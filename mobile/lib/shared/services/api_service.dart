import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../models/destination.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiService(this._dio, this._storage) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear token and redirect to login
            _storage.delete(key: 'token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Auth endpoints
  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    // Backend wraps response in 'data' field
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
      },
    );
    // Backend wraps response in 'data' field
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<void> verifyEmail(String token) async {
    await _dio.post(
      ApiConstants.verifyEmail,
      data: {'token': token},
    );
  }

  // User endpoints
  Future<User> getCurrentUser() async {
    final response = await _dio.get(ApiConstants.currentUser);
    return User.fromJson(response.data['data']);
  }

  Future<User> updateProfile({
    String? fullName,
    String? cityOfResidence,
    String? bio,
    String? travelPreferences,
  }) async {
    final response = await _dio.patch(
      ApiConstants.updateProfile,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (cityOfResidence != null) 'cityOfResidence': cityOfResidence,
        if (bio != null) 'bio': bio,
        if (travelPreferences != null) 'travelPreferences': travelPreferences,
      },
    );
    return User.fromJson(response.data['data']);
  }

  Future<String> uploadPhoto(String imagePath) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(imagePath),
    });
    final response = await _dio.post(
      ApiConstants.uploadPhoto,
      data: formData,
    );
    return response.data['data']['photoUrl'] as String;
  }

  // Trip endpoints
  Future<List<Trip>> getTrips({
    String? destinationId,
    String? region,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (destinationId != null) queryParams['destinationId'] = destinationId;
    if (region != null) queryParams['region'] = region;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _dio.get(
      ApiConstants.trips,
      queryParameters: queryParams,
    );
    return (response.data['data'] as List)
        .map((json) => Trip.fromJson(json))
        .toList();
  }

  Future<Trip> getTrip(String id) async {
    final response = await _dio.get('${ApiConstants.trips}/$id');
    return Trip.fromJson(response.data['data']);
  }

  Future<Trip> createTrip({
    required String destinationName,
    required DateTime startDate,
    required DateTime endDate,
    bool flexibleDates = false,
    String? description,
    required int peopleNeeded,
    required String budgetLevel,
    required String travelStyle,
    required String instagramUsername,
    String? phoneNumber,
    String? telegramUsername,
    String? photoUrl,
  }) async {
    final response = await _dio.post(
      ApiConstants.trips,
      data: {
        'destinationName': destinationName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'flexibleDates': flexibleDates,
        if (description != null) 'description': description,
        'peopleNeeded': peopleNeeded,
        'budgetLevel': budgetLevel,
        'travelStyle': travelStyle,
        'instagramUsername': instagramUsername,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (telegramUsername != null) 'telegramUsername': telegramUsername,
        if (photoUrl != null) 'photoUrl': photoUrl,
      },
    );
    return Trip.fromJson(response.data['data']);
  }

  Future<String> uploadTripPhoto(List<int> bytes, String filename) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post(
      '${ApiConstants.trips}/upload-photo',
      data: formData,
    );
    return response.data['data']['photoUrl'] as String;
  }

  Future<List<Trip>> getMyTrips() async {
    final response = await _dio.get(ApiConstants.myTrips);
    return (response.data['data'] as List)
        .map((json) => Trip.fromJson(json))
        .toList();
  }

  // Destination endpoints
  Future<List<Destination>> getDestinations({
    String? region,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{};
    if (region != null) queryParams['region'] = region;
    if (type != null) queryParams['type'] = type;

    final response = await _dio.get(
      ApiConstants.destinations,
      queryParameters: queryParams,
    );
    return (response.data['data'] as List)
        .map((json) => Destination.fromJson(json))
        .toList();
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
