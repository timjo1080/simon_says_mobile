import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'leaderboard_screen.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key, required this.score});

  final int score;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  final _usernameController = TextEditingController();
  SharedPreferences? _preferences;
  List<HighScore> _highScores = [];
  bool _loadFailed = false;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadScores() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final scores = readHighScores(preferences);
      if (!mounted) return;
      setState(() {
        _preferences = preferences;
        _highScores = scores;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
    }
  }

  Future<void> _saveScore() async {
    final preferences = _preferences;
    final username = _usernameController.text;
    if (preferences == null ||
        _saving ||
        _saved ||
        !highScoreUsernamePattern.hasMatch(username)) {
      return;
    }

    setState(() => _saving = true);
    try {
      final topScores = [..._highScores];
      final nextLower = topScores.indexWhere(
        (entry) => entry.score < widget.score,
      );
      final rankIndex = nextLower == -1 ? topScores.length : nextLower;
      final qualifies = rankIndex < 10;
      if (qualifies) {
        topScores.insert(rankIndex, (username: username, score: widget.score));
        if (topScores.length > 10) topScores.removeLast();
      }
      final saved = await preferences.setStringList(
        highScoresStorageKey,
        topScores.map((entry) => '${entry.username}:${entry.score}').toList(),
      );
      if (!saved) throw StateError('Could not write high scores');
      if (!mounted) return;
      setState(() {
        _highScores = topScores;
        _saved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            qualifies ? 'Score saved!' : 'This score did not make the top 10.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your score. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text('Final Score', style: textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.score}',
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  HighScoresCard(
                    scores: _highScores,
                    loading: _preferences == null && !_loadFailed,
                    loadFailed: _loadFailed,
                  ),
                  if (!_saved && !_loadFailed) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _usernameController,
                      enabled: !_saving && _preferences != null,
                      maxLength: 3,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9]'),
                        ),
                        TextInputFormatter.withFunction((_, value) {
                          return value.copyWith(text: value.text.toUpperCase());
                        }),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Enter 3 characters',
                        hintText: 'ABC',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed:
                          _preferences != null &&
                              !_saving &&
                              highScoreUsernamePattern.hasMatch(
                                _usernameController.text,
                              )
                          ? _saveScore
                          : null,
                      child: Text(_saving ? 'Saving…' : 'SAVE SCORE'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Play Again'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text('Main Menu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
