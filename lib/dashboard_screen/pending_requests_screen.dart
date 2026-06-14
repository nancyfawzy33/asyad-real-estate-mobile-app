import 'package:flutter/material.dart';
import 'request_details_screen.dart';

class PendingRequestsScreen extends StatelessWidget {
  const PendingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pending Requests",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          _buildRequestCard(
            context,
            name: "Fatima Al-Ghamdi",
            date: "Requested: July 26, 3:00 PM",
            image: "assets/images/house1.png",
            phone: "0102856933",
            email: "fatimaalghamdi@gmail.com",
            propertyName: "Villa - New Yasmin",
          ),
          const SizedBox(height: 30),
          _buildRequestCard(
            context,
            name: "Youssef Al-Harbi",
            date: "Requested: July 27, 11:00 AM",
            image: "assets/images/house1.png",
            phone: "01122334455",
            email: "youssef.harbi@gmail.com",
            propertyName: "Villa - New Yasmin",
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context,
      {required String name,
        required String date,
        required String image,
        required String phone,
        required String email,
        required String propertyName}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
              child: const Text("Pending", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: 220,
          height: 45,
          child: ElevatedButton(
            onPressed: () {
              // ✅ دي الطريقة الوحيدة الصح لبعت البيانات
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestDetailsScreen(
                    requestData: {
                      'name': name,
                      'phone': phone,
                      'email': email,
                      'image': image,
                      'propertyName': propertyName,
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text("Review", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}