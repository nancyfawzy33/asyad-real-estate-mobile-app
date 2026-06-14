import 'package:flutter/material.dart';
import 'cancel_appointment_screen.dart';

class AppointmentDetailsScreen extends StatelessWidget {

  final String? name;
  final String? propertyName;
  final String? time;

  const AppointmentDetailsScreen({
    super.key,
    this.name,
    this.propertyName,
    this.time,
  });

  @override
  Widget build(BuildContext context) {

    final displayName = name ?? "Abdullah Al Rajhi";
    final displayProperty = propertyName ?? "Villa - New Yasmin";
    final displayTime = time ?? "11:00 AM";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Appointment Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Image.network(
                      "https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=2071",
                      height: 180, width: double.infinity, fit: BoxFit.cover),
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(displayProperty,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text("Client Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            _infoRow(Icons.phone_outlined, "0102856933"),
            _infoRow(Icons.email_outlined, "abdullahalrajhi00@gmail.com"),
            const SizedBox(height: 30),
            const Text("Property Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network("https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=2071",
                        width: 60, height: 60, fit: BoxFit.cover)),
                const SizedBox(width: 10),
                Expanded(child: Text(displayProperty)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF2ECC71), borderRadius: BorderRadius.circular(20)),
                  child: const Text("Confirmed", style: TextStyle(color: Colors.white, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 30),
            const Text("Appointment Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _infoRow(Icons.calendar_today_outlined, "Today, Oct 26, 2024"),
            _infoRow(Icons.access_time, displayTime),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CancelAppointmentScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFFE74C3C)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Cancel", style: TextStyle(color: Color(0xFFE74C3C), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSuccessDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Complete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 10), Text(text, style: const TextStyle(color: Colors.grey))]));
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 35, backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.check, color: Color(0xFF2ECC71), size: 40)),
              const SizedBox(height: 20),
              const Text("Appointment Confirmed!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              const Text("Client has been notified and\nnotes are saved.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3498DB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Done", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}