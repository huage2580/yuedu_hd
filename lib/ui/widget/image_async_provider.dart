import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:yuedu_hd/ui/widget/image_api.dart';

class NetworkImageWithoutAuth extends ImageProvider<NetworkImageWithoutAuth> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  const NetworkImageWithoutAuth(this.url, {this.scale = 1.0, this.headers})
      : assert(url != null),
        assert(scale != null);

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;

  @override
  Future<NetworkImageWithoutAuth> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageWithoutAuth>(this);
  }

  @override
  ImageStreamCompleter load(
      NetworkImageWithoutAuth key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<NetworkImageWithoutAuth>('Image key', key);
      },
    );
  }

  static final HttpClient _httpClient = HttpClient();

  Future<Codec> _loadAsync(NetworkImageWithoutAuth key) async {
    assert(key == this);
    //解决不安全证书校验通不过的问题
    _httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
    final Uint8List bytes = await ImageApi.image(key.url);
    if (bytes.lengthInBytes == 0)
      throw Exception('NetworkImage is an empty file');

    return PaintingBinding.instance.instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final NetworkImageWithoutAuth typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}