import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/employee_api_service.dart';
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

  // 🎯 رجعناهم String عشان الكاش يفوق وميضربش टाइप إيرور
  String _pendingCount = "0";
  String _completedCount = "0";
  String _appointmentsCount = "5";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // جلب البيانات ديناميكياً من السيرفر وتحديث العدادات
  Future<void> _fetchDashboardData() async {
    try {
      final employeeApi = Provider.of<EmployeeApiService>(context, listen: false);

      // جلب التأسكات المعلقة والمكتملة من السيرفر
      final pendingResult = await employeeApi.getTasksToEmployee(status: 'pending');
      final completedResult = await employeeApi.getTasksToEmployee(status: 'completed');

      if (mounted) {
        setState(() {
          // 🎯 التحويل لـ String هنا بشكل سليم عشان يتوافق مع المتغيرات فوق
          _pendingCount = pendingResult.length.toString();
          _completedCount = completedResult.length.toString();
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
                const Text(
                  "Hey, Nancy",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Here is a summary of your daily activity at Asyad Real Estate",
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                ),

                const SizedBox(height: 30),

                // الكروت العلوية (Stats الإحصائيات الحقيقية المربوطة بالـ API)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TodayAppointmentsScreen()),
                        );
                      },
                      child: _buildStatCard("Today's\nAppointments:", _appointmentsCount, const Color(0xFF007BFF), Icons.calendar_month),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PendingRequestsScreen()),
                        );
                      },
                      child: _buildStatCard("Pending\nRequests:", _pendingCount, const Color(0xFFF59E0B), Icons.access_time),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CompletedTasksScreen()),
                        );
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
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesScreen()),
            );
          }
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddNote()),
            );
          }
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmployeeProfile()),
            );
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