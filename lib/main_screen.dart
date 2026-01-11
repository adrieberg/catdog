import 'dart:math';
import 'package:flutter/material.dart';
import 'game_screen.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  static const List<String> backgrounds = [
    'assets/images/background/boxes.jpg',
    'assets/images/background/city.jpg',
    'assets/images/background/dragon.jpg',
    'assets/images/background/eyes.jpg',
    'assets/images/background/forest.jpg',
  ];

  String getRandomBackground() {
    final rand = Random();
    return backgrounds[rand.nextInt(backgrounds.length)];
  }

  @override
  Widget build(BuildContext context) {
    final String bg = getRandomBackground();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            bg,
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  child: const Text('choose'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings),
                        color: Colors.black,
                        onPressed: () {
                          // TODO: Implement settings functionality
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.volume_up),
                        color: Colors.black,
                        onPressed: () {
                          // TODO: Implement sound functionality
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
