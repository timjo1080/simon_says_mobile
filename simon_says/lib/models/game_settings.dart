class GameSettings {
  final Duration sequenceDelay;
  final int inputTimeLimit;
  final int basePoints;

  final bool showOnlyNext;
  final bool removeColors;
  final bool removeSounds;

  const GameSettings({
    required this.sequenceDelay,
    required this.inputTimeLimit,
    required this.basePoints,
    required this.showOnlyNext,
    required this.removeColors,
    required this.removeSounds,
  });

  int get activeModifierCount {
    int count = 0;

    if (showOnlyNext) count++;
    if (removeColors) count++;
    if (removeSounds) count++;

    return count;
  }

  int get pointsPerCycle {
    return basePoints + activeModifierCount;
  }
}
