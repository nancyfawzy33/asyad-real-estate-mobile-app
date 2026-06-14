import 'package:flutter/material.dart';

class SaveTask extends StatefulWidget {
  const SaveTask({super.key});

  @override
  State<SaveTask> createState() => _SaveTaskState();
}

class _SaveTaskState extends State<SaveTask> {
  // الكنترولرز عشان يسحبوا الكلام اللي كتبتيه
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // خلفية شبه شفافة
      body: Stack(
        children: [
          // قفل الاسكرينة لو دوستي في أي حتة فاضية فوق
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // المؤشر اللي فوق
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("New Notes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),

                  _buildLabel("What needs to be done?"),
                  _buildTextField("Call Client Mr. Hassan", titleController),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Date"), _buildReadOnlyBox("Today, 18 Oct")])),
                      const SizedBox(width: 15),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Time"), _buildReadOnlyBox("02:30 PM")])),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildLabel("Priority"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPriorityChip("High 🔥", const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
                      const SizedBox(width: 10),
                      _buildPriorityChip("Medium", const Color(0xFFF1F5F9), Colors.grey[600]!),
                      const SizedBox(width: 10),
                      _buildPriorityChip("Low", const Color(0xFFF1F5F9), Colors.grey[600]!),
                    ],
                  ),

                  const SizedBox(height: 25),
                  _buildLabel("Additional Notes"),
                  _buildTextField("Add details like address or phone...", noteController, maxLines: 3),

                  const SizedBox(height: 30),

                  // زرار السيف اللي بيقفل الاسكرينة
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // لو العنوان مش فاضي، اقفل الصفحة وابعث البيانات
                        if (titleController.text.isNotEmpty) {
                          Navigator.pop(context, {
                            'title': titleController.text,
                            'subtitle': noteController.text,
                          });
                        } else {
                          // لو فاضي اقفلها وخلاص
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Save Task",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // الـ Widgets المساعدة
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildReadOnlyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(15)),
      child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
    );
  }

  Widget _buildPriorityChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(25)),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}