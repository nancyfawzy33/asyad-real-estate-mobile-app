import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // تأكدي من إضافة حزمة intl في الـ pubspec.yaml لتنسيق التواريخ بسهولة

import '../core/employee_api_service.dart';
import '../models/employee_models.dart';
import 'save_task.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  int selectedDateIndex = 0; // سيتم تحديده ديناميكياً ليوافق اليوم الحالي
  int _currentNavIndex = 1;
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();

  List<dynamic> _allPendingTasks = [];
  List<dynamic> _allCompletedTasks = [];

  List<dynamic> _filteredPendingTasks = [];
  List<dynamic> _filteredCompletedTasks = [];

  final List<DateTime> _calendarDates =
  List.generate(7, (index) => DateTime.now().add(Duration(days: index)));

  @override
  void initState() {
    super.initState();
    selectedDateIndex = 0;
    _fetchTasksData();
  }

  Future<void> _fetchTasksData() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      String? currentEmployeeId = await _storage.read(key: 'employeeId');
      currentEmployeeId ??= "664abc123def456789012345";

      final employeeApi =
      Provider.of<EmployeeApiService>(context, listen: false);

      final pendingResult = await employeeApi.getTasksByEmployee(
        employeeId: currentEmployeeId,
        status: 'pending',
      );
      final completedResult = await employeeApi.getTasksByEmployee(
        employeeId: currentEmployeeId,
        status: 'completed',
      );

      if (mounted) {
        setState(() {
          _allPendingTasks = pendingResult;
          _allCompletedTasks = completedResult;

          // تشغيل الفلترة بناءً على اليوم المختار حالياً
          _filterTasksByDay();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("🎯 Notes Fetch Error: $e");
    }
  }

  // 🟢 الفلترة بقت على dateTask الحقيقي بتاع التاسك (مش تاريخ الإنشاء)
  void _filterTasksByDay() {
    DateTime selectedDateTime = _calendarDates[selectedDateIndex];
    String selectedDayStr = selectedDateTime.day.toString();
    String selectedMonthStr = selectedDateTime.month.toString();
    String selectedYearStr = selectedDateTime.year.toString();

    setState(() {
      // تصفية حذرة للـ Pending Tasks
      _filteredPendingTasks = _allPendingTasks.where((task) {
        if (task == null) return false;
        try {
          DateTime taskDate = _resolveTaskDate(task);
          return taskDate.day.toString() == selectedDayStr &&
              taskDate.month.toString() == selectedMonthStr &&
              taskDate.year.toString() == selectedYearStr;
        } catch (_) {
          // لو مفيش تاريخ مسجل خالص، بنظهره في يوم إنشائه الافتراضي (اليوم الأول)
          return selectedDateIndex == 0;
        }
      }).toList();

      // تصفية حذرة للـ Completed Tasks
      _filteredCompletedTasks = _allCompletedTasks.where((task) {
        if (task == null) return false;
        try {
          DateTime taskDate = _resolveTaskDate(task);
          return taskDate.day.toString() == selectedDayStr &&
              taskDate.month.toString() == selectedMonthStr &&
              taskDate.year.toString() == selectedYearStr;
        } catch (_) {
          return selectedDateIndex == 0;
        }
      }).toList();
    });
  }

  // 🆕 دالة موحّدة لاستخراج تاريخ التاسك: dateTask أولاً، وإلا createdAt كـ fallback
  DateTime _resolveTaskDate(dynamic task) {
    try {
      if (task.dateTask != null) {
        return task.dateTask is String
            ? DateTime.parse(task.dateTask)
            : task.dateTask;
      }
    } catch (_) {}

    try {
      if (task.createdAt != null) {
        return task.createdAt is String
            ? DateTime.parse(task.createdAt)
            : task.createdAt;
      }
    } catch (_) {}

    throw Exception("No date available for task");
  }

  // 🎯 دالة تحديث حالة التأسك المحمية بالكامل
  Future<void> _toggleTaskStatus(String resolvedTaskId) async {
    if (resolvedTaskId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error: Task ID could not be identified"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      final employeeApi =
      Provider.of<EmployeeApiService>(context, listen: false);

      await employeeApi.updateTaskByEmployee(resolvedTaskId, {
        'status': 'completed',
      });

      await Future.delayed(const Duration(milliseconds: 300));
      _fetchTasksData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task marked as completed! 🎉"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update task: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🎯 فتح صفحة الكتابة وإنشاء التأسك بناءً على اليوم المختار في الكاليندر
  Future<void> _openSaveTaskScreen() async {
    final DateTime chosenDate = _calendarDates[selectedDateIndex];

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => SaveTask(selectedDate: chosenDate),
      ),
    );

    if (result != null && result is Map) {
      try {
        setState(() => _isLoading = true);

        final employeeApi =
        Provider.of<EmployeeApiService>(context, listen: false);

        String? currentEmployeeId = await _storage.read(key: 'employeeId');

        currentEmployeeId ??= "664abc123def456789012345";

        int nextTaskNo =
        (_allPendingTasks.length + _allCompletedTasks.length + 1);

        await employeeApi.submitTaskByEmployee(
          employeeId: currentEmployeeId,
          taskNo: nextTaskNo,
          data: result['title'].toString(),
          notes: result['notes'].toString(),
          dateTask: result['dateTask'] as DateTime,// 🟢 اليوم المختار من الكاليندر
        );

        await _fetchTasksData();

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Task added successfully 🎉"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit task: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🆕 فتح صفحة التعديل على تاسك موجود (العنوان / الملاحظات / اليوم)
  Future<void> _openEditTaskScreen(dynamic task) async {
    final String taskId = _safeResolveId(task);
    if (taskId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error: Task ID could not be identified"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    DateTime existingDate;
    try {
      existingDate = _resolveTaskDate(task);
    } catch (_) {
      existingDate = DateTime.now();
    }

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => SaveTask(
          selectedDate: existingDate,
          initialTitle: task.data ?? '',
          initialNotes: task.notes ?? '',
        ),
      ),
    );

    if (result != null && result is Map) {
      try {
        setState(() => _isLoading = true);

        final employeeApi =
        Provider.of<EmployeeApiService>(context, listen: false);

        await employeeApi.updateTaskByEmployee(taskId, {
          'data': result['title'].toString(),
          'notes': result['notes'].toString(),
          'dateTask': result['dateTask'],
        });

        await _fetchTasksData();

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Task updated successfully ✏️"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update task: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // دالة متبعة لاستخراج الـ ID بشكل صارم وآمن يمنع كراش الـ Map نهائياً
  String _safeResolveId(dynamic task) {
    if (task == null) return '';

    // محاولة استخراج الحقل المباشر لو الـ Model مظبوط
    try {
      if (task.id != null) {
        if (task.id is Map) {
          return (task.id['\$oid'] ?? task.id['oid'] ?? '').toString();
        }
        return task.id.toString();
      }
    } catch (_) {}

    // محاولة استخراج بديلة في حال كان الـ object راجع كـ Map خام أو من حقل الـ instance الأصلي
    try {
      final rawId = task.id;
      if (rawId is Map) {
        return (rawId['\$oid'] ?? rawId['oid'] ?? '').toString();
      }
    } catch (_) {}

    return '';
  }

  @override
  Widget build(BuildContext context) {
    // عرض اسم الشهر الحالي بناءً على اليوم المحدد
    String currentMonthYear =
    DateFormat('MMMM yyyy').format(_calendarDates[selectedDateIndex]).toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, 0),
        ),
        title: const Text("Notes",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF007BFF)))
          : RefreshIndicator(
        onRefresh: _fetchTasksData,
        color: const Color(0xFF007BFF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(currentMonthYear,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const SizedBox(height: 15),

              // 🗓️ شريط الأيام القابل للتمرير الأفقي
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _calendarDates.length,
                  itemBuilder: (context, index) {
                    DateTime date = _calendarDates[index];
                    String dayName =
                    DateFormat('E').format(date).toUpperCase(); // MON, TUE
                    String dayNum = DateFormat('d').format(date); // 17, 18
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _buildCalendarItem(index, dayName, dayNum),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              Text("Today's Plan (${_filteredPendingTasks.length})",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _filteredPendingTasks.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No tasks for this day 👍",
                    style: TextStyle(color: Colors.grey)),
              )
                  : Column(
                children: _filteredPendingTasks.map((task) {
                  final String cleanId = _safeResolveId(task);
                  return _buildPlanItem(
                      task: task,
                      taskId: cleanId,
                      title: task.data ?? "No Title",
                      subtitle: task.notes ?? "No Notes provided",
                      color: const Color(0xFF007BFF),
                      icon: Icons.assignment_outlined);
                }).toList(),
              ),

              const SizedBox(height: 30),

              Text("Completed (${_filteredCompletedTasks.length})",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _filteredCompletedTasks.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("No completed tasks",
                    style:
                    TextStyle(color: Colors.grey, fontSize: 13)),
              )
                  : Column(
                children: _filteredCompletedTasks.map((task) {
                  return _buildCompletedItem(
                      task: task,
                      title: task.data ?? "Completed Task",
                      subtitle: task.notes ?? "Done");
                }).toList(),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
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
          if (index == 0) Navigator.pop(context, 0);
          setState(() => _currentNavIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined), label: "Notes"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded), label: "Notification"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildCalendarItem(int index, String day, String date) {
    bool isSelected = selectedDateIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDateIndex = index;
          _filterTasksByDay(); // إعادة التصفية الفورية لليوم المحدد
        });
      },
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0095FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day,
                style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(date,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 🆕 ضفنا onLongPress + زرار edit صريح، وبقت تستقبل التاسك كامل بدل الـ id لوحده
  Widget _buildPlanItem({
    required dynamic task,
    required String taskId,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => _toggleTaskStatus(taskId),
      onLongPress: () => _openEditTaskScreen(task), // ضغط مطوّل = تعديل سريع
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
            ]),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                  width: 10,
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20)))),
              Expanded(
                child: ListTile(
                  title: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: Colors.grey, size: 20),
                        onPressed: () => _openEditTaskScreen(task), // زرار تعديل صريح
                      ),
                      const Icon(Icons.circle_outlined,
                          color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🆕 بقت تقبل التاسك كامل برضه، لو عايز تضيف تعديل على التاسكات المكتملة كمان
  Widget _buildCompletedItem({
    required dynamic task,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onLongPress: () => _openEditTaskScreen(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          title: Text(title,
              style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 15)),
          subtitle:
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: const CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFF10B981),
              child: Icon(Icons.check, color: Colors.white, size: 15)),
        ),
      ),
    );
  }
}