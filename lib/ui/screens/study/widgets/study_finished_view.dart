import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/study_session_notifier.dart';

class StudyFinishedView extends StatelessWidget {
  final dynamic l10n;
  final StudySessionNotifier notifier;
  final int completedCount;

  const StudyFinishedView({
    super.key,
    required this.l10n,
    required this.notifier,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.x),
              onPressed: () => context.pop(),
            ),
          ],
          title: Text(
            l10n.studyCompleteTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.base.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: m.Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.checkCheck,
                  size: 64,
                  color: m.Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.studyCompleteTitle,
                style: theme.typography.h2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.studyCompleteDesc(completedCount),
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                alignment: Alignment.center,
                onPressed: () => context.pop(),
                child: Text(l10n.backToDecks),
              ),
              const SizedBox(height: 12),
              GhostButton(
                onPressed: () => notifier.restart(),
                child: Text(l10n.studyAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
