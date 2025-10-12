import 'dart:async';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/pages/login/linux.dart';

// Returns a ready-to-run MaterialApp containing the InAppWebView page.
// onToken will be called with the token when the page navigates to
// https://talland.myx.nl/?token=...
Widget inAppWebViewApp({
  required FutureOr<void> Function(String token) onToken,
}) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    themeMode: ThemeMode.system,
    home: Platform.isLinux
        ? linuxFallback(onToken: onToken)
        : InAppWebViewPage(onToken: onToken),
  );
}

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({super.key, required this.onToken});

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
    if (!kIsWeb &&
        !Platform.isLinux &&
        kDebugMode &&
        defaultTargetPlatform == TargetPlatform.android) {
      InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        final controller = webViewController;
        if (!didPop && controller != null) {
          if (await controller.canGoBack()) {
            controller.goBack();
          }
        }
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(
                  url: WebUri("https://talland.myx.nl"),
                ),
                onReceivedServerTrustAuthRequest:
                    (controller, challenge) async {
                      return ServerTrustAuthResponse(
                        action: ServerTrustAuthResponseAction.PROCEED,
                      );
                    },
                initialSettings: InAppWebViewSettings(
                  allowsBackForwardNavigationGestures: true,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (controller, url) async {
                  if (url?.toString().startsWith(
                        'https://talland.myx.nl/?token=',
                      ) ??
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
