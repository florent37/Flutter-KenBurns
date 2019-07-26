import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

class KenburnsGeneratorConfig {
  double newScale;
  Offset newTranslation;
  Duration newDuration;

  KenburnsGeneratorConfig({
    @required this.newScale,
    @required this.newTranslation,
    @required this.newDuration,
  });
}

class KenburnsGenerator {
  Random _random = Random();

  KenburnsGenerator();

  /**
   * Generates a positive random integer distributed on the range
   */
  double _randomValue(double min, double max) => min + _random.nextDouble() * (max - min);

  double generateNextScale({double lastScale, double maxScale, bool scaleDown}) {
    final double minScale = 1.0;
    if (scaleDown && minScale < lastScale) {
      return _randomValue(minScale, lastScale);
    } else {
      return _randomValue(max(minScale, lastScale), maxScale);
    }
  }

  Duration generateNextDuration({double minDurationMillis, double maxDurationMillis}) {
    return Duration(milliseconds: _randomValue(minDurationMillis, maxDurationMillis).floor());
  }

  Offset generateNextTranslation({double width, double height, Size nextSize, double nextScale}) {
    double minX = -1 * (nextSize.width / 2 - width) / nextScale;
    double maxX = 1;
    double minY = -1 * (nextSize.height / 2 - height) / nextScale;
    double maxY = 1;

    final x = _randomValue(minX, maxX);
    final y = _randomValue(minY, maxY);
    return Offset(x, y);
  }

  KenburnsGeneratorConfig generateNextConfig({
    double width,
    double height,
    double maxScale,
    double lastScale,
    bool scaleDown,
    double minDurationMillis,
    double maxDurationMillis,
    Offset lastTranslation,
  }) {

    Duration nextDuration;
    double nextScale;
    Offset nextTranslation;

    do {
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
    } while ((nextTranslation.dy - lastTranslation.dy).abs() < height * 0.1 && (nextTranslation.dx - lastTranslation.dx).abs() < width * 0.1);

    return KenburnsGeneratorConfig(
      newDuration: nextDuration,
      newTranslation: nextTranslation,
      newScale: nextScale,
    );
  }
}
