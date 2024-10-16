import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Flame.device.fullScreen();
//   await Flame.device.setLandscape();

//   FlamePlatformer game = FlamePlatformer();
//   runApp(
//     GameWidget(game: kDebugMode ? FlamePlatformer() : game,
//     ),
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuScreen(), // Start with the menu screen
    ),
  );
}

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to game screen when Start Game is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
              child: const Text(
                'Start Game',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20), // Add space between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to settings or handle settings logic here
                print('Settings Button Pressed'); // Placeholder for settings
              },
              child: const Text(
                'Settings',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlamePlatformer game = FlamePlatformer(); // Initialize your game instance

    return Scaffold(
      body: GameWidget(
        game: kDebugMode ? FlamePlatformer() : game, // Game is displayed when you reach this screen
      ),
    );
  }
}
