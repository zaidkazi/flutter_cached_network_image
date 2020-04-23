import 'package:flutter/widgets.dart';

import 'error_widget.dart';
import 'fade_widget.dart';
import 'progress_widget.dart';

enum PlaceholderType {
  static,
  progress,
}

class BetaImageWidget extends StatefulWidget {
  final ImageProvider image;
  final PlaceholderType placeholderType;
  const BetaImageWidget({
    Key key,
    this.image,
    this.placeholderType = PlaceholderType.static,
  }) : super(key: key);

  @override
  _BetaImageWidgetState createState() => _BetaImageWidgetState();
}

class _BetaImageWidgetState extends State<BetaImageWidget> {
  bool _wasSynchronouslyLoaded = false;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.image,
      loadingBuilder: widget.placeholderType == PlaceholderType.progress
          ? _loadingBuilder
          : null,
      frameBuilder: widget.placeholderType == PlaceholderType.static
          ? _frameBuilder
          : _preLoadingBuilder,
      errorBuilder: _errorBuilder,
    );
  }

  Widget _stack(Widget first, Widget second) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        FadeWidget(
          child: first,
        ),
        FadeWidget(
          child: second,
          direction: AnimationDirection.reverse,
        )
      ],
    );
  }

  Widget _frameBuilder(BuildContext context, Widget child, int frame,
      bool wasSynchronouslyLoaded) {
    if (frame == null) {
      return const Placeholder();
    }
    if (wasSynchronouslyLoaded) {
      return child;
    }
    return _stack(
      child,
      const Placeholder(),
    );
  }

  Widget _preLoadingBuilder(BuildContext context, Widget child, int frame,
      bool wasSynchronouslyLoaded) {
    _wasSynchronouslyLoaded = wasSynchronouslyLoaded;
    _isLoaded = frame != null;
    return child;
  }

  Widget _loadingBuilder(
      BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
    if (_isLoaded) {
      if (_wasSynchronouslyLoaded) {
        return child;
      }
      return _stack(
        child,
        const ProgressWidget(null),
      );
    }
    if (loadingProgress != null) {
      return ProgressWidget(loadingProgress.cumulativeBytesLoaded /
          loadingProgress.expectedTotalBytes);
    }
    return const ProgressWidget(null);
  }

  Widget _errorBuilder(context, error, stacktrace) {
    return ErrorIconWidget();
  }
}
