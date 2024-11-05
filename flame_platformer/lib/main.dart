import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart'
    as flame; // Alias flame to avoid conflict between route
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_platformer/locallization/applocalizations.dart';
import 'package:flame_platformer/components/game%20data/gamedata.dart';
import 'package:flame_platformer/firebase_options.dart';
import 'package:flame_platformer/flame_platformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'locallization/localprovider.dart';

// Global variables for sound settings
bool playSounds = true;
double soundVolume = 1.0;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "platformer-game-fe9ef",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  if (playSounds) {
    FlameAudio.bgm.play('He is.mp3', volume: soundVolume * .5);
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(), // Add the LocaleProvider
      child: Builder(
        builder: (context) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            home: MenuScreen(), // Start with the menu screen
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('vi', ''),
            ],
            locale: Provider.of<LocaleProvider>(context)
                .currentLocale, // Get current locale from provider
          );
        },
      ),
    ),
  );
}

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class MenuScreen extends StatefulWidget {
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  bool _isSignedIn = false;

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

  Future<void> handleSignIn() async {
    try {
      UserCredential userCredential = await signInWithGoogle();
      print("Signed in as: ${userCredential.user?.displayName}");

      setState(() {
        _isSignedIn = true;
      });

      // Hiển thị Snackbar thông báo đăng nhập thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signed in successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Sign-in failed: $e");

      // Hiển thị Snackbar với lỗi chi tiết
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign-in failed: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // void loadGameData(){
  //   // Load GameData from file
  //   Future<GameData?> loadGameData() async {
  //     try {
  //       final directory = await getApplicationDocumentsDirectory();
  //       final path = '${directory.path}/game_data.json';
  //       final file = File(path);

  //       if (await file.exists()) {
  //         final jsonData = await file.readAsString();  // Read JSON data from file
  //         return GameData.fromJson(jsonDecode(jsonData));  // Convert JSON to GameData
  //       }
  //     } catch (e) {
  //       print('Error loading game data: $e');
  //     }
  //     return null;  // Return null if file doesn't exist or an error occurs
  //   }
  // }
  Future<GameData> loadGameDataFromFile(String filePath) async {
    final file = File(filePath);
    final jsonData = await file.readAsString();

    // Deserialize the JSON data to GameData object
    return GameData.fromJson(jsonDecode(jsonData));
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
              AppLocalizations.of(context)!.translate('title'),
              style: GoogleFonts.cinzelDecorative(
                textStyle: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.translate('subtitle'),
              style: GoogleFonts.cinzelDecorative(
                textStyle: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
              child: Text(
                AppLocalizations.of(context)!.translate('new_game'),
                style: GoogleFonts.grenzeGotisch(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
            // const SizedBox(height: 20), // Add space between buttons
            if (!_isSignedIn)
              Column(
                children: [
                  const SizedBox(height: 10), // Add space between buttons
                  ElevatedButton(
                    onPressed: handleSignIn,
                    child: Text(
                      AppLocalizations.of(context)!.translate('sign_in_google'),
                      style: GoogleFonts.grenzeGotisch(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                FlameAudio.bgm.stop();
                // Navigate to the Load Game Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadGameScreen(
                      onGameSelected: (selectedFilePath) async {
                        // Load the game data from the selected file
                        final gameData =
                            await loadGameDataFromFile(selectedFilePath);
                        print('hp: ${gameData.playerData.hp}');
                        print('x: ${gameData.playerData.x}');
                        print('y: ${gameData.playerData.y}');
                        print('level: ${gameData.playerData.level}');
                        print(
                            'bonfireName: ${gameData.playerData.bonfireName}');
                        print('inCave: ${gameData.playerData.inCave}');
                        print('playSounds: ${playSounds}');
                        print('soundVolume: ${soundVolume}');
                        // Navigate to game screen with the loaded data
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(
                              hp: gameData.playerData.hp,
                              x: gameData.playerData.x,
                              y: gameData.playerData.y,
                              level: gameData.playerData.level,
                              bonfireName: gameData.playerData.bonfireName,
                              inCave: gameData.playerData.inCave,
                              playSounds: playSounds,
                              soundVolume: soundVolume,
                              isloadfromsavefile: true,
                            ),
                          ),
                          (Route<dynamic> route) =>
                              false, // Remove all previous routes
                        );
                      },
                    ),
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.translate('load_game'),
                style: GoogleFonts.grenzeGotisch(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10), // Add space between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to settings or handle settings logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.translate('settings'),
                style: GoogleFonts.grenzeGotisch(
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

class GameScreen extends StatelessWidget {
  final double? hp;
  final double? x;
  final double? y;
  final String? level;
  final String? bonfireName;
  final bool? inCave;

  final bool playSounds;
  final double soundVolume;
  final bool? isloadfromsavefile;
  GameScreen({
    this.hp,
    this.x,
    this.y,
    this.level,
    this.bonfireName,
    this.inCave,
    required this.playSounds, // Optional, default to true
    required this.soundVolume,
    this.isloadfromsavefile,
  });

  @override
  Widget build(BuildContext context) {
    // You can now access the `playSounds` and `soundVolume` values in your game logic.
    flame.Game game = FlamePlatformer(
      hp: hp ?? 100.0,
      x: x ?? 272,
      y: y ?? 416,
      level: level ?? 'forestmap',
      bonfireName: bonfireName ?? 'Bonfire_Ground',
      inCave: inCave ?? false,
      playSounds: playSounds ?? true, // Use passed value or default to true
      soundVolume: soundVolume ?? 1.0, // Use passed value or default to 1.0
      isloadfromsavefile: isloadfromsavefile ?? false,
    ); // Initialize your game instance

    return Scaffold(
      body: flame.GameWidget(
        game: kDebugMode
            ? FlamePlatformer(
                hp: hp ?? 100.0,
                x: x ?? 272,
                y: y ?? 416,
                level: level ?? 'forestmap',
                bonfireName: bonfireName ?? 'Bonfire_Ground',
                inCave: inCave ?? false,
                playSounds:
                    playSounds ?? true, // Use passed value or default to true
                soundVolume:
                    soundVolume ?? 1.0, // Use passed value or default to 1.0
                isloadfromsavefile: isloadfromsavefile ?? false,
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
        title: Text(AppLocalizations.of(context)!.translate('settings')),
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
                Text(
                  AppLocalizations.of(context)!.translate('play_sounds'),
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
            const SizedBox(height: 10),

            // Sound Volume Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.translate('sound_volume'),
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
                          FlameAudio.bgm.play('He is.mp3',
                              volume:
                                  soundVolume * .5); // Restart with new volume
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // Language Switch Button
            ElevatedButton(
              onPressed: () {
                // Switch the language
                Provider.of<LocaleProvider>(context, listen: false)
                    .switchLocale();
              },
              child: Text(
                AppLocalizations.of(context)!.translate('switch_language'),
                style: GoogleFonts.grenzeGotisch(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
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
              child: Text(
                AppLocalizations.of(context)!.translate('return_menu'),
                style: GoogleFonts.grenzeGotisch(
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

class LoadGameScreen extends StatefulWidget {
  final Function(String)
      onGameSelected; // Callback to pass the selected file path

  const LoadGameScreen({Key? key, required this.onGameSelected})
      : super(key: key);

  @override
  _LoadGameScreenState createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends State<LoadGameScreen> {
  List<File> _savedGames = [];

  @override
  void initState() {
    super.initState();
    _loadSavedGames();
  }

  Future<void> _loadSavedGames() async {
    final directory = await getApplicationDocumentsDirectory();
    final savedFiles = directory
        .listSync()
        .where((item) => item is File && item.path.endsWith('.json'));

    setState(() {
      _savedGames = savedFiles.map((item) => item as File).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Load Game')),
      body: ListView.builder(
        itemCount: _savedGames.length,
        itemBuilder: (context, index) {
          final file = _savedGames[index];
          return ListTile(
            title: Text(file.path.split('/').last), // Show file name
            onTap: () {
              widget.onGameSelected(file.path); // Pass file path to callback
              Navigator.pop(context); // Close load game screen
            },
          );
        },
      ),
    );
  }
}
