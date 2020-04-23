import 'package:flutter/widgets.dart';

/// The direction in which an animation is running.
enum AnimationDirection {
  /// The animation is running from beginning to end.
  forward,

  /// The animation is running backwards, from end to beginning.
  reverse,
}

// Inner display details & controls
class FadeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final AnimationDirection direction;
  final Curve curve;

  const FadeWidget(
      {@required this.child,
        this.duration = const Duration(milliseconds: 800),
        this.direction = AnimationDirection.forward,
        this.curve = Curves.easeOut,
        Key key})
      : assert(duration != null),
        assert(curve != null),
        assert(child != null),
        super(key: key);

  @override
  _FadeWidgetState createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<FadeWidget>
    with SingleTickerProviderStateMixin {
  Animation<double> opacity;
  AnimationController controller;
  bool hideWidget;

  @override
  Widget build(BuildContext context) {
    if (hideWidget) {
      return SizedBox();
    }

    return FadeTransition(
      opacity: opacity,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);
    final curved = CurvedAnimation(parent: controller, curve: widget.curve);
    var begin = widget.direction == AnimationDirection.forward ? 0.0 : 1.0;
    var end = widget.direction == AnimationDirection.forward ? 1.0 : 0.0;
    opacity = Tween<double>(begin: begin, end: end).animate(curved);
    controller.forward();

    hideWidget = false;
    if (widget.direction == AnimationDirection.reverse) {
      opacity.addStatusListener(animationStatusChange);
    }
  }

  @override
  void dispose() {
    if (widget.direction == AnimationDirection.reverse) {
      opacity.removeStatusListener(animationStatusChange);
    }
    controller.dispose();
    super.dispose();
  }

  void animationStatusChange(AnimationStatus status) {
    setState(() {
      hideWidget = widget.direction == AnimationDirection.reverse &&
          status == AnimationStatus.completed;
    });
  }
}
