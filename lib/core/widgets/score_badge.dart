import 'package:flutter/material.dart';

import '../domain/score.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Emoji + Zahl, Hintergrund abhängig von der Bewertung.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score, this.vertical = false});

  final int score;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final emoji = Text(Score.emoji(score), style: TextStyle(fontSize: vertical ? 18 : 18, height: 1));
    final number = Text('$score', style: AppText.display(vertical ? 14 : 17));
    return Semantics(
      label: '$score / 10',
      excludeSemantics: true,
      child: Container(
        constraints: BoxConstraints(minWidth: vertical ? 48 : 54, minHeight: vertical ? 48 : 34),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.scoreBackground(score),
          borderRadius: BorderRadius.circular(vertical ? 14 : 12),
        ),
        child: vertical
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [emoji, number],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [emoji, const SizedBox(width: 4), number],
              ),
      ),
    );
  }
}
