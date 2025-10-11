import 'dart:async';

import 'package:flutter/material.dart';

Widget linuxFallback({required FutureOr<void> Function(String token) onToken}) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('XRooster Login')),
      body: Center(
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
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Bearer token",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                onSubmitted: (String token) {
                  onToken(token);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
