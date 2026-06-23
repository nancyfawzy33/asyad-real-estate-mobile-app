import 'package:flutter/material.dart';

/// شاشة موحّدة للإنشاء والتعديل:
/// - لو initialTitle == null  -> وضع "إنشاء تاسك جديد"
/// - لو initialTitle != null  -> وضع "تعديل تاسك موجود"
class SaveTask extends StatefulWidget {
  final DateTime selectedDate; // اليوم اللي هيتسجل/معدّل فيه التاسك
  final String? initialTitle; // لو موجودة يبقى احنا في وضع "تعديل"
  final String? initialNotes;

  const SaveTask({
    super.key,
    required this.selectedDate,
    this.initialTitle,
    this.initialNotes,
  });

  @override
  State<SaveTask> createState() => _SaveTaskState();
}

class _SaveTaskState extends State<SaveTask> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.initialTitle != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      isEditing
                          ? Icons.edit_note_rounded
                          : Icons.assignment_turned_in_rounded,
                      color: const Color(0xFF0095FF),
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      isEditing ? "Edit Task" : "Create New Task",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📝 خانة كتابة عنوان التأسك
                  const Text("Task Title",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "e.g., Contacted customer...",
                      hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade100)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? "Title is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // 📝 خانة كتابة الملاحظات الإضافية
                  const Text("Description / Notes",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Add extra details here...",
                      hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade100)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🟢 عرض اليوم المختار (جاي من الكاليندر في شاشة Notes)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Task date: ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}",
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text("Cancel",
                              style: TextStyle(color: Color(0xFF64748B))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // إرجاع البيانات (والتاريخ المختار) لصفحة Notes
                              Navigator.pop(context, {
                                "title": _titleController.text.trim(),
                                "notes": _notesController.text.trim().isEmpty
                                    ? "No extra notes provided"
                                    : _notesController.text.trim(),
                                "dateTask": widget.selectedDate,
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0095FF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(isEditing ? "Save Changes" : "Submit",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}