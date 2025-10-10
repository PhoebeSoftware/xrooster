import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Returns a ready-to-run MaterialApp containing the InAppWebView page.
Widget inAppWebViewApp() {
  return const MaterialApp(home: InAppWebViewPage());
}

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({Key? key}) : super(key: key);

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  void _logUrl(String event, Object? url) {
    final urlStr = url?.toString() ?? 'null';
    // Use debugPrint to avoid truncation in release logs
    debugPrint('[InAppWebView][$event] ${DateTime.now().toIso8601String()} -> $urlStr');
  }

  @override
  void initState() {
    super.initState();
    // Enable web contents debugging on Android debug builds
    if (!kIsWeb &&
        kDebugMode &&
        defaultTargetPlatform == TargetPlatform.android) {
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
          appBar: AppBar(
            title: const Text("InAppWebView test"),
          ),
          body: Column(children: <Widget>[
            Expanded(
                child: InAppWebView(
                key: webViewKey,
                initialUrlRequest:
                  URLRequest(url: WebUri("https://talland.myx.nl")),
                initialSettings: InAppWebViewSettings(
                  allowsBackForwardNavigationGestures: true),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (controller, url) async {
                  if (url?.toString().startsWith('https://talland.myx.nl/?token=') ?? false) {
                  final urlStr = url.toString();
                  final token = urlStr
                    .replaceFirst('https://talland.myx.nl/?token=', '')
                    .replaceAll('&ngsw-bypass=true', '');
                  _logUrl('onLoadStop', token); // PEAKKKKKKK
                  }
                },
              ),
            ),
          ])),
    );
  }
}
