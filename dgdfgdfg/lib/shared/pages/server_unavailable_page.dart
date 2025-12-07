import 'package:flutter/material.dart';

class ServerUnavailablePage extends StatelessWidget {
  const ServerUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Server Unavailable', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Please try again later'),
          ],
        ),
      ),
    );
  }
}

