import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String path;
  WebViewScreen(this.path);

  @override
  State<StatefulWidget> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      // initialFile: widget.path,
      initialUrlRequest: URLRequest(url: Uri.parse(widget.path)),
      initialUserScripts: UnmodifiableListView<UserScript>([]),
      initialOptions: options,
      onWebViewCreated: (controller) async {
        webViewController = controller;
        final data = await File(widget.path).readAsString(encoding: utf8);
        final String contentBase64 =
            base64Encode(const Utf8Encoder().convert(data));

        await webViewController?.loadUrl(
          urlRequest: URLRequest(
            url: Uri.dataFromString(data,
                mimeType: 'text/html', encoding: Encoding.getByName('utf-8')),
          ),
        );
      },
    );
  }
}
