enum TaskStatus { pending, accepted, rejected, completed }

class EmployeeRef {
  final String id;
  final String name;
  final String email;

  EmployeeRef({required this.id, required this.name, required this.email});

  factory EmployeeRef.fromJson(Map<String, dynamic> json) {
    return EmployeeRef(
      id: json['_id'] ?? '',
      name: json['name'] ?? json['userName'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
  };
}

class PropertyRef {
  final String id;
  final String title;
  final String city;

  PropertyRef({required this.id, required this.title, required this.city});

  factory PropertyRef.fromJson(Map<String, dynamic> json) {
    return PropertyRef(
      id: json['_id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'city': city,
  };
}

class TaskToEmployee {
  final String id;
  final dynamic employee; // String ID or EmployeeRef
  final dynamic property; // String ID or PropertyRef
  final String? appointmentId;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskToEmployee({
    required this.id,
    required this.employee,
    required this.property,
    this.appointmentId,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskToEmployee.fromJson(Map<String, dynamic> json) {
    return TaskToEmployee(
      id: json['_id'] ?? '',
      employee: json['employeeId'] is Map
          ? EmployeeRef.fromJson(json['employeeId'])
          : json['employeeId'],
      property: json['propertyId'] is Map
          ? PropertyRef.fromJson(json['propertyId'])
          : json['propertyId'],
      appointmentId: json['appointmentId'],
      title: json['title'] ?? '',
      description: json['description'],
      status: _parseStatus(json['status']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'employeeId': employee is EmployeeRef ? employee.toJson() : employee,
    'propertyId': property is PropertyRef ? property.toJson() : property,
    'appointmentId': appointmentId,
    'title': title,
    'description': description,
    'status': status.name,
    'dueDate': dueDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static TaskStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted': return TaskStatus.accepted;
      case 'rejected': return TaskStatus.rejected;
      case 'completed': return TaskStatus.completed;
      default: return TaskStatus.pending;
    }
  }
}

class TaskByEmployee {
  final String id;
  final dynamic employee;
  final int taskNo;
  final String data;
  final String? notes;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskByEmployee({
    required this.id,
    required this.employee,
    required this.taskNo,
    required this.data,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskByEmployee.fromJson(Map<String, dynamic> json) {
    return TaskByEmployee(
      id: json['_id'] ?? '',
      employee: json['employeeId'] is Map
          ? EmployeeRef.fromJson(json['employeeId'])
          : json['employeeId'],
      taskNo: json['taskNo'] ?? 0,
      data: json['data'] ?? '',
      notes: json['notes'],
      status: TaskToEmployee._parseStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'employeeId': employee is EmployeeRef ? employee.toJson() : employee,
    'taskNo': taskNo,
    'data': data,
    'notes': notes,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class Evaluation {
  final String id;
  final String employeeId;
  final int rating;
  final String? comments;
  final DateTime evaluationDate;
  final EvaluatorRef? ratingBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Evaluation({
    required this.id,
    required this.employeeId,
    required this.rating,
    this.comments,
    required this.evaluationDate,
    this.ratingBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['_id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      rating: json['rating'] ?? 0,
      comments: json['comments'],
      evaluationDate: DateTime.parse(json['evaluationDate'] ?? DateTime.now().toIso8601String()),
      ratingBy: json['ratingBy'] != null ? EvaluatorRef.fromJson(json['ratingBy']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'employeeId': employeeId,
    'rating': rating,
    'comments': comments,
    'evaluationDate': evaluationDate.toIso8601String(),
    'ratingBy': ratingBy?.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class EvaluatorRef {
  final String id;
  final String userName;
  final String email;
  final String phoneNumber;

  EvaluatorRef({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
  });

  factory EvaluatorRef.fromJson(Map<String, dynamic> json) {
    return EvaluatorRef(
      id: json['_id'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userName': userName,
    'email': email,
    'phone_number': phoneNumber,
  };
}

class ApiError {
  final String message;

  ApiError({required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(message: json['message'] ?? 'Unknown error occurred');
  }
}
