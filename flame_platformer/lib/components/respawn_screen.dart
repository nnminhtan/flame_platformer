import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Your RespawnScreen Widget
class RespawnScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBackToMainMenu;

  const RespawnScreen({
    super.key,
    required this.onContinue,
    required this.onBackToMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your respawn screen UI
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You Died', 
                style: GoogleFonts.cinzelDecorative(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: onContinue, // Continue game
              child: Text(
              'Continue',
              style: GoogleFonts.cinzelDecorative(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onBackToMainMenu, // Back to main menu
              child: Text(
                'Back to Main Menu',
                style: GoogleFonts.cinzelDecorative(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
