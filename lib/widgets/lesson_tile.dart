import 'package:flutter/material.dart';

class LessonTile extends StatelessWidget {
  final String title;
  final double progress; // 0..1
  const LessonTile({super.key, required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: LinearProgressIndicator(value: progress.clamp(0, 1)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
