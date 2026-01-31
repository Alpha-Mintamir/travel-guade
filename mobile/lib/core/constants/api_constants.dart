abstract class ApiConstants {
  // Base URL - Production API on Vercel
  static const String baseUrl = 'https://travel-guade-fukm.vercel.app/api';
  
  // Local development URL (uncomment for local testing)
  // static const String baseUrl = 'http://10.61.4.107:3000/api';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  
  // User endpoints
  static const String currentUser = '/users/me';
  static const String updateProfile = '/users/me';
  static const String uploadPhoto = '/users/me/photo';
  static const String getUser = '/users';
  
  // Trip endpoints
  static const String trips = '/trips';
  static const String myTrips = '/trips/my-trips';
  
  // Destination endpoints
  static const String destinations = '/destinations';
  
  // Request endpoints
  static const String tripRequests = '/requests';
  static const String sentRequests = '/requests/sent';
  static const String receivedRequests = '/requests/received';
  static const String conversations = '/requests/conversations';
  
  // Notification endpoints
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications';
  
  // Socket.io namespace
  static const String socketNamespace = '/';
}
