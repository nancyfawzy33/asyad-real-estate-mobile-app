import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_service.dart';
import '../home/property_details_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List _favorites = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getMyFavorites();

      if (mounted) {
        final raw = response.data;
        List result = [];
        if (raw is List) {
          result = raw;
        } else if (raw is Map) {
          result = (raw['data'] ?? raw['favorites'] ?? raw['results'] ?? []) as List;
        }

        // ✅ لو الـ property مش موجودة جوا كل item، نجيب تفاصيلها من الـ API
        final List enriched = [];
        for (final item in result) {
          if (item is Map) {
            // لو في property object كامل جوا الـ item
            if (item['property'] != null && item['property'] is Map) {
              enriched.add(item);
            } else {
              // نجيب الـ propertyId ونعمل call منفصل
              final idRaw = item['propertyId'];
              final String pid = (idRaw is Map)
                  ? (idRaw['\$oid'] ?? idRaw['_id'] ?? '').toString()
                  : idRaw?.toString() ?? '';

              if (pid.isNotEmpty) {
                try {
                  final detailRes = await apiService.getPropertyDetails(pid);
                  final detailData = detailRes.data;
                  Map<String, dynamic> propertyData = {};
                  if (detailData is Map && detailData.containsKey('data')) {
                    propertyData = Map<String, dynamic>.from(detailData['data']);
                  } else if (detailData is Map) {
                    propertyData = Map<String, dynamic>.from(detailData);
                  }
                  enriched.add({ ...Map<String, dynamic>.from(item), 'property': propertyData });
                } catch (_) {
                  enriched.add(item);
                }
              } else {
                enriched.add(item);
              }
            }
          }
        }

        setState(() { _favorites = enriched; _isLoading = false; });
      }
    } catch (e) {
      debugPrint('❌ Error fetching favorites: $e');
      if (mounted) setState(() { _isLoading = false; _errorMessage = 'Failed to load saved homes.'; });
    }
  }

  Future<void> _removeFromFavorites(String propertyId, int index) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.removeFromFavorites(propertyId);
      setState(() => _favorites.removeAt(index));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from saved'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      debugPrint('❌ Error removing favorite: $e');
    }
  }

  // ✅ نفس طريقة property_details في استخراج الـ image url
  String _extractImageUrl(Map<String, dynamic> property) {
    final images = property['images'] as List?;
    if (images == null || images.isEmpty) return '';
    final first = images[0];
    if (first is Map) return first['url']?.toString() ?? '';
    return first.toString();
  }

  String _extractPropertyId(Map raw, Map<String, dynamic> property) {
    final idRaw = raw['propertyId'] ?? property['_id'];
    if (idRaw is Map) return (idRaw['\$oid'] ?? '').toString();
    return idRaw?.toString() ?? '';
  }

  String _formatPrice(dynamic price) {
    final num p = num.tryParse(price.toString()) ?? 0;
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}M';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}K';
    return p.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Saved Homes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              SizedBox(height: 4),
              Text('Your favourite properties', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: const Icon(Icons.favorite, color: Color(0xFF0095FF), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0095FF)));
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchFavorites,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0095FF)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }
    if (_favorites.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0095FF).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border, size: 52, color: Color(0xFF0095FF)),
          ),
          const SizedBox(height: 20),
          const Text('No saved homes yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          const Text('Properties you save will appear here', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchFavorites,
      color: const Color(0xFF0095FF),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        itemCount: _favorites.length,
        itemBuilder: (context, index) => _buildFavoriteCard(index),
      ),
    );
  }

  Widget _buildFavoriteCard(int index) {
    final raw = _favorites[index] as Map;

    // ✅ نفس logic الـ property_details في استخراج الداتا
    final Map<String, dynamic> property = raw['property'] != null
        ? Map<String, dynamic>.from(raw['property'])
        : Map<String, dynamic>.from(raw);

    final String name = property['name']?.toString() ?? 'Property';
    final dynamic price = property['price'];
    final dynamic beds = property['bedrooms'] ?? property['beds'];
    final dynamic baths = property['bathrooms'] ?? property['baths'];
    final details = property['details'] as Map?;
    final dynamic area = details?['area'] ?? property['area'] ?? property['size'];

    // ✅ location زي الـ property_details بالظبط
    final locationMap = property['location'];
    final String location = locationMap is Map
        ? '${locationMap['city'] ?? ''}, ${locationMap['address'] ?? ''}'.trim().replaceAll(RegExp(r'^,\s*|,\s*$'), '')
        : property['location']?.toString() ?? property['address']?.toString() ?? 'Cairo, Egypt';

    // ✅ image url زي الـ property_details بالظبط
    final String imageUrl = _extractImageUrl(property);
    final String propertyId = _extractPropertyId(raw, property);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailsScreen(propertyId: propertyId)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // ✅ نفس error handling الـ property_details
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey.shade100,
                        child: const Center(child: CircularProgressIndicator(color: Color(0xFF0095FF), strokeWidth: 2)),
                      );
                    },
                  )
                      : _imagePlaceholder(),
                ),
                // Price badge
                if (price != null)
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFF0095FF), borderRadius: BorderRadius.circular(8)),
                      child: Text('EGP ${_formatPrice(price)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                // Remove from favorites
                Positioned(
                  top: 12, right: 12,
                  child: GestureDetector(
                    onTap: () => _removeFromFavorites(propertyId, index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            // ── Info ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on, size: 13, color: Color(0xFF0095FF)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(location,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    if (beds != null) ...[
                      const Icon(Icons.bed_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$beds Beds', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                    if (baths != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.bathtub_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$baths Baths', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                    if (area != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.square_foot, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$area m²', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: const Icon(Icons.home, size: 60, color: Colors.grey),
    );
  }
}