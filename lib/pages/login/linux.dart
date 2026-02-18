import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/pages/login/login.dart';

Widget linuxFallback({required FutureOr<void> Function(String? token) onToken}) {
  return MaterialApp(
    darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.system,
    home: Scaffold(
      appBar: loginAppbar(() {
        onToken(null);
      }),
      body: FutureBuilder<String?>(
        future: SharedPreferencesAsync().getString('token'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final saved = snapshot.data;
          if (saved != null && saved.isNotEmpty) {
            // Use saved token once after the frame is rendered
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              setToken(saved);
              try {
                await onToken(saved);
              } catch (e) {
                debugPrint('[linuxFallback] onToken callback error: $e');
              }
            });
            return const Center(child: Text('Using saved token...'));
          }

          final controller = TextEditingController();

          return Center(
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'InAppWebView is not supported on Linux.\nPlease enter your bearer token manually:',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Bearer token",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onSubmitted: (String token) async {
                      setToken(token);
                      try {
                        await onToken(token);
                      } catch (e) {
                        debugPrint('[linuxFallback] onToken callback error: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
