import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_service.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getMyAppointments();

      final raw = response.data;
      List result = [];
      if (raw is List) {
        result = raw;
      } else if (raw is Map) {
        result = (raw['data'] ?? raw['appointments'] ?? raw['results'] ?? []) as List;
      }

      // ✅ نجيب اسم الـ property بس (مش محتاجين صور)
      final List enriched = [];
      for (final item in result) {
        if (item is! Map) continue;
        final appt = Map<String, dynamic>.from(item);

        final propIdRaw = appt['propertyId'];
        final String propId = propIdRaw is Map
            ? (propIdRaw['\$oid'] ?? '').toString()
            : propIdRaw?.toString() ?? '';

        if (propId.isNotEmpty) {
          try {
            final propRes = await apiService.getPropertyDetails(propId);
            final propData = propRes.data;
            Map<String, dynamic> property = {};
            if (propData is Map && propData.containsKey('data')) {
              property = Map<String, dynamic>.from(propData['data']);
            } else if (propData is Map) {
              property = Map<String, dynamic>.from(propData);
            }
            appt['_propertyName']     = property['name']?.toString() ?? 'Property';
            appt['_propertyLocation'] = _extractLocation(property['location']);
            appt['_propertyType']     = property['propertyType']?.toString() ?? '';
          } catch (_) {
            appt['_propertyName'] = 'Property';
          }
        }
        enriched.add(appt);
      }

      if (mounted) setState(() { _appointments = enriched; _isLoading = false; });
    } catch (e) {
      debugPrint('❌ Appointments error: $e');
      if (mounted) setState(() { _isLoading = false; _errorMessage = 'Failed to load appointments.'; });
    }
  }

  String _extractLocation(dynamic loc) {
    if (loc is Map) {
      final city    = loc['city']?.toString() ?? '';
      final address = loc['address']?.toString() ?? '';
      return [city, address].where((s) => s.isNotEmpty).join(', ');
    }
    return loc?.toString() ?? '';
  }

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return 'N/A';
    final String iso = dateVal is Map
        ? (dateVal['\$date']?.toString() ?? '')
        : dateVal.toString();
    if (iso.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
      const days   = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final min  = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}  •  $hour:$min $ampm';
    } catch (_) { return iso; }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':  return Colors.green;
      case 'completed':  return const Color(0xFF0095FF);
      case 'pending':    return Colors.orange;
      case 'cancelled':  return Colors.red;
      default:           return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':  return Icons.check_circle_outline;
      case 'completed':  return Icons.done_all;
      case 'pending':    return Icons.access_time;
      case 'cancelled':  return Icons.cancel_outlined;
      default:           return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1A1A2E)),
          ),
        ),
        title: const Text('My Appointments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0095FF)));
    }
    if (_errorMessage != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
        const SizedBox(height: 12),
        Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _fetchAppointments,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0095FF)),
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ]));
    }
    if (_appointments.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0095FF).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_today_outlined, size: 52, color: Color(0xFF0095FF)),
        ),
        const SizedBox(height: 20),
        const Text('No appointments yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        const Text('Book a property visit to see it here',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
      ]));
    }

    return RefreshIndicator(
      onRefresh: _fetchAppointments,
      color: const Color(0xFF0095FF),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _appointments.length,
        itemBuilder: (_, i) => _buildCard(_appointments[i]),
      ),
    );
  }

  Widget _buildCard(dynamic item) {
    final Map<String, dynamic> appt = Map<String, dynamic>.from(item as Map);

    final String name     = appt['_propertyName']?.toString() ?? 'Property';
    final String location = appt['_propertyLocation']?.toString() ?? '';
    final String type     = appt['_propertyType']?.toString() ?? '';
    final String status   = appt['status']?.toString() ?? 'pending';
    final String start    = _formatDate(appt['startTime']);
    final String end      = _formatDate(appt['endTime']);
    final String notes    = appt['notes']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── اسم الـ property + status ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0095FF).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.home_outlined, color: Color(0xFF0095FF), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (type.isNotEmpty)
                        Text(type, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_statusIcon(status), size: 12, color: _statusColor(status)),
                  const SizedBox(width: 4),
                  Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusColor(status)),
                  ),
                ]),
              ),
            ],
          ),

          // ── location ──
          if (location.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.location_on, size: 13, color: Color(0xFF0095FF)),
              const SizedBox(width: 4),
              Expanded(child: Text(location,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // ── Start ──
          _infoRow(Icons.play_circle_outline, 'Start', start),
          const SizedBox(height: 8),

          // ── End ──
          _infoRow(Icons.stop_circle_outlined, 'End', end),

          // ── Notes ──
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.notes_outlined, 'Notes', notes),
          ],
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 15, color: const Color(0xFF0095FF)),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Expanded(
        child: Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}