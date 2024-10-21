import 'package:flutter/material.dart';

// Your RespawnScreen Widget
class RespawnScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBackToMainMenu;

  const RespawnScreen({
    Key? key,
    required this.onContinue,
    required this.onBackToMainMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your respawn screen UI
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You Died', style: TextStyle(fontSize: 50)),
            ElevatedButton(
              onPressed: onContinue, // Continue game
              child: Text('Continue'),
            ),
            ElevatedButton(
              onPressed: onBackToMainMenu, // Back to main menu
              child: Text('Back to Main Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
