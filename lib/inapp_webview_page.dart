import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:xrooster/api/myx.dart';

// Returns a ready-to-run MaterialApp containing the InAppWebView page.
// onToken will be called with the token when the page navigates to
// https://talland.myx.nl/?token=...
Widget inAppWebViewApp({required FutureOr<void> Function(String token) onToken}) {
  return MaterialApp(home: InAppWebViewPage(onToken: onToken));
}

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({Key? key, required this.onToken}) : super(key: key);

  final FutureOr<void> Function(String token) onToken;

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;


  @override
  void initState() {
    super.initState();
    // Enable web contents debugging on Android debug builds
    if (!kIsWeb && kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
      InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final controller = webViewController;
        if (controller != null) {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("InAppWebView test")),
        body: Column(
          children: <Widget>[
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: WebUri("https://talland.myx.nl")),
                initialSettings: InAppWebViewSettings(
                  allowsBackForwardNavigationGestures: true,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (controller, url) async {
                  if (url?.toString().startsWith('https://talland.myx.nl/?token=') ??
                      false) {
                    final urlStr = url.toString();
                    final token = urlStr
                        .replaceFirst('https://talland.myx.nl/?token=', '')
                        .replaceAll('&ngsw-bypass=true', '');
                    // notify caller and allow them to replace the app
                    try {
                      setToken(token);
                      widget.onToken(token);
                    } catch (e) {
                      debugPrint('[InAppWebView][onToken] callback error: $e');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
