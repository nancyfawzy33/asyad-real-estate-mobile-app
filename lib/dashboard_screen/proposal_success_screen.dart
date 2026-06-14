import 'package:flutter/material.dart';
// تأكدي من كتابة المسار الصحيح لملف الداشبورد عندك
import 'employee_dashboard.dart';

class ProposalSuccessScreen extends StatelessWidget {
  final Map<String, dynamic>? requestData;
  const ProposalSuccessScreen({super.key, this.requestData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const Spacer(flex: 3),
            const Center(
              child: CircleAvatar(
                radius: 65,
                backgroundColor: Color(0xFF007BFF),
                child: Icon(Icons.file_upload_outlined, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Your proposal has been sent\nsuccessfully",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 20),
            const Text(
              "You will be notified once the appointment is\nconfirmed by the other party.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 60),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Appointment Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  _buildDetailRow(Icons.calendar_month_outlined, "Date: Friday, June 18, 2026"),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.access_time, "01:00 AM"),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.location_on_outlined, requestData?['propertyName'] ?? "Villa - New Yasmin"),
                ],
              ),
            ),
            const Spacer(flex: 4),

            // --- الزرار بعد التعديل ---
            ElevatedButton(
              onPressed: () {
                // الكود ده هيفتح صفحة الداشبورد ويمسح كل اللي فات عشان يصفر الـ Navigation Stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const EmployeeDashboard()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text("Back to Home",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 15),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400)),
      ],
    );
  }
}