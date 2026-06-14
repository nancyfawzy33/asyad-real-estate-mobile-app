import 'package:flutter/material.dart';
import 'proposal_success_screen.dart';

class SuggestTimeScreen extends StatefulWidget {
  // إضافة علامة الاستفهام (?) تجعل المتغير يقبل أن يكون Null لحماية التطبيق من الـ Crash
  final Map<String, dynamic>? requestData;

  const SuggestTimeScreen({super.key, this.requestData});

  @override
  State<SuggestTimeScreen> createState() => _SuggestTimeScreenState();
}

class _SuggestTimeScreenState extends State<SuggestTimeScreen> {
  int selectedDateIndex = 1;
  int selectedSlotIndex = 1;

  @override
  Widget build(BuildContext context) {
    // تأمين البيانات: لو الـ requestData جت Null، بنستخدم Map فاضية
    final data = widget.requestData ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Suggest Another\nTime",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CURRENT REQUEST", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Wed, July 26, 3:00 PM", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  const Text("Unavailable", style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Select New Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateItem(0, "Thu", "17"),
                _buildDateItem(1, "Fri", "18"),
                _buildDateItem(2, "Sat", "19"),
                _buildDateItem(3, "Sun", "20"),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Available Slots", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeSlot(0, "10:00 AM"),
                _buildTimeSlot(1, "01:00 PM"),
                _buildTimeSlot(2, "04:30 PM"),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Add Note (Optional)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your message here...",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),

            const SizedBox(height: 100),

            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProposalSuccessScreen(
                        // نمرر البيانات المؤمنة أو بيانات افتراضية لو فارغة
                        requestData: widget.requestData ?? {"propertyName": "Villa - New Yasmin"},
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text("Send Proposal", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(int index, String day, String date) {
    bool isSelected = selectedDateIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedDateIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0095FF) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(day, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey)),
            Text(date, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(int index, String time) {
    bool isSelected = selectedSlotIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedSlotIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0095FF) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
        ),
        child: Text(time, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
      ),
    );
  }
}