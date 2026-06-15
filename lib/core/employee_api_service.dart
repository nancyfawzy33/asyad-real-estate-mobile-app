import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';
import '../models/employee_models.dart';

class EmployeeApiService {
  static final EmployeeApiService _instance = EmployeeApiService._internal();
  factory EmployeeApiService() => _instance;

  // 🎯 شيلنا الـ (_) عشان تبقا public ونقدر نستخدمها في الـ Provider
  final Dio dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final _storage = const FlutterSecureStorage();

  EmployeeApiService._internal() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(_handleDioError(e));
      },
    ));
  }

  DioException _handleDioError(DioException e) {
    String message = "An unexpected error occurred";
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'];
      }
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message = "Connection timeout";
          break;
        case DioExceptionType.sendTimeout:
          message = "Send timeout";
          break;
        case DioExceptionType.receiveTimeout:
          message = "Receive timeout";
          break;
        case DioExceptionType.badResponse:
          message = "Bad response from server";
          break;
        case DioExceptionType.cancel:
          message = "Request cancelled";
          break;
        default:
          message = "Network connection issue";
      }
    }
    return e.copyWith(error: ApiException(message, statusCode: e.response?.statusCode));
  }

  Future<T> _request<T>(Future<Response> Function() call, T Function(dynamic data) mapper) async {
    try {
      final response = await call();
      return mapper(response.data);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error!;
      }
      throw ApiException("Failed to perform request: ${e.message}");
    } catch (e) {
      throw ApiException("An unexpected error occurred: $e");
    }
  }

  // --- 1. Tasks To Employees ---

  Future<TaskToEmployee> createTaskToEmployee({
    required String employeeId,
    required String title,
    required String propertyId,
    String? description,
    String? appointmentId,
    DateTime? dueDate,
  }) {
    return _request(
          () => dio.post('/tasks-to-employees', data: {
        'employeeId': employeeId,
        'title': title,
        'propertyId': propertyId,
        'description': description,
        'appointmentId': appointmentId,
        'dueDate': dueDate?.toIso8601String(),
      }),
          (data) => TaskToEmployee.fromJson(data['task'] ?? data),
    );
  }

  Future<List<TaskToEmployee>> getTasksToEmployee({String? employeeId, String? status}) {
    return _request(
          () => dio.get('/tasks-to-employees', queryParameters: {
        if (employeeId != null) 'employeeId': employeeId,
        if (status != null) 'status': status,
      }),
          (data) {
        final list = data is Map ? (data['tasks'] ?? data['data'] ?? []) : data;
        return (list as List).map((item) => TaskToEmployee.fromJson(item)).toList();
      },
    );
  }

  Future<TaskToEmployee> updateTaskToEmployee(String id, Map<String, dynamic> fields) {
    return _request(
          () => dio.patch('/tasks-to-employees/$id', data: fields),
          (data) => TaskToEmployee.fromJson(data['task'] ?? data),
    );
  }

  // --- 2. Tasks By Employees (الخاص بالتقارير والنوتس) ---

  Future<TaskByEmployee> submitTaskByEmployee({
    required String employeeId,
    required int taskNo,
    required String data,
    String? notes,
  }) {
    return _request(
          () => dio.post('/tasks-by-employees', data: {
        'employeeId': employeeId,
        'taskNo': taskNo,
        'data': data,
        'notes': notes,
      }),
          (data) => TaskByEmployee.fromJson(data['task'] ?? data),
    );
  }

  Future<List<TaskByEmployee>> getTasksByEmployee({String? employeeId, String? status}) {
    return _request(
          () => dio.get('/tasks-by-employees', queryParameters: {
        if (employeeId != null) 'employeeId': employeeId,
        if (status != null) 'status': status,
      }),
          (data) {
        final list = data is Map ? (data['tasks'] ?? data['data'] ?? []) : data;
        return (list as List).map((item) => TaskByEmployee.fromJson(item)).toList();
      },
    );
  }

  Future<TaskByEmployee> updateTaskByEmployee(String id, Map<String, dynamic> fields) {
    return _request(
          () => dio.patch('/tasks-by-employees/$id', data: fields),
          (data) => TaskByEmployee.fromJson(data['task'] ?? data),
    );
  }

  // --- 3. Evaluations ---

  Future<Evaluation> createEvaluation({
    required String employeeId,
    required int rating,
    String? comments,
    String? appointmentId,
    String? transactionId,
  }) {
    return _request(
          () => dio.post('/evaluations', data: {
        'employeeId': employeeId,
        'rating': rating,
        'comments': comments,
        'appointmentId': appointmentId,
        'transactionId': transactionId,
      }),
          (data) => Evaluation.fromJson(data['evaluation'] ?? data),
    );
  }

  Future<List<Evaluation>> getEvaluations({String? employeeId}) {
    return _request(
          () => dio.get('/evaluations', queryParameters: {
        if (employeeId != null) 'employeeId': employeeId,
      }),
          (data) {
        final list = data is Map ? (data['evaluations'] ?? data['data'] ?? []) : data;
        return (list as List).map((item) => Evaluation.fromJson(item)).toList();
      },
    );
  }
}