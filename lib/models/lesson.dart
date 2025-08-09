class Lesson {
  final String id;
  final String title;
  final double order;
  final bool active;
  const Lesson({
    required this.id,
    required this.title,
    required this.order,
    this.active = true,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        order: (json['order'] as num?)?.toDouble() ?? 0,
        active: json['active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'order': order,
        'active': active,
      };
}
