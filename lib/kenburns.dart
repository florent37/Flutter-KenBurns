import 'dart:math';

import 'package:flutter/material.dart';

import 'KenburnsGenerator.dart';

class KenBurns extends StatefulWidget {
  final Widget child;

  final Duration minAnimationDuration;
  final Duration maxAnimationDuration;
  final double maxScale;

  //multiple images
  final List<Widget> children;
  final Duration childrenFadeDuration;
  final int childLoop;

  KenBurns({
    @required this.child,
    this.minAnimationDuration = const Duration(milliseconds: 3000),
    this.maxAnimationDuration = const Duration(milliseconds: 10000),
    this.maxScale = 8,
  })  : this.childrenFadeDuration = null,
        this.children = null,
        this.childLoop = null,
        assert(minAnimationDuration != null && minAnimationDuration.inMilliseconds > 0),
        assert(maxAnimationDuration != null && maxAnimationDuration.inMilliseconds > 0),
        assert(minAnimationDuration < maxAnimationDuration),
        assert(maxScale > 1),
        assert(child != null);

  KenBurns.multiple(
      {this.minAnimationDuration = const Duration(milliseconds: 1000),
      this.maxAnimationDuration = const Duration(milliseconds: 10000),
      this.maxScale = 10,
      this.childLoop = 3,
      this.children,
      this.childrenFadeDuration = const Duration(milliseconds: 500)})
      : this.child = null;

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

  //region multiple childs
  bool get displayMultipleImage => widget.children != null;
  int lastChildIndex = 0;
  int currentChildIndex = 0;
  int currentChildLoop = 0;

  AnimationController _fadeController;
  Animation<double> _fadeInAnim;
  Animation<double> _fadeOutAnim;

  Future<void> _createFadeAnimations() async {
    _fadeController?.dispose();
    _fadeController = AnimationController(
      duration: widget.childrenFadeDuration,
      vsync: this,
    );
    _fadeInAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.linear),
    )..addListener(() {
        setState(() {});
      });
    _fadeOutAnim = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.linear),
    )..addListener(() {
        setState(() {});
      });
  }

  Future<void> _createNextAnimations({double height, double width}) async {
    final KenBurnsGeneratorConfig nextConfig = _kenburnsGenerator.generateNextConfig(
        width: width,
        height: height,
        maxScale: widget.maxScale,
        lastScale: _currentScale,
        scaleDown: _scaleDown,
        minDurationMillis: widget.minAnimationDuration.inMilliseconds.toDouble(),
        maxDurationMillis: widget.maxAnimationDuration.inMilliseconds.toDouble(),
        lastTranslation: Offset(_currentTranslationX, _currentTranslationY));

    _scaleController?.dispose();
    _scaleController = AnimationController(
      duration: nextConfig.newDuration,
      vsync: this,
    );

    _scaleAnim = Tween(begin: this._currentScale, end: nextConfig.newScale).animate(
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

    _translationXAnim = Tween(begin: this._currentTranslationX, end: nextConfig.newTranslation.dx).animate(
      CurvedAnimation(parent: _translationController, curve: Curves.linear),
    )..addListener(() {
        setState(() {
          _currentTranslationX = _translationXAnim.value;
        });
      });
    _translationYAnim = Tween(begin: this._currentTranslationY, end: nextConfig.newTranslation.dy).animate(
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

  Future<void> _fade() async {
    await _fadeController.forward();
    setState(() {
      lastChildIndex = currentChildIndex;
      currentChildIndex++;
      if(currentChildIndex > widget.children.length - 1){
        currentChildIndex = 0;
      }
    });
    _fadeController.reset();
  }

  Future<void> fire({double height, double width}) async {
    _running = true;
    if (displayMultipleImage) {
      await _createFadeAnimations();
      while (_running) {
        if (currentChildLoop == widget.childLoop) {
          _fade(); //parallel
          currentChildLoop = 0;
        }
        await _createNextAnimations(width: width, height: height);
        currentChildLoop++;
      }
    } else {
      while (_running) {
        await _createNextAnimations(width: width, height: height);
      }
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
            child: _buildChild(),
          ),
        ),
      );
    });
  }

  Widget _buildChild() {
    if (displayMultipleImage) {
      if (lastChildIndex != currentChildIndex) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Opacity(
                opacity: _fadeInAnim.value,
                child: widget.children[currentChildIndex]),
            Opacity(
                opacity: _fadeOutAnim.value,
                child: widget.children[lastChildIndex]),
          ],
        );
      } else {
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.children[currentChildIndex],
          ],
        );
      }
    } else {
      return Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
        ],
      );
    }
  }

  @override
  void dispose() {
    _running = false;
    _scaleController.dispose();
    _translationController.dispose();
    super.dispose();
  }
}
