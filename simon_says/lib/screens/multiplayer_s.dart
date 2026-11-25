import 'package:flutter/material.dart';

import '../widgets/color_button.dart';
import 'game_over_screen.dart';

enum MultiplayerPhase {
  handoff,
  showingSequence,
  repeatingSequence,
  addingButton,
  gameOver,
}

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  final List<int> _sequence = [];

  MultiplayerPhase _phase = MultiplayerPhase.handoff;

  int _currentPlayer = 1;
  int _playerSequenceIndex = 0;
  int _activeButton = -1;
  int _round = 0;

  bool _isAnimating = false;

  Future<void> _startTurn() async {
    if (_isAnimating || _phase != MultiplayerPhase.handoff) {
      return;
    }

    if (_sequence.isEmpty) {
      setState(() {
        _phase = MultiplayerPhase.addingButton;
      });
      return;
    }

    await _showSequence();
  }

  Future<void> _showSequence() async {
    setState(() {
      _phase = MultiplayerPhase.showingSequence;
      _playerSequenceIndex = 0;
    });

    for (final buttonIndex in _sequence) {
      if (!mounted) return;

      setState(() {
        _activeButton = buttonIndex;
      });

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      setState(() {
        _activeButton = -1;
      });

      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted) return;

    setState(() {
      _phase = MultiplayerPhase.repeatingSequence;
    });
  }

  Future<void> _buttonPressed(int buttonIndex) async {
    if (_isAnimating) {
      return;
    }

    if (_phase == MultiplayerPhase.addingButton) {
      await _addButton(buttonIndex);
      return;
    }

    if (_phase != MultiplayerPhase.repeatingSequence) {
      return;
    }

    _isAnimating = true;

    setState(() {
      _activeButton = buttonIndex;
    });

    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;

    setState(() {
      _activeButton = -1;
    });

    if (buttonIndex != _sequence[_playerSequenceIndex]) {
      _isAnimating = false;
      _endGame();
      return;
    }

    _playerSequenceIndex++;
    _isAnimating = false;

    if (_playerSequenceIndex == _sequence.length) {
      setState(() {
        _round++;
        _phase = MultiplayerPhase.addingButton;
      });
    }
  }

  Future<void> _addButton(int buttonIndex) async {
    _isAnimating = true;

    setState(() {
      _activeButton = buttonIndex;
    });

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      _activeButton = -1;
      _sequence.add(buttonIndex);
      _currentPlayer = _currentPlayer == 2 ? 1 : 2;
      _phase = MultiplayerPhase.handoff;
    });

    _isAnimating = false;
  }

  Future<void> _endGame() async {
    setState(() {
      _phase = MultiplayerPhase.gameOver;
    });

    final playAgain = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => PopScope(
          canPop: false,
          child: GameOverScreen(score: _round, multiplayer: true),
        ),
      ),
    );

    if (mounted && playAgain == true) {
      _restartGame();
    }
  }

  void _restartGame() {
    setState(() {
      _sequence.clear();
      _phase = MultiplayerPhase.handoff;
      _currentPlayer = 1;
      _playerSequenceIndex = 0;
      _activeButton = -1;
      _round = 0;
    });
  }

  String _instructionText() {
    switch (_phase) {
      case MultiplayerPhase.handoff:
        return 'Pass the device to Player $_currentPlayer';

      case MultiplayerPhase.showingSequence:
        return 'Watch the sequence';

      case MultiplayerPhase.repeatingSequence:
        return 'Player $_currentPlayer, repeat the sequence';

      case MultiplayerPhase.addingButton:
        return 'Player $_currentPlayer, add one button';

      case MultiplayerPhase.gameOver:
        return 'Game over';
    }
  }

  String _buttonText() {
    if (_sequence.isEmpty) {
      return 'Start Game';
    }

    return 'Start Turn';
  }

  @override
  Widget build(BuildContext context) {
    final canStart = _phase == MultiplayerPhase.handoff;

    return Scaffold(
      appBar: AppBar(title: const Text('Multiplayer'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Round: $_round',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _instructionText(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 20),

              if (canStart)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startTurn,
                    child: Text(_buttonText()),
                  ),
                ),

              const SizedBox(height: 20),

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 360,
                      maxHeight: 360,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: List.generate(4, (index) {
                          return ColorButton(
                            color: _colors[index],
                            isLit: _activeButton == index,
                            onPressed: () => _buttonPressed(index),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
