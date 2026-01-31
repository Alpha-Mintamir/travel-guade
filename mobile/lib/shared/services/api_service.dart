import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../models/destination.dart';
import '../models/trip_request.dart';
import '../models/notification.dart';

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

  Future<void> forgotPassword(String email) async {
    await _dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post(
      ApiConstants.resetPassword,
      data: {'token': token, 'newPassword': newPassword},
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
    String? interests,
  }) async {
    final response = await _dio.patch(
      ApiConstants.updateProfile,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (cityOfResidence != null) 'cityOfResidence': cityOfResidence,
        if (bio != null) 'bio': bio,
        if (travelPreferences != null) 'travelPreferences': travelPreferences,
        if (interests != null) 'interests': interests,
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
    String? search,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (destinationId != null) queryParams['destinationId'] = destinationId;
    if (region != null) queryParams['region'] = region;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
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
    String? userPhotoUrl,
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
        if (userPhotoUrl != null) 'userPhotoUrl': userPhotoUrl,
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

  Future<Trip> updateTrip(
    String id, {
    String? destinationName,
    DateTime? startDate,
    DateTime? endDate,
    bool? flexibleDates,
    String? description,
    int? peopleNeeded,
    String? budgetLevel,
    String? travelStyle,
    String? instagramUsername,
    String? phoneNumber,
    String? telegramUsername,
    String? photoUrl,
    String? userPhotoUrl,
  }) async {
    final response = await _dio.patch(
      '${ApiConstants.trips}/$id',
      data: {
        if (destinationName != null) 'destinationName': destinationName,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (flexibleDates != null) 'flexibleDates': flexibleDates,
        if (description != null) 'description': description,
        if (peopleNeeded != null) 'peopleNeeded': peopleNeeded,
        if (budgetLevel != null) 'budgetLevel': budgetLevel,
        if (travelStyle != null) 'travelStyle': travelStyle,
        if (instagramUsername != null) 'instagramUsername': instagramUsername,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (telegramUsername != null) 'telegramUsername': telegramUsername,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (userPhotoUrl != null) 'userPhotoUrl': userPhotoUrl,
      },
    );
    return Trip.fromJson(response.data['data']);
  }

  Future<void> deleteTrip(String id) async {
    await _dio.delete('${ApiConstants.trips}/$id');
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

  // Request endpoints
  Future<TripRequest> createTripRequest({
    required String tripId,
    String? message,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.tripRequests}/trips/$tripId/requests',
      data: {
        if (message != null) 'message': message,
      },
    );
    return TripRequest.fromJson(response.data['data']);
  }

  Future<List<TripRequest>> getSentRequests() async {
    final response = await _dio.get(ApiConstants.sentRequests);
    return (response.data['data'] as List)
        .map((json) => TripRequest.fromJson(json))
        .toList();
  }

  Future<List<TripRequest>> getReceivedRequests() async {
    final response = await _dio.get(ApiConstants.receivedRequests);
    return (response.data['data'] as List)
        .map((json) => TripRequest.fromJson(json))
        .toList();
  }

  Future<TripRequest> respondToRequest({
    required String requestId,
    required String status, // 'ACCEPTED' or 'REJECTED'
  }) async {
    final response = await _dio.patch(
      '${ApiConstants.tripRequests}/$requestId/respond',
      data: {'status': status},
    );
    return TripRequest.fromJson(response.data['data']);
  }

  Future<TripRequest?> getMyRequestForTrip(String tripId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.tripRequests}/trips/$tripId/my-request',
      );
      final data = response.data['data'];
      if (data == null) return null;
      return TripRequest.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  // Chat/Conversation endpoints
  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get(ApiConstants.conversations);
    return (response.data['data'] as List)
        .map((json) => Conversation.fromJson(json))
        .toList();
  }

  Future<MessagesResponse> getMessages({
    required String requestId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.tripRequests}/$requestId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );
    return MessagesResponse.fromJson(response.data['data']);
  }

  // Notification endpoints
  Future<List<AppNotification>> getNotifications() async {
    final response = await _dio.get(ApiConstants.notifications);
    return (response.data['data'] as List)
        .map((json) => AppNotification.fromJson(json))
        .toList();
  }

  Future<AppNotification> markNotificationAsRead(String notificationId) async {
    final response = await _dio.patch(
      '${ApiConstants.notifications}/$notificationId/read',
    );
    return AppNotification.fromJson(response.data['data']);
  }

  Future<void> markAllNotificationsAsRead() async {
    await _dio.post('${ApiConstants.notifications}/read-all');
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

class MessagesResponse {
  final List<Message> messages;
  final Pagination pagination;

  MessagesResponse({required this.messages, required this.pagination});

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
