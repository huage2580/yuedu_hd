import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';

final Future<LoadBalancer> loadBalancer =
LoadBalancer.create(2, IsolateRunner.spawn);

class ImageApi {
  static final HttpClient _httpClient = HttpClient();

  static Future<Uint8List> image(String url) async {
    return getRequest(url);
  }

  static Future<Uint8List> getRequest(String url) async {
    final ReceivePort receivePort = ReceivePort();
    final LoadBalancer lb = await loadBalancer;
    // 开启一个线程
    await lb.run<dynamic, SendPort>(dataLoader, receivePort.sendPort);
    final SendPort sendPort = await receivePort.first;
    final ReceivePort resultPort = ReceivePort();
    sendPort.send([url, resultPort.sendPort]);
    Uint8List response = await resultPort.first;
    return Future.value(response);
  }

  // isolate的绑定方法
  static dataLoader(SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((msg) async {
      String requestURL = msg[0];
      SendPort callbackPort = msg[1];

      final Uri resolved = Uri.base.resolve(requestURL);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw Exception(
            'HTTP request failed, statusCode: ${response?.statusCode}, $resolved');

      final Uint8List bytes =
      await consolidateHttpClientResponseBytes(response);

      // 回调返回值给调用者
      callbackPort.send(bytes);
    });
  }
}