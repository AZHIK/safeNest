/// API Configuration Constants
///
/// Contains base URLs, endpoints, and timeout configurations.
/// Update [baseUrl] based on your environment (dev/staging/prod).
class ApiConstants {
  ApiConstants._();

  // Base URL - Change per environment
  // Production: 'https://api.safenest.example.com/api/v1'
  // Android Emulator: use 'http://10.0.2.2:8000/api/v1' (localhost on host)
  // iOS Simulator: use 'http://localhost:8000/api/v1'
  // Physical Device: use your computer's IP
  static const String baseUrl = 'http://10.220.83.68:8000/api/v1';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ==================== AUTH ====================
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String anonymousSession = '/auth/anonymous';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String currentUser = '/auth/me';
  static const String updateProfile = '/auth/me';
  static const String trustedContacts = '/auth/trusted-contacts';

  // ==================== SOS ====================
  static const String sosTrigger = '/sos/trigger';
  static const String sosLocationUpdate = '/sos/location-update';
  static const String sosLocationBatch = '/sos/location-batch';
  static const String sosStatus = '/sos/status';
  static const String sosActive = '/sos/active';
  static const String sosHistory = '/sos/history';

  // ==================== REPORTING ====================
  static const String reportsCreate = '/reports/create';
  static const String reportsMyReports = '/reports/my-reports';
  static const String reportsDetail = '/reports';
  static const String reportsUploadEvidence = '/reports/upload-evidence';

  // ==================== MESSAGING ====================
  static const String messagesConversations = '/messages/conversations';
  static const String messagesSend = '/messages/send';
  static const String messagesWs = '/messages/ws/chat';

  // ==================== SUPPORT CENTERS ====================
  static const String supportCentersNearby = '/support-centers/nearby';
  static const String supportCentersDetail = '/support-centers';
  static const String supportCentersByType = '/support-centers/type';
  static const String supportCentersVerified = '/support-centers/verified/list';

  // ==================== TRAINING ====================
  static const String trainingCategories = '/training/categories';
  static const String trainingCategoryBySlug = '/training/categories';
  static const String trainingLessons = '/training/lessons';
  static const String trainingLessonDetail = '/training/lesson';
}
