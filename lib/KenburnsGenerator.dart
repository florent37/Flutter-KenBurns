import 'dart:math';
import 'dart:ui';

/// The generated configuration of KenBurns (scale, translation, duration)
class KenBurnsGeneratorConfig {
  double newScale;
  Offset newTranslation;
  Duration newDuration;

  KenBurnsGeneratorConfig({
    required this.newScale,
    required this.newTranslation,
    required this.newDuration,
  });
}

/// The random scale, translation, duration generator
class KenburnsGenerator {
  Random _random = Random();

  KenburnsGenerator();

  /// Generates a positive random integer distributed on the range
  double _randomValue(double min, double max) =>
      min + _random.nextDouble() * (max - min);

  double generateNextScale(
      {double? lastScale, double? maxScale, required bool scaleDown}) {
    final double minScale = 1.0;
    if (scaleDown && minScale < lastScale!) {
      return _randomValue(minScale, lastScale);
    } else {
      return _randomValue(max(minScale, lastScale!), maxScale!);
    }
  }

  Duration generateNextDuration(
      {required double minDurationMillis, required double maxDurationMillis}) {
    return Duration(
        milliseconds:
            _randomValue(minDurationMillis, maxDurationMillis).floor());
  }

  Offset generateNextTranslation(
      {required double width,
      required double height,
      required Size nextSize,
      double? nextScale}) {
    final availableXOffset = ((nextSize.width - width) / 2);
    final availableYOffset = ((nextSize.height - height) / 2);

    final x = _randomValue(-1 * availableXOffset, availableXOffset);
    final y = _randomValue(-1 * availableYOffset, availableYOffset);
    return Offset(x, y);
  }

  KenBurnsGeneratorConfig generateNextConfig({
    required double width,
    required double height,
    double? maxScale,
    double? lastScale,
    required bool scaleDown,
    required double minDurationMillis,
    required double maxDurationMillis,
    Offset? lastTranslation,
  }) {
    Duration nextDuration;
    double nextScale;
    Offset nextTranslation;

    nextDuration = generateNextDuration(
      minDurationMillis: minDurationMillis,
      maxDurationMillis: maxDurationMillis,
    );

    nextScale = generateNextScale(
      lastScale: lastScale,
      maxScale: maxScale,
      scaleDown: scaleDown,
    );

    Size nextSize = Size(width * nextScale, height * nextScale);

    nextTranslation = generateNextTranslation(
      width: width,
      height: height,
      nextScale: nextScale,
      nextSize: nextSize,
    );

    return KenBurnsGeneratorConfig(
      newDuration: nextDuration,
      newTranslation: nextTranslation,
      newScale: nextScale,
    );
  }
}
