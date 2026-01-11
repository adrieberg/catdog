import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GDBC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

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
      appBar: AppBar(
        title: const Text('GDBC'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            bg,
            fit: BoxFit.cover,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(),
                  ),
                );
              },
              child: const Text('choose'),
            ),
          ),
        ],
      ),
    );
  }
}


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  int leftCounter = 0;
  int rightCounter = 0;
  bool gameActive = true;
  List<_GameImage> images = [];
  DateTime? startTime;

  static const List<String> imagePaths = [
    'assets/images/boy128.png',
    'assets/images/girl128.png',
    'assets/images/cat128.png',
    'assets/images/dog128.png',
  ];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _startGameLoop();
  }

  void _startGameLoop() async {
    final random = Random();
    while (gameActive && DateTime.now().difference(startTime!) < const Duration(seconds: 30)) {
      if (!mounted) break;
      // Add new image(s)
      setState(() {
        images.add(_GameImage(
          key: UniqueKey(),
          imagePath: imagePaths[random.nextInt(imagePaths.length)],
          left: random.nextDouble() * (MediaQuery.of(context).size.width - 128),
          top: random.nextDouble() * (MediaQuery.of(context).size.height - 128),
          onClick: _onImageClicked,
          onMissed: _onImageMissed,
        ));
      });
      await Future.delayed(const Duration(seconds: 2));
    }
    // End game
    setState(() {
      gameActive = false;
      images.clear();
    });
  }

  void _onImageClicked(_GameImage img) {
    if (!gameActive) return;
    setState(() {
      rightCounter++;
      images.remove(img);
    });
  }

  void _onImageMissed(_GameImage img) {
    if (!gameActive) return;
    setState(() {
      leftCounter++;
      images.remove(img);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Screen'),
      ),
      body: Stack(
        children: [
          // Top left counter
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Missed: \$leftCounter',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          // Top right counter
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Caught: \$rightCounter',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          // Game images
          ...images,
          // Show "Game Over" when finished
          if (!gameActive)
            Center(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(32),
                child: const Text(
                  'Game Over',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameImage extends StatefulWidget {
  final String imagePath;
  final double left;
  final double top;
  final void Function(_GameImage) onClick;
  final void Function(_GameImage) onMissed;

  const _GameImage({
    required Key key,
    required this.imagePath,
    required this.left,
    required this.top,
    required this.onClick,
    required this.onMissed,
  }) : super(key: key);

  @override
  State<_GameImage> createState() => _GameImageState();
}

class _GameImageState extends State<_GameImage> {
  bool visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && visible) {
        widget.onMissed(widget);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: GestureDetector(
        onTap: () {
          if (visible) {
            setState(() {
              visible = false;
            });
            widget.onClick(widget);
          }
        },
        child: Image.asset(
          widget.imagePath,
          width: 128,
          height: 128,
        ),
      ),
    );
  }
}

