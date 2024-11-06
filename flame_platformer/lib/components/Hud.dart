// import 'package:flame/game.dart';
// import 'package:flame_platformer/flame_platformer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// class PauseMenu extends StatelessWidget {
//   final VoidCallback onResume;
//   final VoidCallback onExit;

//   const PauseMenu({Key? key, required this.onResume, required this.onExit}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black54, // Semi-transparent background
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Paused',
//             style: TextStyle(color: Colors.white, fontSize: 32),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: onResume,
//             child: Text('Resume'),
//           ),
//           ElevatedButton(
//             onPressed: onExit,
//             child: Text('Exit'),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class MyGameWidget extends StatelessWidget {
//   final FlamePlatformer game = Flam();

//   @override
//   Widget build(BuildContext context) {
//     return GameWidget(
//       game: game,
//       overlayBuilderMap: {
//         'PauseMenu': (context, game) {
//           return PauseMenu(
//             onResume: () {
//               game.; // Resume the game
//               Overlay.of(context)?.remove('PauseMenu'); // Remove the overlay
//             },
//             onExit: () {
//               // Implement exit logic (e.g., return to main menu)
//             },
//           );
//         },
//       },
//       children: [
//         Positioned(
//           top: 16,
//           right: 16,
//           child: IconButton(
//             icon: Icon(Icons.pause, color: Colors.white),
//             onPressed: () {
//               game.togglePause();
//               if (game.isPaused) {
//                 Overlay.of(context)?.insert(
//                   OverlayEntry(
//                     builder: (context) => PauseMenu(
//                       onResume: () {
//                         game.togglePause(); // Resume the game
//                         Overlay.of(context)?.remove('PauseMenu'); // Remove overlay
//                       },
//                       onExit: () {
//                         // Implement exit logic (e.g., return to main menu)
//                       },
//                     ),
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }