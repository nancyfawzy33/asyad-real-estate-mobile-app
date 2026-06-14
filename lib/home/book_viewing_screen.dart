import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_service.dart';
import 'appointment_confirmed_screen.dart';

class BookViewingScreen extends StatefulWidget {
  final String propertyId;
  const BookViewingScreen({super.key, required this.propertyId});

  @override
  State<BookViewingScreen> createState() => _BookViewingScreenState();
}

class _BookViewingScreenState extends State<BookViewingScreen> {
  int selectedDateIndex = 0;
  int selectedTimeIndex = 1;
  bool _isBooking = false;
  final TextEditingController _notesController = TextEditingController();

  // توليد قائمة بـ 7 أيام قادمة ابتداءً من الغد
  final List<DateTime> availableDates = List.generate(7, (index) => DateTime.now().add(Duration(days: index + 1)));

  final List<String> times = ["10:00 AM", "11:30 AM", "02:00 PM", "04:30 PM", "06:00 PM"];

  Future<void> _handleBooking() async {
    setState(() => _isBooking = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final selectedDate = availableDates[selectedDateIndex];
      final timeStr = times[selectedTimeIndex];

      // معالجة فائقة الأمان لتحويل الوقت وتجنب الـ String/int index type error
      int hour = 12;
      int minute = 0;

      try {
        final cleanedTimeStr = timeStr.trim().replaceAll(RegExp(r'\s+'), ' '); // تنظيف المسافات الزائدة
        final parts = cleanedTimeStr.split(' ');
        if (parts.length >= 2) {
          final timeParts = parts[0].split(':');
          if (timeParts.length >= 2) {
            hour = int.tryParse(timeParts[0]) ?? 12;
            minute = int.tryParse(timeParts[1]) ?? 0;

            final isPM = parts[1].toUpperCase().contains('PM');
            final isAM = parts[1].toUpperCase().contains('AM');

            if (isPM && hour < 12) hour += 12;
            if (isAM && hour == 12) hour = 0;
          }
        }
      } catch (e) {
        debugPrint("Time Parsing Safe Block Error: $e");
      }

      final startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour, minute);
      final endTime = startTime.add(const Duration(hours: 1)); // الحجز مدته ساعة ديفولت

      // إرسال الطلب للسيرفر
      final response = await apiService.bookAppointment({
        "propertyId": widget.propertyId,
        "startTime": startTime.toIso8601String(),
        "endTime": endTime.toIso8601String(),
        "notes": _notesController.text.trim(),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context); // إغلاق الـ Bottom Sheet

        // الانتقال لشاشة النجاح
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppointmentConfirmedScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to book appointment. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 25, right: 25, top: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 25),
            const Text("Book a Viewing", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),

            const Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(children: List.generate(availableDates.length, (index) => _buildDateCard(index))),
            ),

            const SizedBox(height: 30),
            const Text("Available Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            Wrap(spacing: 12, runSpacing: 12, children: List.generate(times.length, (index) => _buildTimeCard(index))),

            const SizedBox(height: 30),
            const Text("Notes (Optional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: "E.g. I want to see the garden...",
                filled: true, fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _handleBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isBooking
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(int index) {
    bool isSelected = selectedDateIndex == index;
    DateTime date = availableDates[index];
    return GestureDetector(
      onTap: () => setState(() => selectedDateIndex = index),
      child: Container(
        width: 70, height: 90, margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_getMonthName(date.month), style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
            const SizedBox(height: 5),
            Text(date.day.toString(), style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  Widget _buildTimeCard(int index) {
    bool isSelected = selectedTimeIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTimeIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200),
        ),
        child: Text(times[index], style: TextStyle(color: isSelected ? Colors.blue : Colors.black54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}