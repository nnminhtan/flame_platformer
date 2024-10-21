import 'package:flame/flame.dart';
import 'package:flame/game.dart' as flame; // Alias flame to avoid conflict between route
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Global variables for sound settings
bool playSounds = true;
double soundVolume = 1.0;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  if (playSounds) {
    FlameAudio.bgm.play('He is.mp3', volume: soundVolume * .5);
  }

  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: MenuScreen(), // Start with the menu screen
    ),
  );
}

class MenuScreen extends StatefulWidget {
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register as a lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes
    if (state == AppLifecycleState.paused) {
      // App goes to the background, pause the music
      FlameAudio.bgm.pause();
    } else if (state == AppLifecycleState.resumed) {
      // App returns to the foreground, resume the music if sound is enabled
      if (playSounds) {
        FlameAudio.bgm.resume();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Migga', // Replace with your game title
              style: GoogleFonts.cinzelDecorative(
                textStyle: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              'Beyond Journey\'s End', // Replace with your game subtitle
              style: GoogleFonts.cinzelDecorative(
                textStyle: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                FlameAudio.bgm.stop();
                // Navigate to game screen when Start Game is pressed
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      playSounds: playSounds,
                      soundVolume: soundVolume,
                    ),
                  ),
                  (Route<dynamic> route) => false, // Remove all previous routes
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
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
  final bool playSounds;
  final double soundVolume;

  GameScreen({required this.playSounds, required this.soundVolume});

  @override
  Widget build(BuildContext context) {
    // You can now access the `playSounds` and `soundVolume` values in your game logic.
    flame.Game game = FlamePlatformer(
      playSounds: playSounds ?? true, // Use passed value or default to true
      soundVolume: soundVolume ?? 1.0, // Use passed value or default to 1.0
    ); // Initialize your game instance

    return Scaffold(
      body: flame.GameWidget(
        game: kDebugMode
            ? FlamePlatformer(
                playSounds: playSounds ?? true, // Use passed value or default to true
                soundVolume: soundVolume ?? 1.0, // Use passed value or default to 1.0
              )
            : game, // Game is displayed when you reach this screen
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Play Sounds Checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Play Sounds',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Checkbox(
                  value: playSounds,
                  onChanged: (bool? value) {
                    setState(() {
                      playSounds = value!;
                      if (playSounds) {
                        FlameAudio.bgm.resume();
                      } else {
                        FlameAudio.bgm.pause();
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Sound Volume Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sound Volume',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Expanded(
                  child: Slider(
                    value: soundVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: (soundVolume * 100).round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        soundVolume = value;
                        if (playSounds) {
                          FlameAudio.bgm.play('He is.mp3', volume: soundVolume * .5); // Restart with new volume
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Return to Menu Button
            ElevatedButton(
              onPressed: () {
                if (playSounds) {
                  // FlameAudio.bgm.resume();
                }
                Navigator.pop(context); // Return to Menu
              },
              child: const Text(
                'Return to Menu',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
