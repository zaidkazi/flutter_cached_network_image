import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import 'fade_widget.dart';

enum PlaceholderType {
  none,
  static,
  progress,
}

typedef Widget ImageBuilder(
    BuildContext context, ImageProvider imageProvider);
typedef Widget PlaceholderBuilder(BuildContext context);
typedef Widget ProgressBuilder(
    BuildContext context, ImageChunkEvent progress);

class BetaImageWidget extends StatefulWidget {
  /// Optional builder to further customize the display of the image.
  final ImageBuilder imageBuilder;
  //TODO make this an ImageFrameBuilder and let CachedNetworkImage map it to an ImageBuilder

  /// Widget displayed while the target [imageUrl] is loading.
  final PlaceholderBuilder placeholder;

  /// Widget displayed while the target [imageUrl] is loading.
  final ProgressBuilder progressIndicatorBuilder;

  /// Widget displayed while the target [imageUrl] failed loading.
  final ImageErrorWidgetBuilder errorWidget;

  /// The duration of the fade-in animation for the [placeholder].
  final Duration placeholderFadeInDuration; //TODO do we really want this?

  /// The duration of the fade-out animation for the [placeholder].
  final Duration fadeOutDuration; // TODO

  /// The curve of the fade-out animation for the [placeholder].
  final Curve fadeOutCurve; //TODO

  /// The duration of the fade-in animation for the [imageUrl].
  final Duration fadeInDuration; //TODO

  /// The curve of the fade-in animation for the [imageUrl].
  final Curve fadeInCurve; //TODO

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder widget does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double width; //TODO use for placeholder and error widgets

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder widget does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double height; //TODO use for placeholder and error widgets

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, a [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while a
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// children); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with children in right-to-left environments, for
  /// children that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip children with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is true, there must be an ambient [Directionality] widget in
  /// scope.
  final bool matchTextDirection;

  /// Optional headers for the http request of the image url
  final Map<String, String> httpHeaders;

  /// When set to true it will animate from the old image to the new image
  /// if the url changes.
  final bool useOldImageOnUrlChange; //TODO can we still support this?

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  final Color color;

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  final BlendMode colorBlendMode;

  /// Target the interpolation quality for image scaling.
  ///
  /// If not given a value, defaults to FilterQuality.low.
  final FilterQuality filterQuality;


  /// If [cacheWidth] or [cacheHeight] are provided, it indicates to the
  /// engine that the image must be decoded at the specified size. The image
  /// will be rendered to the constraints of the layout or [width] and [height]
  /// regardless of these parameters. These parameters are primarily intended
  /// to reduce the memory usage of [ImageCache].
  final ImageProvider image;
  BetaImageWidget({
    Key key,
    image,
    this.imageBuilder,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.errorWidget,
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.httpHeaders,
    this.useOldImageOnUrlChange = false,
    this.color,
    this.filterQuality = FilterQuality.low,
    this.colorBlendMode,
    this.placeholderFadeInDuration,
    int cacheWidth,
    int cacheHeight,
  })  : image = ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight, image),
        assert(fadeOutDuration != null),
        assert(fadeOutCurve != null),
        assert(fadeInDuration != null),
        assert(fadeInCurve != null),
        assert(alignment != null),
        assert(filterQuality != null),
        assert(repeat != null),
        assert(matchTextDirection != null),
        super(key: key);

  @override
  _BetaImageWidgetState createState() => _BetaImageWidgetState();
}

class _BetaImageWidgetState extends State<BetaImageWidget> {
  @override
  Widget build(BuildContext context) {
    var placeholderType = _definePlaceholderType(
        widget.placeholder, widget.progressIndicatorBuilder);

    ImageFrameBuilder frameBuilder;
    switch(placeholderType){
      case PlaceholderType.none:
        frameBuilder = _imageBuilder;
        break;
      case PlaceholderType.static:
        frameBuilder = _placeholderBuilder;
        break;
      case PlaceholderType.progress:
        frameBuilder = _preLoadingBuilder;
        break;
    }

    return Image(
      image: widget.image,
      loadingBuilder:
          placeholderType == PlaceholderType.progress ? _loadingBuilder : null,
      frameBuilder: frameBuilder,
      errorBuilder: _errorBuilder,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      repeat: widget.repeat,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      matchTextDirection: widget.matchTextDirection,
      filterQuality: widget.filterQuality,
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

  Widget _imageBuilder(BuildContext context, Widget child, int frame,
      bool wasSynchronouslyLoaded) {
    if (frame == null) {
      return child;
    }
    return _image(child);
  }

  Widget _placeholderBuilder(BuildContext context, Widget child, int frame,
      bool wasSynchronouslyLoaded) {
    if (frame == null) {
      return _placeholder(context);
    }
    if (wasSynchronouslyLoaded) {
      return _image(child);
    }
    return _stack(
      _image(child),
      _placeholder(context),
    );
  }

  bool _wasSynchronouslyLoaded = false;
  bool _isLoaded = false;
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
        return _image(child);
      }
      return _stack(
        _image(child),
        _progressIndicator(context, null),
      );
    }
    return _progressIndicator(context, loadingProgress);
  }
  
  Widget _image(Widget child){
    if(widget.imageBuilder != null) {
      return Center(child: widget.imageBuilder(context, widget.image));
    }
    return child;
  }

  Widget _errorBuilder(context, error, stacktrace) {
    return Center(child: widget.errorWidget(context, error, stacktrace),);
  }

  Widget _progressIndicator(BuildContext context, ImageChunkEvent loadingProgress){
    return Center(child: widget.progressIndicatorBuilder(context, loadingProgress));
  }

  Widget _placeholder(BuildContext context){
    return Center(child: widget.placeholder(context));
  }

  PlaceholderType _definePlaceholderType(PlaceholderBuilder placeholder,
      ProgressBuilder progressIndicator) {
    assert(placeholder == null || progressIndicator == null);
    if (placeholder != null) return PlaceholderType.static;
    if(progressIndicator != null) return PlaceholderType.progress;
    return PlaceholderType.none;
  }
}
