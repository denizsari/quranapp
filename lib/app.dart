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
import 'providers/user_progress_write_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:typed_data';
import 'feature_flags.dart';

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
    final levelBadge =
        progressView == null ? null : 'Seviye ${progressView.level}';
    final streakBadge =
        progressView == null ? null : 'Günlük Seri ${profile?.streak ?? 0}';
    final flagsAsync = ref.watch(featureFlagsProvider);
    final lessonsAsync = ref.watch(lessonsStreamProvider);
    final analytics = const ConsoleAnalytics();
    final progressWriter = ref.watch(progressWriteControllerProvider);
    return Scaffold(
      appBar: AppBar(
          title: Text(
              profile == null ? 'Lessons' : 'Merhaba ${profile.displayName}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth.value == null)
            AppButton.primary('Anonim Giriş',
                onPressed: () =>
                    ref.read(authControllerProvider).signInAnonymously()),
          if (auth.isLoading) const CircularProgressIndicator(),
          if (auth.value != null) ...[
            const Text('Bugünkü İlerleme', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            const AppProgressBar(value: 0.42),
            const SizedBox(height: 24),
            Row(children: [
              if (levelBadge != null) AppBadge(label: levelBadge),
              if (streakBadge != null) ...[
                const SizedBox(width: 8),
                AppBadge(label: streakBadge, color: Colors.orange),
              ]
            ]),
            const SizedBox(height: 8),
            flagsAsync.when(
              data: (f) => Row(children: [
                if (f.aiPronunciationEnabled)
                  const AppBadge(label: 'AI Pron.', color: Colors.purple),
              ]),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            lessonsAsync.when(
              data: (lessons) {
                if (lessons.isEmpty) {
                  return const Text('Ders bulunamadı');
                }
                return Column(
                  children: [
                    for (final l in lessons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: LessonTile(title: l.title, progress: 0)),
                            const SizedBox(width: 8),
                            AppButton.ghost('Başla',
                                onPressed: () =>
                                    progressWriter.startLesson(l.id)),
                            const SizedBox(width: 4),
                            AppButton.primary('Bitir',
                                onPressed: () =>
                                    progressWriter.completeLesson(l.id)),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Hata: $e'),
            ),
            const SizedBox(height: 24),
            AppButton.primary('Derse Başla',
                onPressed: () =>
                    analytics.log('lesson_started', params: {'id': 'demo'})),
            const SizedBox(height: 12),
            AppButton.ghost('Kayıt Yükle (stub)', onPressed: () async {
              final bytes =
                  Uint8List.fromList(List<int>.generate(128, (i) => i % 256));
              await ref
                  .read(recordingUploadServiceProvider)
                  .uploadLessonRecording(lessonId: 'demo', data: bytes);
            }),
            const SizedBox(height: 12),
            AppButton.ghost('Crash Test',
                onPressed: () => FirebaseCrashlytics.instance.crash()),
          ],
        ],
      ),
    );
  }
}
