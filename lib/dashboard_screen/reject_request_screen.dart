import 'package:flutter/material.dart';

class RejectRequestScreen extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const RejectRequestScreen({super.key, required this.requestData});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            // صورة العقار
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  Image.asset(
                      requestData['image'] ?? 'assets/images/house1.png',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
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
            ),

            const Spacer(),

            // الدائرة الحمراء وعلامة الـ X
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 50,
              ),
            ),

            const SizedBox(height: 30),

            // نص الرفض
            const Text(
              "Cancel this appointment?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)
              ),
            ),

            const Spacer(),

            // زرار الكونفيرم لوحده في النص
            SizedBox(
              width: double.infinity, // واخد العرض كله
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(vertical: 18), // أتخن شوية عشان يبقى أوضح
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text(
                    "Confirm Cancellation",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}