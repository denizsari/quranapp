import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_lesson_progress.freezed.dart';
part 'user_lesson_progress.g.dart';

@freezed
class UserLessonProgress with _$UserLessonProgress {
  const factory UserLessonProgress({
    required String id,
    required String userId,
    required String lessonId,
    required double progress, // 0-1
    required int lastUpdatedAt, // epoch ms
  }) = _UserLessonProgress;

  factory UserLessonProgress.fromJson(Map<String, dynamic> json) => _$UserLessonProgressFromJson(json);
}
