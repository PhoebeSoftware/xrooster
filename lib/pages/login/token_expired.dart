import 'package:flutter/material.dart';

class TokenExpiredPage extends StatelessWidget {
  final VoidCallback onReLogin;
  final VoidCallback onViewCached;

  const TokenExpiredPage({
    super.key,
    required this.onReLogin,
    required this.onViewCached,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_clock,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Token expired',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Your login token is no longer valid.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onViewCached,
              icon: Icon(Icons.history),
              label: Text('View Cached Schedule'),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReLogin,
              icon: Icon(Icons.login),
              label: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
