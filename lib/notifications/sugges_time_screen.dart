import 'package:flutter/material.dart';

class SuggestTimeScreen extends StatefulWidget {
  const SuggestTimeScreen({super.key});

  @override
  State<SuggestTimeScreen> createState() => _SuggestTimeScreenState();
}

class _SuggestTimeScreenState extends State<SuggestTimeScreen> {
  // متغيرات لتخزين الاختيارات الحالية (Date & Time)
  int selectedDateIndex = 0;
  String selectedTime = "11:30 AM";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Suggest New Time",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // --- الكارت العلوي الصغير (مطابق للصورة تماماً) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Visit Rejected",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Luxury Villa, Oceanview Estate",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Friday, Oct 28, 2024 at 11:00 AM",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Select Date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // --- قائمة التواريخ ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDateCard(0, "Oct", "12"),
                  _buildDateCard(1, "Oct", "13"),
                  _buildDateCard(2, "Oct", "14"),
                  _buildDateCard(3, "Oct", "15"),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Available Time",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // --- شبكة الأوقات ---
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildTimeChip("10:00 AM"),
                _buildTimeChip("11:30 AM"),
                _buildTimeChip("02:00 PM"),
                _buildTimeChip("04:30 PM"),
              ],
            ),

            const Spacer(),

            // --- زر Send Proposal (بدون أكشن بناءً على طلبك) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // لا يخرج أي شيء حالياً
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF), // نفس درجة الأزرق في الصورة
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // حواف دائرية (Pill shape)
                    ),
                  ),
                  child: const Text(
                    "Send Proposal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويجيت بناء كارت التاريخ
  Widget _buildDateCard(int index, String month, String day) {
    bool isSelected = selectedDateIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedDateIndex = index),
      child: Container(
        width: 65,
        padding: const EdgeInsets.symmetric(vertical: 15),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007BFF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade100,
          ),
        ),
        child: Column(
          children: [
            Text(
              month,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويجيت بناء خيارات الوقت
  Widget _buildTimeChip(String time) {
    bool isSelected = selectedTime == time;
    return GestureDetector(
      onTap: () => setState(() => selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF007BFF) : Colors.transparent,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? const Color(0xFF007BFF) : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}