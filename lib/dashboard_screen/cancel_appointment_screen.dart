import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/employee_api_service.dart';

class CancelAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic>? appointmentData;

  const CancelAppointmentScreen({
    super.key,
    this.appointmentData,
  });

  @override
  State<CancelAppointmentScreen> createState() => _CancelAppointmentScreenState();
}

class _CancelAppointmentScreenState extends State<CancelAppointmentScreen> {
  bool _isSubmitting = false;
  final TextEditingController _reasonController = TextEditingController();

  // دالة حل مشكلة الـ ID بأمان
  String _safeResolveId(dynamic rawId) {
    if (rawId == null) return '';
    if (rawId is Map) {
      return (rawId['\$oid'] ?? rawId['oid'] ?? '').toString();
    }
    return rawId.toString();
  }

  // 🎯 الدالة المسؤولة عن معالجة الإلغاء وإرساله للسيرفر
  Future<void> _submitCancellation() async {
    final rawId = widget.appointmentData?['_id'] ?? widget.appointmentData?['id'];
    final String taskId = _safeResolveId(rawId);

    if (taskId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Valid Appointment ID not found")),
      );
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a reason for cancellation"), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);
      final employeeApi = Provider.of<EmployeeApiService>(context, listen: false);

      // تحديث حالة التأسك إلى cancelled وإرسال سبب الإلغاء
      await employeeApi.updateTaskToEmployee(taskId, {
        'status': 'cancelled',
        'cancellationReason': _reasonController.text.trim(),
      });

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // إظهار رسالة نجاح والرجوع للخلف مع عمل ريفريش
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment cancelled successfully"), backgroundColor: Colors.redAccent),
      );

      // نرجع بـ true للشاشة السابقة عشان تعمل تحديث تلقائي
      Navigator.pop(context, true);

    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel appointment: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayProperty = widget.appointmentData?['title'] ?? "Villa - New Yasmin";

    // 🎯 الحل الجذري للإيرور: تحويل الـ DateTime إلى String بأمان قبل عرضه
    dynamic rawDate = widget.appointmentData?['date'];
    String displayDate = "Today";

    if (rawDate != null) {
      if (rawDate is DateTime) {
        displayDate = DateFormat('MMM d, yyyy').format(rawDate);
      } else {
        displayDate = rawDate.toString(); // لو جاي String جاهز مش هيعترض
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Cancel Appointment",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE74C3C)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to cancel this appointment?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 10),
            Text(
              "$displayProperty ($displayDate)",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),
            const Text(
              "Reason for Cancellation",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter the reason here...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE74C3C)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitCancellation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text(
                  "Confirm Cancellation",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}