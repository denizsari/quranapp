class UserLessonProgress {
  final String id;
  final String userId;
  final String lessonId;
  final double progress; // 0-1
  final int lastUpdatedAt; // epoch ms
  const UserLessonProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.progress,
    required this.lastUpdatedAt,
  });

  factory UserLessonProgress.fromJson(Map<String, dynamic> json) =>
      UserLessonProgress(
        id: json['id'] as String,
        userId: json['userId'] as String,
        lessonId: json['lessonId'] as String,
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
        lastUpdatedAt: (json['lastUpdatedAt'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'lessonId': lessonId,
        'progress': progress,
        'lastUpdatedAt': lastUpdatedAt,
      };
}
