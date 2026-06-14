import 'package:flutter/material.dart';
import 'visit_details_screen.dart';
import 'visit_rejected_screen.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}
class _AddNoteState extends State<AddNote> {
  String selectedFilter = "All";

  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Visit Accepted",
      "subtitle": "Your visit with 'John Smith' for 'Sunnyvale Estate' has been confirmed.",
      "time": "10 minutes ago",
      "icon": Icons.check,
      "color": const Color(0xFF4CAF50),
      "hasUnreadDot": true,
      "type": "User Actions",
    },
    {
      "title": "Visit Rejected",
      "subtitle": "Emily White has cancelled the visit for Downtown Loft.",
      "time": "30 minutes ago",
      "icon": Icons.close,
      "color": const Color(0xFFE53935),
      "hasUnreadDot": false,
      "type": "User Actions",
    },
    {
      "title": "Waiting for Client Response",
      "subtitle": "Jane Doe is reviewing your suggested time for Cityside Condo.",
      "time": "10 minutes ago",
      "icon": Icons.access_time,
      "color": const Color(0xFFFBC02D),
      "hasUnreadDot": true,
      "type": "User Actions",
    },
    {
      "title": "Upcoming Visit Reminder",
      "subtitle": "Lakeside Villa tomorrow at 10:00 AM.",
      "time": "5 minutes ago",
      "icon": Icons.notifications_none,
      "color": const Color(0xFF039BE5),
      "hasUnreadDot": false,
      "type": "Appointments",
      "showRightDot": true,
    },
  ];

  List<Map<String, dynamic>> get filteredList {
    if (selectedFilter == "All") return notifications;
    return notifications.where((item) => item["type"] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterButton("All", width: 80),
                _buildFilterButton("User Actions", width: 135),
                _buildFilterButton("Appointments", width: 135),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return InkWell(
                  onTap: () {
                    if (item["title"] == "Visit Rejected") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VisitRejectedScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VisitDetailsScreen(),
                        ),
                      );
                    }
                  },
                  child: _buildListItem(item),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          selectedItemColor: const Color(0xFF039BE5),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconSize: 32,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Booking'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, {double? width}) {
    bool isSelected = selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        width: width,
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF039BE5) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 45),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: item["color"],
            radius: 28,
            child: Icon(item["icon"], color: Colors.white, size: 26),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (item["hasUnreadDot"] == true)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.circle, color: Color(0xFF039BE5), size: 12),
                            ),
                          Flexible(
                            child: Text(
                              item["title"],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item["time"],
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item["subtitle"],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}