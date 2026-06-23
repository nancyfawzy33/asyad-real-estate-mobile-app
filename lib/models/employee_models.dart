// ===========================================================
// employee_models.dart
// نماذج البيانات الخاصة بالموظف: التاسكات والتقييمات
// ===========================================================

/// 🟢 دوال مساعدة مشتركة (تفادي تكرار نفس الكود في كل موديل)
class ModelHelpers {
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    try {
      return DateTime.parse(value.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  // بيتعامل مع الحالتين: ID كـ String عادي، أو كـ Map فيها $oid (شكل MongoDB الخام)
  static String resolveId(dynamic value) {
    if (value == null) return '';
    if (value is Map) {
      return (value['\$oid'] ?? value['oid'] ?? '').toString();
    }
    return value.toString();
  }
}

/// الموديل الأساسي بتاع التاسكات الشخصية (تقارير/ملاحظات الموظف)
/// ده الموديل اللي فيه الإصلاح المهم: حقل dateTask
class TaskByEmployee {
  final String id;
  final String employeeId;
  final int? taskNo;
  final String data; // عنوان التاسك
  final String notes;
  final DateTime dateTask; // 🟢 تاريخ التاسك الفعلي (اللي اخترته من الكاليندر)
  final String status; // pending / completed
  final DateTime createdAt;

  TaskByEmployee({
    required this.id,
    required this.employeeId,
    this.taskNo,
    required this.data,
    required this.notes,
    required this.dateTask,
    required this.status,
    required this.createdAt,
  });

  factory TaskByEmployee.fromJson(Map<String, dynamic> json) {
    return TaskByEmployee(
      id: ModelHelpers.resolveId(json['_id'] ?? json['id']),
      employeeId: ModelHelpers.resolveId(json['employeeId']),
      taskNo: json['taskNo'] is int
          ? json['taskNo']
          : int.tryParse(json['taskNo']?.toString() ?? ''),
      data: json['data']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      // لو السيرفر مرجّعش dateTask لأي سبب (تاسك قديم)، نرجع لـ createdAt كحماية
      dateTask: ModelHelpers.parseDate(json['dateTask']) ??
          ModelHelpers.parseDate(json['createdAt']) ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: ModelHelpers.parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employeeId': employeeId,
      'taskNo': taskNo,
      'data': data,
      'notes': notes,
      'dateTask': dateTask.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// الموديل بتاع التاسكات اللي بتتوجه للموظف (من المدير مثلاً)، مرتبطة بعقار/موعد
class TaskToEmployee {
  final String id;
  final String employeeId;
  final String title;
  final String propertyId;
  final String? description;
  final String? appointmentId;
  final DateTime? dueDate;
  final String status;
  final DateTime createdAt;

  TaskToEmployee({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.propertyId,
    this.description,
    this.appointmentId,
    this.dueDate,
    required this.status,
    required this.createdAt,
  });

  factory TaskToEmployee.fromJson(Map<String, dynamic> json) {
    return TaskToEmployee(
      id: ModelHelpers.resolveId(json['_id'] ?? json['id']),
      employeeId: ModelHelpers.resolveId(json['employeeId']),
      title: json['title']?.toString() ?? '',
      propertyId: ModelHelpers.resolveId(json['propertyId']),
      description: json['description']?.toString(),
      appointmentId: json['appointmentId'] != null
          ? ModelHelpers.resolveId(json['appointmentId'])
          : null,
      dueDate: ModelHelpers.parseDate(json['dueDate']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: ModelHelpers.parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }
}

/// الموديل بتاع التقييمات
class Evaluation {
  final String id;
  final String employeeId;
  final int rating;
  final String? comments;
  final String? appointmentId;
  final String? transactionId;
  final DateTime createdAt;

  Evaluation({
    required this.id,
    required this.employeeId,
    required this.rating,
    this.comments,
    this.appointmentId,
    this.transactionId,
    required this.createdAt,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: ModelHelpers.resolveId(json['_id'] ?? json['id']),
      employeeId: ModelHelpers.resolveId(json['employeeId']),
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comments: json['comments']?.toString(),
      appointmentId: json['appointmentId'] != null
          ? ModelHelpers.resolveId(json['appointmentId'])
          : null,
      transactionId: json['transactionId'] != null
          ? ModelHelpers.resolveId(json['transactionId'])
          : null,
      createdAt: ModelHelpers.parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }
}