import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec;
import 'dart:ui' show Size, Locale, TextDirection, hashValues;
import 'package:image/image.dart' as graphics;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class BlurHashImage extends ImageProvider<BlurHashImage> {
  /// Creates an object that decodes a [Uint8List] buffer as an image.
  ///
  /// The arguments must not be null.
  const BlurHashImage(this.blurHash, {this.scale = 1.0})
      : assert(blurHash != null),
        assert(scale != null);

  /// The bytes to decode into an image.
  final String blurHash;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<BlurHashImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<BlurHashImage>(this);
  }

  @override
  ImageStreamCompleter load(BlurHashImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(BlurHashImage key, DecoderCallback decode) async {
    assert(key == this);
    var decodingWidth = 32;
    var decodingHeight = 32;

    var bytes = await blurHashDecode(
      blurHash: blurHash,
      width: decodingWidth,
      height: decodingHeight,
    ).then((rs) {
      final img = graphics.Image.fromBytes(decodingWidth, decodingHeight, rs);
      return Uint8List.fromList(graphics.encodePng(img));
    });
    return decode(bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is BlurHashImage &&
        other.blurHash == blurHash &&
        other.scale == scale;
  }

  @override
  int get hashCode => hashValues(blurHash.hashCode, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'BlurHashImage')}(${describeIdentity(blurHash)}, scale: $scale)';
}
