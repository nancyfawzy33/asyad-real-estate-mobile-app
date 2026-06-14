import 'package:flutter/material.dart';
import '../profile/notifications_screen.dart'; // تأكدي إن المسار صح عندك

class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.center,
      // الـ padding ده بيضمن إن الكارت يفرش في الشاشة زي الصورة بالظبط
      insetPadding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35), // انحناء الحواف زي الصورة
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان وزرار الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notifications",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[300], size: 28),
                )
              ],
            ),
            const SizedBox(height: 20),

            // قسم NEW
            const Text(
              "NEW",
              style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1),
            ),
            const SizedBox(height: 15),

            _buildFullItem(
                icon: Icons.check,
                color: Colors.green,
                title: "Booking Confirmed",
                sub: "Grand Villa visit is set.",
                time: "2h",
                hasDot: true
            ),
            _buildFullItem(
                icon: Icons.arrow_downward,
                color: Colors.orange,
                title: "Price Drop Alert!",
                sub: "Sky Penthouse is 5% off.",
                time: "5h",
                hasDot: true
            ),

            const SizedBox(height: 20),

            // قسم EARLIER
            const Text(
              "EARLIER",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1),
            ),
            const SizedBox(height: 15),

            _buildFullItem(
                icon: Icons.person_outline,
                color: Colors.black,
                title: "Complete Profile",
                sub: "Add your payment info.",
                time: "1d",
                hasDot: false
            ),

            const SizedBox(height: 30),

            // زرار See All Notifications
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
                child: const Text(
                  "See All Notifications",
                  style: TextStyle(
                    color: Color(0xFF007BFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // حجم الخط زي الصورة
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ميثود بتبني العنصر كامل بالأيقونة والوقت والنقطة الزرقاء
  Widget _buildFullItem({
    required IconData icon,
    required Color color,
    required String title,
    required String sub,
    required String time,
    required bool hasDot
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 4),
                Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              const SizedBox(height: 8),
              if (hasDot)
                const CircleAvatar(radius: 4, backgroundColor: Color(0xFF007BFF)),
            ],
          ),
        ],
      ),
    );
  }
}