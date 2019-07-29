import 'package:flutter/material.dart';

import 'KenburnsGenerator.dart';

/// KenBurns widget, please provide a `child` Widget,
/// Will animate the child, using random scale, translation & duration
class KenBurns extends StatefulWidget {
  final Widget child;

  /// minimum translation & scale duration, not null
  final Duration minAnimationDuration;

  /// maximum translation & scale duration, not null
  final Duration maxAnimationDuration;

  /// Maximum allowed child scale, > 1
  final double maxScale;

  //region multiple images
  /// If specified (using the constructor multiple)
  /// Will animate [childLoop] each children then will fade to the next child
  /// Not Null & Size must be > 1
  /// if size == 1 -> Will use the KenBurns as a single child
  final List<Widget> children;

  /// If specified (using the constructor multiple)
  /// Will specify the fade in duration between 2 child
  final Duration childrenFadeDuration;

  /// If specified (using the constructor multiple)
  /// Will determine thow many times each child will stay in the KenBurns
  /// Until the next child will be displayed
  final int childLoop;

  //endregion

  /// Constructor for a single child KenBurns
  KenBurns({
    @required this.child,
    this.minAnimationDuration = const Duration(milliseconds: 3000),
    this.maxAnimationDuration = const Duration(milliseconds: 10000),
    this.maxScale = 8,
  })  : this.childrenFadeDuration = null,
        this.children = null,
        this.childLoop = null,
        assert(minAnimationDuration != null &&
            minAnimationDuration.inMilliseconds > 0),
        assert(maxAnimationDuration != null &&
            maxAnimationDuration.inMilliseconds > 0),
        assert(minAnimationDuration < maxAnimationDuration),
        assert(maxScale > 1),
        assert(child != null);

  /// Constructor for multiple child KenBurns
  KenBurns.multiple(
      {this.minAnimationDuration = const Duration(milliseconds: 1000),
      this.maxAnimationDuration = const Duration(milliseconds: 10000),
      this.maxScale = 10,
      this.childLoop = 3,
      this.children,
      this.childrenFadeDuration = const Duration(milliseconds: 800)})
      : this.child = null;

  @override
  _KenBurnsState createState() => _KenBurnsState();
}

class _KenBurnsState extends State<KenBurns> with TickerProviderStateMixin {
  bool _running = false;

  /// The generated scale controller
  /// Will be destroyed / created at each loop (because duration is different)
  AnimationController _scaleController;

  /// The generated scale controller's animation
  /// Will be destroyed / created at each loop (because duration is different)
  Animation<double> _scaleAnim;

  /// The generated translation controller
  /// Will be destroyed / created at each loop (because duration is different)
  AnimationController _translationController;

  /// The generated translation controller's X animation
  /// Will be destroyed / created at each loop (because duration is different)
  Animation<double> _translationXAnim;

  /// The generated translation controller's Y animation
  /// Will be destroyed / created at each loop (because duration is different)
  Animation<double> _translationYAnim;

  /// The animated current scale
  double _currentScale = 1;

  /// The animated current translation X
  double _currentTranslationX = 0;

  /// The animated current translation Y
  double _currentTranslationY = 0;

  /// If true : next animation will scale down,
  /// false : next animation will scale up
  bool _scaleDown = true;

  /// For developpers : set to true to enable logs
  bool _displayLogs = true;

  /// The random [scale/duration/translation] generator
  KenburnsGenerator _kenburnsGenerator = KenburnsGenerator();

  //region multiple childs
  /// if true : the widget setup is multipleImages
  bool get displayMultipleImage =>
      widget.children != null && widget.children.length > 1;
  int nextChildIndex = -1;
  int currentChildIndex = 0;
  int currentChildLoop = 0;

  double _opacityCurrentChild = 1;
  double _opacityNextChild = 0;

  /// The generated fade controller
  AnimationController _fadeController;

  /// The generated opacity fade in controller's animation
  Animation<double> _fadeInAnim;

  /// The generated opacity fade out controller's animation
  Animation<double> _fadeOutAnim;

  //endregion

  /// Generate the fade (in & out) animations
  Future<void> _createFadeAnimations() async {
    _fadeController?.dispose();
    _fadeController = AnimationController(
      duration: widget.childrenFadeDuration,
      vsync: this,
    );
    _fadeInAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.linear),
    )..addListener(() {
        setState(() {
          _opacityNextChild = _fadeInAnim.value;
        });
      });
    _fadeOutAnim = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.linear),
    )..addListener(() {
        setState(() {
          _opacityCurrentChild = _fadeOutAnim.value;
        });
      });
  }

  /// Generate the next animation [scale, duration, translation]
  /// Using the [KenBurnsGenerator] generateNextConfig
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

    /// Recreate the scale animations
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

    /// Recreate the translations animations
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

    /// Next scale animation will be inverted
    _scaleDown = !_scaleDown;

    /// fire scale & translation animations
    await _scaleController.forward();
    await _translationController.forward();

    log("kenburns finished");
  }

  /// Display on debug logs (enable with [_displayLogs])
  void log(String text) {
    if (_displayLogs) {
      print(text);
    }
  }

  /// Fire the fade (in/out) animation
  Future<void> _fade() async {
    await _fadeController.forward();

    setState(() {
      currentChildIndex = nextChildIndex;

      nextChildIndex = currentChildIndex + 1;
      nextChildIndex = nextChildIndex % widget.children.length;
    });

    _fadeController.reset();
  }

  Future<void> fire({double height, double width}) async {
    _running = true;
    if (displayMultipleImage) {
      nextChildIndex = 1;

      /// Create one time the fade animation
      await _createFadeAnimations();

      /// Cancel if _running go to false
      while (_running) {
        if (currentChildLoop % widget.childLoop == 0) {
          _fade(); //parallel
        }
        await _createNextAnimations(width: width, height: height);
        currentChildLoop++;
      }
    } else {
      /// Cancel if _running go to false
      while (_running) {
        await _createNextAnimations(width: width, height: height);
      }
    }
  }

  @override
  void initState() {
    /// Reset _runnint state
    _running = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Layout builder to provide constrains height/width
    return LayoutBuilder(builder: (context, constraints) {
      /// create the animation only if we have a size (not possible in initState())
      if (!_running) {
        fire(height: constraints.maxHeight, width: constraints.maxWidth);
      }
      return ClipRect(
        ///Clip because we scale up children, if not clipped : child can take all the screen
        /// Apply the current animated translation
        child: Transform.translate(
          offset: Offset(_currentTranslationX, _currentTranslationY),

          /// Apply the current animated scale
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
      /// If the [currentChildIndex] changed (different than [lastChildIndex])
      /// -> we animate to display the next child
      /// We use the stack to keep the same structure as multiple/single child
      return Stack(fit: StackFit.expand, children: <Widget>[
        Opacity(
            opacity: _opacityCurrentChild,
            child: widget.children[currentChildIndex]),
        Opacity(
            opacity: _opacityNextChild, child: widget.children[nextChildIndex]),
      ]);
    } else {
      /// If we have only 1 child
      /// We use the stack to keep the same structure as multiple/single child
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
    /// will stop the [fire()] loop
    _running = false;
    _scaleController?.dispose();
    _translationController?.dispose();
    super.dispose();
  }
}
