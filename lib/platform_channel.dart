import 'package:flutter/services.dart';

class PlatformChannel {
  final channel = const MethodChannel("vn.meoluoi.openweb/flutter_channel");
  final handleNativeChannel = const MethodChannel('callbacks');
  bool hasSetNetaloUser = false;

  facebookTracking(String event) async {
    channel.invokeMethod("facebookTracking", {"event": event});
  }

  Future<bool> saveFile(String link) async {
    bool result = false;
    try {
      result = await channel.invokeMethod("saveFile", link);
      print("dashareroine:$result");
    } catch (e) {}
    return result;
  }

  Future<bool> openFile(String path) async {
    bool result = false;
    try {
      result = await channel.invokeMethod("openFile", path);
      print("openFile:$result");
    } catch (e) {}
    return result;
  }

  Future<bool> openWebView(String path) async {
    bool result = false;
    try {
      result = await channel.invokeMethod("openWebView", path);
      print("openFile:$result");
    } catch (e) {}
    return result;
  }

  Future<String> getSavePath() async {
    final result = await channel.invokeMethod("getSavePath");
    print("getSavePath: $result");
    return result;
  }

  startListeningNative(Function(dynamic) callback) async {
    handleNativeChannel.setMethodCallHandler((call) async {
      try {
        switch (call.method) {
          case 'checkIsFriend':
            print(call.arguments);
            break;

          default:
            print(
                'TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
        }
      } catch (e) {}
    });
  }
}
