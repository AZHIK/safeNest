import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../providers/api_provider.dart';
import '../models/training_model.dart';
import 'base_repository.dart';

/// Training Repository
///
/// Handles training content - categories and lessons.
class TrainingRepository extends BaseRepository {
  final ApiClient _apiClient;

  TrainingRepository(this._apiClient);

  /// Get all training categories
  Future<List<TrainingCategoryResponse>> getCategories({
    bool featured = false,
    int limit = 50,
  }) async {
    return execute(() async {
      final response = await _apiClient.get(
        ApiConstants.trainingCategories,
        queryParameters: {'featured': featured, 'limit': limit},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map(
            (e) => TrainingCategoryResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    });
  }

  /// Get category by slug
  Future<TrainingCategoryResponse> getCategoryBySlug(String slug) async {
    return execute(() async {
      final response = await _apiClient.get(
        '${ApiConstants.trainingCategoryBySlug}/$slug',
      );
      return TrainingCategoryResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Get training lessons
  Future<List<TrainingLessonResponse>> getLessons({
    int skip = 0,
    int limit = 50,
    String? categoryId,
  }) async {
    return execute(() async {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
        'category_id': categoryId,
      };
      queryParams.removeWhere((key, value) => value == null);

      final response = await _apiClient.get(
        ApiConstants.trainingLessons,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map(
            (e) => TrainingLessonResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    });
  }

  /// Get lesson details
  Future<TrainingLessonDetail> getLessonDetail(String lessonId) async {
    return execute(() async {
      final response = await _apiClient.get(
        '${ApiConstants.trainingLessonDetail}/$lessonId',
      );
      return TrainingLessonDetail.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Get lesson by slug
  Future<TrainingLessonResponse> getLessonBySlug(String slug) async {
    return execute(() async {
      final response = await _apiClient.get(
        '${ApiConstants.trainingLessonDetail}/slug/$slug',
      );
      return TrainingLessonResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }
}

/// Provider for TrainingRepository
final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return TrainingRepository(apiClient);
});
