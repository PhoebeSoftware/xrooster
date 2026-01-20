import 'package:flutter/material.dart';

MaterialApp offlinePage() {
  return MaterialApp(
    darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.system,
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.signal_wifi_connected_no_internet_4,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text('No internet connection', style: TextStyle(fontSize: 18)),
            Text(
              'Please connect to the internet to login',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}
