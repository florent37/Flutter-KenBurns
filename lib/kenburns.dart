import 'dart:math';

import 'package:flutter/material.dart';

class Kenburns extends StatefulWidget {
  final Widget child;

  final Duration minAnimationDuration;
  final Duration maxAnimationDuration;
  final double maxScale;

  Kenburns({
    this.child,
    this.minAnimationDuration = const Duration(milliseconds: 1000),
    this.maxAnimationDuration = const Duration(milliseconds: 10000),
    this.maxScale = 10,
  });

  @override
  _KenburnsState createState() => _KenburnsState();
}

class _KenburnsState extends State<Kenburns> with TickerProviderStateMixin {
  AnimationController _scaleController;
  Animation<double> _scaleAnim;

  AnimationController _translationController;
  Animation<double> _translationXAnim;
  Animation<double> _translationYAnim;

  double _currentScale = 1;
  double _currentTranslationX = 0;
  double _currentTranslationY = 0;

  bool _scaleDown = true;

  Random _random = Random();

  bool _displayLogs = false;

  /**
   * Generates a positive random integer uniformly distributed on the range
   * from [min], inclusive, to [max], exclusive.
   */
  double _randomValue(double min, double max) => min + _random.nextInt((max - min).round());

  double _generateNextScale({double lastScale, bool scaleDown}) {
    final double minScale = 1.0;
    final double maxScale = widget.maxScale;
    if (scaleDown && minScale < lastScale) {
      return _randomValue(minScale, lastScale);
    } else {
      return _randomValue(lastScale, maxScale);
    }
  }

  Duration _generateNextDuration() {
    return Duration(milliseconds: _randomValue(widget.minAnimationDuration.inMilliseconds.toDouble(), widget.maxAnimationDuration.inMilliseconds.toDouble()).floor());
  }

  Offset _generateNextTranslation({double width, double height}) {
    final x = _randomValue(-0.9 * width, 0.9 * width);
    final y = _randomValue(-0.9 * height, 0.9 * height);
    return Offset(x, y);
  }

  Future<void> _createNextAnimations({double height, double width}) async {
    final Duration duration = _generateNextDuration();

    _scaleController?.dispose();
    _scaleController = AnimationController(
      duration: duration,
      vsync: this,
    );

    final newScale = _generateNextScale(lastScale: _currentScale, scaleDown: _scaleDown);

    _scaleAnim = Tween(begin: this._currentScale, end: newScale).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.linear),
    )..addListener(() {
        setState(() {
          _currentScale = _scaleAnim.value;
        });
      });

    _translationController?.dispose();
    _translationController = AnimationController(
      duration: duration,
      vsync: this,
    );

    final Offset translation = _generateNextTranslation(width: width, height: height);

    _translationXAnim = Tween(begin: this._currentTranslationX, end: translation.dx).animate(
      CurvedAnimation(parent: _translationController, curve: Curves.linear),
    )..addListener(() {
        setState(() {
          _currentTranslationX = _translationXAnim.value;
        });
      });
    _translationYAnim = Tween(begin: this._currentTranslationY, end: translation.dy).animate(
      CurvedAnimation(parent: _translationController, curve: Curves.linear),
    )..addListener(() {
        setState(() {
          _currentTranslationY = _translationYAnim.value;
        });
      });

    log("kenburns started");
    log("kenburns d($duration) translation(${translation.dx}, ${translation.dy}) scale($newScale)");

    _scaleDown = !_scaleDown;

    await _scaleController.forward();
    await _translationController.forward();

    log("kenburns finished");
  }

  void log(String text){
    if(_displayLogs){
      print(text);
    }
  }

  bool _running = false;

  void fire({double height, double width}) async {
    _running = true;
    while (_running) {
      await _createNextAnimations(width: width, height: height);
    }
  }

  @override
  void initState() {
    _running = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (!_running) {
        fire(height: constraints.maxHeight, width: constraints.maxWidth);
      }
      return ClipRect(
        child: Transform.translate(
          offset: Offset(_currentTranslationX, _currentTranslationY),
          child: Transform.scale(
            scale: 1 + _currentScale,
            child: widget.child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _running = false;
    _scaleController.dispose();
    _translationController.dispose();
    super.dispose();
  }
}
