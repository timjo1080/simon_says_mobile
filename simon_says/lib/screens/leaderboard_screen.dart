import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef HighScore = ({String username, int score});

const highScoresStorageKey = 'simon_says.high_scores';
final highScoreUsernamePattern = RegExp(r'^[A-Z0-9]{3}$');

List<HighScore> readHighScores(SharedPreferences preferences) {
  final scores = <HighScore>[];
  for (final entry in preferences.getStringList(highScoresStorageKey) ?? []) {
    final parts = entry.split(':');
    if (parts.length != 2 || !highScoreUsernamePattern.hasMatch(parts.first)) {
      continue;
    }
    final score = int.tryParse(parts.last);
    if (score != null) scores.add((username: parts.first, score: score));
  }
  scores.sort((a, b) => b.score.compareTo(a.score));
  return scores.take(10).toList();
}

class HighScoresCard extends StatelessWidget {
  const HighScoresCard({
    super.key,
    required this.scores,
    this.loading = false,
    this.loadFailed = false,
  });

  final List<HighScore> scores;
  final bool loading;
  final bool loadFailed;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.amber),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                const Icon(Icons.emoji_events, size: 20, color: Colors.amber),
                Text('HIGH SCORES', style: titleStyle),
              ],
            ),
            const SizedBox(height: 8),
            if (loadFailed)
              const Text(
                'Could not load high scores.',
                textAlign: TextAlign.center,
              )
            else if (loading)
              const Text('Loading high scores...', textAlign: TextAlign.center)
            else if (scores.isEmpty)
              const Text('No high scores yet!', textAlign: TextAlign.center)
            else
              for (final (index, entry) in scores.take(5).indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text('${index + 1}.  ${entry.username}')),
                      Expanded(
                        child: Text('${entry.score}', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final _scores = SharedPreferences.getInstance().then(readHighScores);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: FutureBuilder<List<HighScore>>(
                future: _scores,
                builder: (context, snapshot) => HighScoresCard(
                  scores: snapshot.data ?? const [],
                  loading: snapshot.connectionState != ConnectionState.done,
                  loadFailed: snapshot.hasError,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
