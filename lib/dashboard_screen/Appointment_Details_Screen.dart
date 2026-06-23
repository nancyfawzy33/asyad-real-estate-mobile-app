import 'package:flutter/material.dart';
import 'cancel_appointment_screen.dart'; // تأكدي من وجود هذا الملف أيضاً

class AppointmentDetailsScreen extends StatelessWidget {
  final String? name;
  final String? propertyName;
  final String? time;

  const AppointmentDetailsScreen({super.key, this.name, this.propertyName, this.time});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Appointment Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network("https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=2071", height: 180, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: 25),
            Text(name ?? "Client Name", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Text("Property: ${propertyName ?? 'N/A'}"),
            Text("Time: ${time ?? 'N/A'}"),
            const SizedBox(height: 40),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CancelAppointmentScreen())), child: const Text("Cancel"))),
              const SizedBox(width: 15),
              Expanded(child: ElevatedButton(onPressed: () => _showSuccessDialog(context), child: const Text("Complete"))),
            ])
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Appointment Confirmed!"), content: const Text("Notes saved."), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))]));
  }
}