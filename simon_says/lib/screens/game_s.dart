import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/color_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  final List<int> _sequence = [];

  int _playerIndex = 0;
  int _activeButton = -1;
  int _score = 0;

  bool _showingSequence = true;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _sequence.clear();
    _sequence.add(_random.nextInt(4));
    _playerIndex = 0;
    _score = 0;
    _gameOver = false;

    _playSequence();
  }

  Future<void> _playSequence() async {
    setState(() {
      _showingSequence = true;
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
      _showingSequence = false;
    });
  }

  Future<void> _buttonPressed(int buttonIndex) async {
    if (_showingSequence || _gameOver) {
      return;
    }

    setState(() {
      _activeButton = buttonIndex;
    });

    await Future.delayed(const Duration(milliseconds: 150));

    if (!mounted) return;

    setState(() {
      _activeButton = -1;
    });

    if (buttonIndex != _sequence[_playerIndex]) {
      _endGame();
      return;
    }

    _playerIndex++;

    if (_playerIndex == _sequence.length) {
      setState(() {
        _score++;
        _playerIndex = 0;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      _sequence.add(_random.nextInt(4));
      _playSequence();
    }
  }

  void _endGame() {
    setState(() {
      _gameOver = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score was $_score.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startGame();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Main Menu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solo Game'), centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            final horizontalPadding = screenWidth < 400 ? 16.0 : 24.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _showingSequence
                          ? 'Watch the sequence'
                          : 'Repeat the sequence',
                      style: const TextStyle(fontSize: 17),
                    ),

                    const SizedBox(height: 20),

                    Center(
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
