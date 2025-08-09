import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'theme/app_theme.dart';
import 'widgets/lesson_tile.dart';
import 'widgets/ui_components.dart';
import 'theme/typography.dart';
import 'auth.dart';
import 'providers/progression_providers.dart';
import 'providers/lessons_providers.dart';
import 'analytics/analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class QuranApp extends ConsumerWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Quran Learning',
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateChangesProvider);
  final profile = ref.watch(userProfileProvider).value;
  // Derive level badge text (simple use of existing level field; could recompute from XP if needed)
  final progressView = ref.watch(userProgressViewProvider);
  final levelBadge = progressView == null ? null : 'Seviye ${progressView.level}';
    final lessonsAsync = ref.watch(lessonsStreamProvider);
    final analytics = const ConsoleAnalytics();
    return Scaffold(
      appBar: AppBar(title: Text(profile == null ? 'Lessons' : 'Merhaba ${profile.displayName}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth.value == null)
            AppButton.primary('Anonim Giriş', onPressed: () => ref.read(authControllerProvider).signInAnonymously()),
          if (auth.isLoading) const CircularProgressIndicator(),
          if (auth.value != null) ...[
          const Text('Bugünkü İlerleme', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
            const AppProgressBar(value: 0.42),
          const SizedBox(height: 24),
          if (levelBadge != null) Badge(label: levelBadge),
          const SizedBox(height: 16),
          lessonsAsync.when(
            data: (lessons) {
              if (lessons.isEmpty) {
                return const Text('Ders bulunamadı');
              }
              return Column(
                children: [
                  for (final l in lessons)
                    LessonTile(title: l.title, progress: 0),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Hata: $e'),
          ),
          const SizedBox(height: 24),
          AppButton.primary('Derse Başla', onPressed: () => analytics.log('lesson_started', params: {'id': 'demo'})),
          const SizedBox(height: 12),
          AppButton.ghost('Crash Test', onPressed: () => FirebaseCrashlytics.instance.crash()),
          ],
        ],
      ),
    );
  }
}
