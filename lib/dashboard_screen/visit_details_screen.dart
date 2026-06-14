import 'package:flutter/material.dart';

class VisitDetailsScreen extends StatelessWidget {
  final String clientName;
  final String propertyName;
  final String date;
  final String notes;

  // ممنوع يكون فيه const هنا لأننا بنستقبل متغيرات
  VisitDetailsScreen({
    super.key,
    required this.clientName,
    required this.propertyName,
    required this.date,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Visit Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              propertyName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 35),
            _buildRow(Icons.person_outline, "Client: $clientName", Colors.blue),
            const SizedBox(height: 25),
            _buildRow(Icons.calendar_month_outlined, "Date: $date", Colors.blue),
            const SizedBox(height: 25),
            _buildRow(Icons.check_circle, "Status: Completed", Colors.green),
            const SizedBox(height: 50),
            const Text(
              "Client Notes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text(
              notes,
              style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
      ],
    );
  }
}