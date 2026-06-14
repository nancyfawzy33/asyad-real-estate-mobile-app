import 'package:flutter/material.dart';
import 'reject_request_screen.dart';
import 'suggest_time_screen.dart'; // تأكدي أن الملف موجود بهذا الاسم

class RequestDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const RequestDetailsScreen({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text("Pending Requests", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const Text("Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الكارت الكبير للصورة
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    requestData['image'] ?? 'assets/images/house1.png',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("Pending", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 15,
                  child: Text(
                    requestData['propertyName'] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text("Client Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(requestData['name'] ?? "", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.phone_outlined, requestData['phone'] ?? ""),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.email_outlined, requestData['email'] ?? ""),

            const SizedBox(height: 30),
            const Text("Property Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(requestData['image'] ?? 'assets/images/house1.png', width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 15),
                  Expanded(child: Text(requestData['propertyName'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFE6F7F0), borderRadius: BorderRadius.circular(10)),
                    child: const Text("Confirmed", style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Client Message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "Looking forward to seeing this property.\nMorning availability is best.",
              style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                _buildActionBtn("Reject", const Color(0xFFFFEBEB), const Color(0xFFEF4444), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RejectRequestScreen(requestData: requestData),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                _buildActionBtn("Suggest Another time", const Color(0xFFEBF5FF), const Color(0xFF007BFF), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuggestTimeScreen(requestData: requestData),
                    ),
                  );
                }),

                const SizedBox(width: 8),
                _buildActionBtn("Approve", const Color(0xFF10B981), Colors.white, () => _showSuccessDialog(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String info) {
    return Row(children: [Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 10), Text(info, style: const TextStyle(color: Colors.grey, fontSize: 15))]);
  }

  Widget _buildActionBtn(String label, Color bg, Color textCol, VoidCallback tap) {
    return Expanded(
      child: InkWell(
        onTap: tap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.check_circle, color: Color(0xFF10B981), size: 60),
              ),
              const SizedBox(height: 25),
              const Text("Appointment Confirmed!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("The appointment has been added\nto Today's Appointments.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095FF),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}