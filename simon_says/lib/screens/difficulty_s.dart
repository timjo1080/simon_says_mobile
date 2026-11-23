import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import 'game_s.dart';

class DifficultyScreen extends StatefulWidget {
  const DifficultyScreen({super.key});

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  String _selectedDifficulty = 'Normal';

  Duration _sequenceDelay = const Duration(milliseconds: 600);
  int _inputTimeLimit = 10;
  int _basePoints = 2;

  bool _showOnlyNext = false;
  bool _removeColors = false;
  bool _removeSounds = false;

  void _selectDifficulty(
    String difficulty,
    Duration sequenceDelay,
    int inputTimeLimit,
    int basePoints,
  ) {
    setState(() {
      _selectedDifficulty = difficulty;
      _sequenceDelay = sequenceDelay;
      _inputTimeLimit = inputTimeLimit;
      _basePoints = basePoints;
    });
  }

  void _startGame() {
    final settings = GameSettings(
      sequenceDelay: _sequenceDelay,
      inputTimeLimit: _inputTimeLimit,
      basePoints: _basePoints,
      showOnlyNext: _showOnlyNext,
      removeColors: _removeColors,
      removeSounds: _removeSounds,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(settings: settings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Setup'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choose Difficulty',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  _difficultyButton(
                    name: 'Easy',
                    description: '15 seconds • 1 point per cycle',
                    delay: const Duration(milliseconds: 800),
                    inputTime: 15,
                    points: 1,
                  ),

                  _difficultyButton(
                    name: 'Normal',
                    description: '10 seconds • 2 points per cycle',
                    delay: const Duration(milliseconds: 600),
                    inputTime: 10,
                    points: 2,
                  ),

                  _difficultyButton(
                    name: 'Hard',
                    description: '5 seconds • 3 points per cycle',
                    delay: const Duration(milliseconds: 400),
                    inputTime: 5,
                    points: 3,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Difficulty Modifiers',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _showOnlyNext,
                          onChanged: (value) {
                            setState(() {
                              _showOnlyNext = value;
                            });
                          },
                          title: const Text('Show only next button'),
                          subtitle: const Text('+1 point per cycle'),
                        ),

                        SwitchListTile(
                          value: _removeColors,
                          onChanged: (value) {
                            setState(() {
                              _removeColors = value;
                            });
                          },
                          title: const Text('Remove button colors'),
                          subtitle: const Text('+1 point per cycle'),
                        ),

                        SwitchListTile(
                          value: _removeSounds,
                          onChanged: (value) {
                            setState(() {
                              _removeSounds = value;
                            });
                          },
                          title: const Text('Remove button sounds'),
                          subtitle: const Text('+1 point per cycle'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Points per cycle: '
                    '${_basePoints + (_showOnlyNext ? 1 : 0) + (_removeColors ? 1 : 0) + (_removeSounds ? 1 : 0)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _difficultyButton({
    required String name,
    required String description,
    required Duration delay,
    required int inputTime,
    required int points,
  }) {
    final isSelected = _selectedDifficulty == name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          _selectDifficulty(name, delay, inputTime, points);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.inversePrimary
              : null,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Text(description),
          ],
        ),
      ),
    );
  }
}
