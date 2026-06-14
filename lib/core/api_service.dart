import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await logout();
        }
        return handler.next(e);
      },
    ));
  }

  // --- 1) Auth ---
  Future<void> logout() async => await _storage.delete(key: 'token');
  Future<Response> register(Map<String, dynamic> data) => _dio.post('/auth/register', data: data);
  Future<Response> login(String email, String password) => _dio.post('/auth/login', data: {'email': email, 'password': password});
  Future<Response> verifyCode(String email, String code) => _dio.post('/auth/verify-code', data: {'email': email, 'code': code});
  Future<Response> forgetPassword(String email) => _dio.post('/auth/forget-password', data: {'email': email});
  Future<Response> resetPassword(String email, String code, String newPassword) =>
      _dio.post('/auth/reset-password', data: {'email': email, 'code': code, 'password': newPassword});

  // --- 2) Profile ---
  Future<Response> getMe() => _dio.get('/users/me');
  Future<Response> updateMe(Map<String, dynamic> data) => _dio.put('/users/me', data: data);

  // --- 3) Properties ---
  Future<Response> getProperties({String? category, double? minPrice, double? maxPrice, String? beds, String? baths}) async {
    Map<String, dynamic> queryParams = {};
    if (category != null && category != "All") queryParams['category'] = category;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (beds != null && beds != "Any") queryParams['bedrooms'] = beds;
    if (baths != null && baths != "Any") queryParams['bathrooms'] = baths;
    return await _dio.get('/properties', queryParameters: queryParams);
  }

  Future<Response> getPropertyDetails(String idOrSlug) => _dio.get('/properties/$idOrSlug');

  // --- 4) Favorites ---
  Future<Response> addToFavorites(String propertyId) => _dio.post('/favorites', data: {'propertyId': propertyId});
  Future<Response> getMyFavorites() => _dio.get('/favorites/me');
  Future<Response> removeFromFavorites(String propertyId) => _dio.delete('/favorites/$propertyId');

  // --- 5) Appointments ---
  Future<Response> bookAppointment(Map<String, dynamic> data) => _dio.post('/appointments', data: data);
  Future<Response> getMyAppointments() => _dio.get('/appointments/me');

  // --- 6) Error Handling (الدالة التي كانت مفقودة) ---
  String extractErrorMessage(Object error, {String fallback = 'Something went wrong'}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? data['msg'] ?? data['errors']?[0]?['msg'];
        if (message is String && message.trim().isNotEmpty) return message;
      }
      if (error.type == DioExceptionType.connectionTimeout) return "Connection timeout. Check your internet.";
      if (error.response?.statusCode == 401) return "Session expired. Please login again.";
    }
    return fallback;
  }
}