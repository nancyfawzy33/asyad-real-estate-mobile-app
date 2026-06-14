import 'package:flutter/material.dart';
import 'save_task.dart'; // تأكدي من استدعاء ملف صفحة السيف تاسك

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  int selectedDateIndex = 0;
  int _currentNavIndex = 1;

  final List<Map<String, dynamic>> _tasks = [
    {
      "title": "Meeting with Mr. Karim",
      "subtitle": "Palm Hills Compound • 10:00 AM",
      "color": const Color(0xFF007BFF),
      "icon": Icons.location_on
    },
    {
      "title": "Call New Leads (5)",
      "subtitle": "Follow up on recent requests",
      "color": const Color(0xFFF59E0B),
      "icon": Icons.phone
    },
  ];

  // --- الدالة الجديدة لفتح صفحة SaveTask واستلام البيانات ---
  void _openSaveTaskScreen() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, // عشان نقدر نشوف الخلفية الشفافة
        pageBuilder: (_, __, ___) => const SaveTask(),
      ),
    );

    // لو راجع ببيانات (يعني داس على Save Task)
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _tasks.add({
          "title": result['title'],
          "subtitle": result['subtitle'].toString().isEmpty
              ? "Today, 18 Oct • 02:30 PM"
              : result['subtitle'],
          "color": const Color(0xFF0095FF),
          "icon": Icons.assignment_outlined,
        });
      });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("OCTOBER 2026", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCalendarItem(0, "MON", "18"),
                _buildCalendarItem(1, "TUE", "19"),
                _buildCalendarItem(2, "WED", "20"),
                _buildCalendarItem(3, "THU", "21"),
              ],
            ),
            const SizedBox(height: 30),
            Text("Today's Plan (${_tasks.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            ..._tasks.map((task) => _buildPlanItem(task["title"], task["subtitle"], task["color"], task["icon"])),

            const SizedBox(height: 30),
            const Text("Completed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildCompletedItem("Send Contract Draft", "Sent to Legal Dept."),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // الزرار دلوقتي هيفتح اسكرينة الـ SaveTask اللي بعتيها
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

  // الـ Widgets المساعدة (نفس كودك السابق بدون تغيير)
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