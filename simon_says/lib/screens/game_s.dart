import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:audioplayers/audioplayers.dart';

import '../widgets/color_button.dart';
import '../models/game_settings.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final GameSettings settings;

  const GameScreen({super.key, required this.settings});

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

  //final AudioPlayer _audioPlayer = AudioPlayer();

  final List<String> _soundPaths = [
    'sounds/red.wav',
    'sounds/blue.wav',
    'sounds/green.wav',
    'sounds/yellow.wav',
  ];

  int _playerIndex = 0;
  int _activeButton = -1;
  int _score = 0;

  bool _showingSequence = true;
  bool _gameOver = false;

  Timer? _inputTimer;
  int _remainingSeconds = 0;

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

    final sequenceToShow = widget.settings.showOnlyNext
        ? [_sequence.last]
        : _sequence;

    for (final buttonIndex in sequenceToShow) {
      if (!mounted) return;

      setState(() {
        _activeButton = buttonIndex;
      });

      //_playButtonSound(buttonIndex);

      await Future.delayed(widget.settings.sequenceDelay);

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

    _startInputTimer();
  }

  Future<void> _buttonPressed(int buttonIndex) async {
    _inputTimer?.cancel();

    if (_showingSequence || _gameOver) {
      return;
    }

    if (_playerIndex == _sequence.length) {
      setState(() {
        _score += widget.settings.pointsPerCycle;
        _playerIndex = 0;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      _sequence.add(_random.nextInt(4));
      _playSequence();
    } else {
      _startInputTimer();
    }

    setState(() {
      _activeButton = buttonIndex;
    });

    //_playButtonSound(buttonIndex);

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
        _score += widget.settings.pointsPerCycle;
        _playerIndex = 0;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      _sequence.add(_random.nextInt(4));
      _playSequence();
    }
  }

  Future<void> _endGame() async {
    if (!mounted || _gameOver) return;

    _inputTimer?.cancel();

    setState(() {
      _gameOver = true;
    });

    final playAgain = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => GameOverScreen(score: _score),
      ),
    );

    if (mounted && playAgain == true) {
      _startGame();
    }
  }

  void _startInputTimer() {
    _inputTimer?.cancel();

    setState(() {
      _remainingSeconds = widget.settings.inputTimeLimit;
    });

    _inputTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        _endGame();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _inputTimer?.cancel();
    //_timerController.dispose();
    //_audioPlayer.dispose();
    super.dispose();
  }

  /*
  void _playButtonSound(int buttonIndex) {
    if (widget.settings.removeSounds) {
      return;
    }

    _audioPlayer.stop();
    _audioPlayer.play(AssetSource(_soundPaths[buttonIndex]));
  }
  */

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
                                color: widget.settings.removeColors
                                    ? Colors.white
                                    : _colors[index],
                                isLit: _activeButton == index,
                                onPressed: () => _buttonPressed(index),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (!_showingSequence && !_gameOver) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer),
                          const SizedBox(width: 6),
                          Text(
                            '$_remainingSeconds seconds',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Time Bar
                      SizedBox(
                        width: double.infinity,
                        child: LinearProgressIndicator(
                          value:
                              _remainingSeconds /
                              widget.settings.inputTimeLimit,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: Colors.grey.shade700,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _remainingSeconds <= 3
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
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
