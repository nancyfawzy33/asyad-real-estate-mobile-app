import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/employee_api_service.dart';

// 🎯 تأكدي من أن هذا الـ Import يشير بالظبط إلى مكان ملف الـ NotesScreen الإحترافي الذي أرسلتيه
import '../notes/notes_screen.dart';

import '../notifications/add_note.dart';
import '../profileadmin/employee_profile.dart';
import '../models/employee_models.dart';
import 'today_appointments_screen.dart';
import 'pending_requests_screen.dart';
import 'completed_tasks_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _currentIndex = 0;
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();

  String _employeeName = "Employee";
  String _pendingCount = "0";
  String _completedCount = "0";
  String _appointmentsCount = "0";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final employeeApi = Provider.of<EmployeeApiService>(context, listen: false);

      String? savedName = await _storage.read(key: 'employeeName');
      String? currentEmployeeId = await _storage.read(key: 'employeeId');
      currentEmployeeId ??= "664abc123def456789012345";

      final pendingResult = await employeeApi.getTasksToEmployee(status: 'pending');
      final completedResult = await employeeApi.getTasksToEmployee(status: 'completed');

      final todayAppointmentsResult = await employeeApi.getTasksByEmployee(
        employeeId: currentEmployeeId,
        status: 'pending',
      );

      DateTime now = DateTime.now();
      String currentDay = now.day.toString();
      String currentMonth = now.month.toString();

      final todayTasks = todayAppointmentsResult.where((task) {
        if (task == null) return false;
        try {
          DateTime? taskDate = task.dateTask ?? task.createdAt;
          return taskDate.day.toString() == currentDay &&
              taskDate.month.toString() == currentMonth;
        } catch (_) {}
        return true;
      }).toList();

      if (mounted) {
        setState(() {
          if (savedName != null && savedName.isNotEmpty) {
            _employeeName = savedName;
          }
          _pendingCount = pendingResult.length.toString();
          _completedCount = completedResult.length.toString();
          _appointmentsCount = todayTasks.length.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("🎯 Dashboard Fetch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
            : RefreshIndicator(
          onRefresh: _fetchDashboardData,
          color: const Color(0xFF007BFF),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hey, $_employeeName",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Here is a summary of your daily activity at Asyad Real Estate",
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TodayAppointmentsScreen()),
                        ).then((_) => _fetchDashboardData());
                      },
                      child: _buildStatCard("Today's\nAppointments:", _appointmentsCount, const Color(0xFF007BFF), Icons.calendar_month),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PendingRequestsScreen()),
                        ).then((_) => _fetchDashboardData());
                      },
                      child: _buildStatCard("Pending\nRequests:", _pendingCount, const Color(0xFFF59E0B), Icons.access_time),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CompletedTasksScreen()),
                        ).then((_) => _fetchDashboardData());
                      },
                      child: _buildStatCard("Completed:", _completedCount, const Color(0xFF10B981), Icons.check_circle_outline),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Important warnings",
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 28),
                  ],
                ),

                const SizedBox(height: 20),
                _buildWarningItem(
                  title: "A lease agreement that will expire soon",
                  subtitle: "Apartment 204 lease expires in 5 days",
                  color: const Color(0xFFF59E0B),
                ),
                _buildWarningItem(
                  title: "Required documents",
                  subtitle: "Please upload a copy of the customer's ID, Mohammed Ali",
                  color: const Color(0xFFFFCC80),
                ),
                _buildWarningItem(
                  title: "Task completed",
                  subtitle: "Reference number 5512 has been successfully archived",
                  color: const Color(0xFF10B981),
                ),
                _buildWarningItem(
                  title: "A property receipt error occurred",
                  subtitle: "The client, Osama Ahmed, received the wrong property",
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF007BFF),
        unselectedItemColor: const Color(0xFF94A3B8),
        onTap: (index) {
          if (index == _currentIndex) return;

          if (index == 0) {
            setState(() => _currentIndex = 0);
          }
          else if (index == 1) {
            // 🎯 هنا هينتقل مباشرة لشاشتك الإحترافية اللي فيها الكاليندر والـ SaveTask
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesScreen()),
            ).then((_) {
              setState(() => _currentIndex = 0); // إعادة تصفير اللون عند الرجوع للداشبورد
              _fetchDashboardData();
            });
          }
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddNote()),
            ).then((_) {
              setState(() => _currentIndex = 0);
              _fetchDashboardData();
            });
          }
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmployeeProfile()),
            ).then((_) {
              setState(() => _currentIndex = 0);
              _fetchDashboardData();
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Notes"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.2)),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWarningItem({required String title, required String subtitle, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}