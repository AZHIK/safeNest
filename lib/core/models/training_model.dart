import 'base_model.dart';

/// Training Category Response Model
class TrainingCategoryResponse extends BaseModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconName;
  final String? colorCode;
  final int sortOrder;
  final bool isActive;
  final bool isFeatured;
  final int lessonCount;

  const TrainingCategoryResponse({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconName,
    this.colorCode,
    required this.sortOrder,
    required this.isActive,
    required this.isFeatured,
    required this.lessonCount,
  });

  factory TrainingCategoryResponse.fromJson(Map<String, dynamic> json) {
    return TrainingCategoryResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      colorCode: json['color_code'] as String?,
      sortOrder: json['sort_order'] as int,
      isActive: json['is_active'] as bool,
      isFeatured: json['is_featured'] as bool,
      lessonCount: json['lesson_count'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon_name': iconName,
      'color_code': colorCode,
      'sort_order': sortOrder,
      'is_active': isActive,
      'is_featured': isFeatured,
      'lesson_count': lessonCount,
    };
  }
}

/// Training Lesson Response Model
class TrainingLessonResponse extends BaseModel {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final int? durationMinutes;
  final String difficultyLevel;
  final bool isActive;
  final bool isPremium;
  final String categoryId;
  final String? thumbnailUrl;
  final int viewCount;
  final int sortOrder;
  final DateTime createdAt;

  const TrainingLessonResponse({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.durationMinutes,
    required this.difficultyLevel,
    required this.isActive,
    required this.isPremium,
    required this.categoryId,
    this.thumbnailUrl,
    required this.viewCount,
    required this.sortOrder,
    required this.createdAt,
  });

  factory TrainingLessonResponse.fromJson(Map<String, dynamic> json) {
    return TrainingLessonResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      difficultyLevel: json['difficulty_level'] as String,
      isActive: json['is_active'] as bool,
      isPremium: json['is_premium'] as bool,
      categoryId: json['category_id'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      viewCount: json['view_count'] as int,
      sortOrder: json['sort_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'duration_minutes': durationMinutes,
      'difficulty_level': difficultyLevel,
      'is_active': isActive,
      'is_premium': isPremium,
      'category_id': categoryId,
      'thumbnail_url': thumbnailUrl,
      'view_count': viewCount,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Training Lesson Detail Model (with full content)
class TrainingLessonDetail extends BaseModel {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final int? durationMinutes;
  final String difficultyLevel;
  final bool isActive;
  final bool isPremium;
  final String categoryId;
  final String? thumbnailUrl;
  final int viewCount;
  final int sortOrder;
  final DateTime createdAt;
  final List<ContentBlock>? contentBlocks;
  final String? videoUrl;
  final String? audioUrl;
  final String? pdfUrl;
  final String? tags;
  final List<String>? relatedLessonIds;
  final int completionCount;
  final double? ratingAverage;
  final int ratingCount;

  const TrainingLessonDetail({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.durationMinutes,
    required this.difficultyLevel,
    required this.isActive,
    required this.isPremium,
    required this.categoryId,
    this.thumbnailUrl,
    required this.viewCount,
    required this.sortOrder,
    required this.createdAt,
    this.contentBlocks,
    this.videoUrl,
    this.audioUrl,
    this.pdfUrl,
    this.tags,
    this.relatedLessonIds,
    required this.completionCount,
    this.ratingAverage,
    required this.ratingCount,
  });

  factory TrainingLessonDetail.fromJson(Map<String, dynamic> json) {
    return TrainingLessonDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      difficultyLevel: json['difficulty_level'] as String,
      isActive: json['is_active'] as bool,
      isPremium: json['is_premium'] as bool,
      categoryId: json['category_id'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      viewCount: json['view_count'] as int,
      sortOrder: json['sort_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      contentBlocks: json['content_blocks'] != null
          ? (json['content_blocks'] as List)
              .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      videoUrl: json['video_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      tags: json['tags'] as String?,
      relatedLessonIds: json['related_lesson_ids'] != null
          ? List<String>.from(json['related_lesson_ids'] as List)
          : null,
      completionCount: json['completion_count'] as int,
      ratingAverage: json['rating_average'] != null
          ? (json['rating_average'] as num).toDouble()
          : null,
      ratingCount: json['rating_count'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'duration_minutes': durationMinutes,
      'difficulty_level': difficultyLevel,
      'is_active': isActive,
      'is_premium': isPremium,
      'category_id': categoryId,
      'thumbnail_url': thumbnailUrl,
      'view_count': viewCount,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'content_blocks': contentBlocks?.map((e) => e.toJson()).toList(),
      'video_url': videoUrl,
      'audio_url': audioUrl,
      'pdf_url': pdfUrl,
      'tags': tags,
      'related_lesson_ids': relatedLessonIds,
      'completion_count': completionCount,
      'rating_average': ratingAverage,
      'rating_count': ratingCount,
    };
  }
}

/// Content Block Model for lesson content
class ContentBlock extends BaseModel {
  final String type;
  final String? content;
  final String? url;
  final Map<String, dynamic>? metadata;

  const ContentBlock({
    required this.type,
    this.content,
    this.url,
    this.metadata,
  });

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      type: json['type'] as String,
      content: json['content'] as String?,
      url: json['url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'url': url,
      'metadata': metadata,
    };
  }
}
