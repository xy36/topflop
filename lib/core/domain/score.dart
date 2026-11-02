import '../../l10n/app_localizations.dart';

/// Bewertungsskala 1–10 mit Emoji und Wort.
abstract final class Score {
  static const min = 1;
  static const max = 10;

  static const _emojis = ['🤮', '🤢', '😖', '🙁', '😕', '😐', '🙂', '😊', '😋', '🤩'];

  static String emoji(int score) => _emojis[score.clamp(min, max) - 1];

  static String word(AppLocalizations l10n, int score) => switch (score.clamp(min, max)) {
        1 => l10n.score1,
        2 => l10n.score2,
        3 => l10n.score3,
        4 => l10n.score4,
        5 => l10n.score5,
        6 => l10n.score6,
        7 => l10n.score7,
        8 => l10n.score8,
        9 => l10n.score9,
        _ => l10n.score10,
      };
}
