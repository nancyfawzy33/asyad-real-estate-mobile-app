import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70, // ✅ كبرنا ارتفاع الـ AppBar
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28), // ✅ كبرنا سهم الرجوع
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24, // ✅ كبرنا العنوان الرئيسي
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF007BFF), size: 28), // ✅ كبرنا أيقونة الصح
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20), // ✅ زودنا الـ Padding الجانبي
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم NEW
            const Text(
              "NEW",
              style: TextStyle(
                color: Color(0xFF007BFF),
                fontWeight: FontWeight.bold,
                fontSize: 15, // ✅ كبرنا كلمة NEW
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            _buildRow(Icons.check, Colors.green, "Booking Confirmed", "Grand Villa visit is set.", "2h", true),
            _buildRow(Icons.arrow_downward, Colors.orange, "Price Drop Alert!", "Sky Penthouse is 5% off.", "5h", true),

            const SizedBox(height: 35), // ✅ مسافة أكبر بين الأقسام

            // قسم EARLIER
            const Text(
              "EARLIER",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 15, // ✅ كبرنا كلمة EARLIER
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            _buildRow(Icons.person_outline, Colors.black, "Complete Profile", "Add your payment info.", "1d", false),
            _buildRow(Icons.arrow_upward, Colors.grey, "System Update", "Bug fixes and improvements.", "2d", false),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, Color color, String title, String sub, String time, bool unread) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0), // ✅ مسافة أكبر بين كل إشعار والتاني
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14), // ✅ كبرنا المربع اللي خلف الأيقونة
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 26), // ✅ كبرنا الأيقونة نفسها
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // ✅ كبرنا عنوان الإشعار
                ),
                const SizedBox(height: 6),
                Text(
                  sub,
                  style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.3), // ✅ كبرنا الكلام اللي تحت
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(color: Colors.grey[400], fontSize: 13), // ✅ كبرنا الوقت شوية
              ),
              const SizedBox(height: 10),
              if (unread)
                const CircleAvatar(
                  radius: 5, // ✅ كبرنا النقطة الزرقاء
                  backgroundColor: Color(0xFF007BFF),
                ),
            ],
          ),
        ],
      ),
    );
  }
}