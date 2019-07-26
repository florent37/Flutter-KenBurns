import 'package:flutter/material.dart';

import 'KenburnsGenerator.dart';

class KenBurns extends StatefulWidget {
  final Widget child;

  final List<Widget> children;
  final Duration childrenFadeDuration;

  final Duration minAnimationDuration;
  final Duration maxAnimationDuration;
  final double maxScale;

  KenBurns({
    @required this.child,
    this.minAnimationDuration = const Duration(milliseconds: 3000),
    this.maxAnimationDuration = const Duration(milliseconds: 10000),
    this.maxScale = 8,
  })  : this.childrenFadeDuration = null,
        this.children = null,
        assert(minAnimationDuration != null &&
            minAnimationDuration.inMilliseconds > 0),
        assert(maxAnimationDuration != null &&
            maxAnimationDuration.inMilliseconds > 0),
        assert(minAnimationDuration < maxAnimationDuration),
        assert(maxScale > 1),
        assert(child != null);

  /*
  Kenburns.multiple({
    this.minAnimationDuration = const Duration(milliseconds: 1000),
    this.maxAnimationDuration = const Duration(milliseconds: 10000),
    this.maxScale = 10,
    this.children,
    this.childrenFadeDuration = const Duration(milliseconds: 500)
  }) : this.child = null;
  */

  @override
  _KenBurnsState createState() => _KenBurnsState();
}

class _KenBurnsState extends State<KenBurns> with TickerProviderStateMixin {
  bool _running = false;

  AnimationController _scaleController;
  Animation<double> _scaleAnim;

  AnimationController _translationController;
  Animation<double> _translationXAnim;
  Animation<double> _translationYAnim;

  double _currentScale = 1;
  double _currentTranslationX = 0;
  double _currentTranslationY = 0;

  bool _scaleDown = true;

  bool _displayLogs = true;

  KenburnsGenerator _kenburnsGenerator = KenburnsGenerator();

  Future<void> _createNextAnimations({double height, double width}) async {
    final KenBurnsGeneratorConfig nextConfig =
        _kenburnsGenerator.generateNextConfig(
            width: width,
            height: height,
            maxScale: widget.maxScale,
            lastScale: _currentScale,
            scaleDown: _scaleDown,
            minDurationMillis:
                widget.minAnimationDuration.inMilliseconds.toDouble(),
            maxDurationMillis:
                widget.maxAnimationDuration.inMilliseconds.toDouble(),
            lastTranslation:
                Offset(_currentTranslationX, _currentTranslationY));

    _scaleController?.dispose();
    _scaleController = AnimationController(
      duration: nextConfig.newDuration,
      vsync: this,
    );

    _scaleAnim =
        Tween(begin: this._currentScale, end: nextConfig.newScale).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.linear),
    )..addListener(() {
            setState(() {
              _currentScale = _scaleAnim.value;
            });
          });

    _translationController?.dispose();
    _translationController = AnimationController(
      duration: nextConfig.newDuration,
      vsync: this,
    );

    _translationXAnim = Tween(
            begin: this._currentTranslationX, end: nextConfig.newTranslation.dx)
        .animate(
      CurvedAnimation(parent: _translationController, curve: Curves.linear),
    )..addListener(() {
            setState(() {
              _currentTranslationX = _translationXAnim.value;
            });
          });
    _translationYAnim = Tween(
            begin: this._currentTranslationY, end: nextConfig.newTranslation.dy)
        .animate(
      CurvedAnimation(parent: _translationController, curve: Curves.linear),
    )..addListener(() {
            setState(() {
              _currentTranslationY = _translationYAnim.value;
            });
          });

    log("kenburns started");
    log("kenburns d(${nextConfig.newDuration}) translation(${nextConfig.newTranslation.dx}, ${nextConfig.newTranslation.dy}) scale(${nextConfig.newScale})");

    _scaleDown = !_scaleDown;

    await _scaleController.forward();
    await _translationController.forward();

    log("kenburns finished");
  }

  void log(String text) {
    if (_displayLogs) {
      print(text);
    }
  }

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
            scale: _currentScale,
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
