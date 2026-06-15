import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/employee_api_service.dart';
import '../models/employee_models.dart';
import 'save_task.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  int selectedDateIndex = 0;
  int _currentNavIndex = 1;
  bool _isLoading = true;

  // قوائم لتخزين البيانات الديناميكية القادمة من الباك اند (TaskByEmployee)
  List<TaskByEmployee> _pendingTasks = [];
  List<TaskByEmployee> _completedTasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasksData();
  }

  // 🎯 دالة جلب البيانات ديناميكياً من الباك اند (Pending & Completed)
  Future<void> _fetchTasksData() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final employeeApi = Provider.of<EmployeeApiService>(context, listen: false);

      // استدعاء دالة getTasksByEmployee المخصصة لتقارير الموظف من السيرفر
      final pendingResult = await employeeApi.getTasksByEmployee(status: 'pending');
      final completedResult = await employeeApi.getTasksByEmployee(status: 'completed');

      if (mounted) {
        setState(() {
          _pendingTasks = pendingResult;
          _completedTasks = completedResult;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("🎯 Notes Fetch Error: $e");
    }
  }

  // 🎯 الدالة المعدلة بالكامل لفتح صفحة SaveTask وإرسال الـ Request Body المطلوب بالظبط
  void _openSaveTaskScreen() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => const SaveTask(),
      ),
    );

    // لو الموظف دخل بيانات وداس Save Task وراجع بـ Map
    if (result != null && result is Map<String, dynamic>) {
      try {
        setState(() => _isLoading = true);
        final employeeApi = Provider.of<EmployeeApiService>(context, listen: false);

        // حساب الـ taskNo التالي تلقائياً كـ int عشان السيرفر يقبله (نوعه Number بالباك اند)
        int nextTaskNo = (_pendingTasks.length + _completedTasks.length + 1);

        // 🎯 إرسال البيانات بمطابقة تامة للـ Example Request Body بتاعك
        await employeeApi.submitTaskByEmployee(
          employeeId: "664abc123def456789012345", // الـ ID الحقيقي للموظف المسؤول
          taskNo: nextTaskNo,                     // بيبعت الرقم كـ int صريح (1، 2، 3...)
          data: result['title'] ?? "Contacted customer and scheduled appointment successfully", // البيانات الأساسية من التكست فيلد
          notes: result['subtitle'] ?? "Customer is very interested, prefers morning visits",    // الملاحظات الإضافية
        );

        // بعد الحفظ بنجاح، بنعمل تحديث (Refresh) للداتا ديناميكياً من السيرفر
        _fetchTasksData();

      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit task: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Notes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
          : RefreshIndicator(
        onRefresh: _fetchTasksData, // اسحبي الشاشة لتحت لتحديث البيانات تلقائياً من السيرفر
        color: const Color(0xFF007BFF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("JUNE 2026", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCalendarItem(0, "MON", "15"),
                  _buildCalendarItem(1, "TUE", "16"),
                  _buildCalendarItem(2, "WED", "17"),
                  _buildCalendarItem(3, "THU", "18"),
                ],
              ),
              const SizedBox(height: 30),

              // خطة اليوم الديناميكية (Pending Tasks القادمة من الباك اند)
              Text("Today's Plan (${_pendingTasks.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _pendingTasks.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No tasks in today's plan 👍", style: TextStyle(color: Colors.grey)),
              )
                  : Column(
                children: _pendingTasks.map((task) {
                  return _buildPlanItem(
                      task.data ?? "No Title",
                      task.notes ?? "No Notes provided",
                      const Color(0xFF007BFF),
                      Icons.assignment_outlined
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // قسم التأسكات المكتملة الديناميكي (Completed Tasks)
              Text("Completed (${_completedTasks.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _completedTasks.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("No completed tasks yet", style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
                  : Column(
                children: _completedTasks.map((task) {
                  return _buildCompletedItem(
                      task.data ?? "Completed Task",
                      task.notes ?? "Done"
                  );
                }).toList(),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // الزرار الدائري لفتح اسكرينة الـ SaveTask وإضافة نوت جديدة
      floatingActionButton: FloatingActionButton(
        onPressed: _openSaveTaskScreen,
        backgroundColor: const Color(0xFF0095FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF007BFF),
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
          setState(() => _currentNavIndex = index);
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

  // الـ Widgets المساعدة بالتصميم القديم
  Widget _buildCalendarItem(int index, String day, String date) {
    bool isSelected = selectedDateIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedDateIndex = index),
      child: Container(
        width: 75, padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0095FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Text(day, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
            const SizedBox(height: 5),
            Text(date, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanItem(String title, String subtitle, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 10, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)))),
            Expanded(child: ListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), trailing: const Icon(Icons.circle_outlined, color: Colors.grey, size: 20))),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        title: Text(title, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const CircleAvatar(radius: 12, backgroundColor: Color(0xFF10B981), child: Icon(Icons.check, color: Colors.white, size: 15)),
      ),
    );
  }
}