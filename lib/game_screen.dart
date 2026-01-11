import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'globals.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  int leftCounter = 0;
  int rightCounter = 0;
  bool gameActive = true;
  bool showingCountdown = true;
  String countdownText = '3';
  List<_GameImage> images = [];
  DateTime? startTime;
  Timer? countdownTimer;
  int remainingSeconds = kGameDurationSeconds;

  static const List<String> imagePaths = [
    'assets/images/boy128.png',
    'assets/images/girl128.png',
    'assets/images/cat128.png',
    'assets/images/dog128.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialCountdown();
    });
  }

  void _startInitialCountdown() async {
     
    // Show 2
    setState(() {
      countdownText = '2';
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    // Show 1
    setState(() {
      countdownText = '1';
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    // Show GO
    setState(() {
      countdownText = 'GO';
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    // Start game
    setState(() {
      showingCountdown = false;
      startTime = DateTime.now();
    });
    _startCountdownTimer();
    _startGameLoop();
  }

  void _startCountdownTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final elapsed = DateTime.now().difference(startTime!).inSeconds;
      final remaining = kGameDurationSeconds - elapsed;
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          remainingSeconds = 0;
        });
      } else {
        setState(() {
          remainingSeconds = remaining;
        });
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void _startGameLoop() async {
    final random = Random();
    while (gameActive && DateTime.now().difference(startTime!) < Duration(seconds: kGameDurationSeconds)) {
      if (!mounted) break;
      // Add new image(s) with random delays
      for (int i = 0; i < kSimultaneousImages; i++) {
        final delay = random.nextInt(kImageVisibilitySeconds * 1000);
        Future.delayed(Duration(milliseconds: delay), () {
          if (!mounted || !gameActive) return;
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
        });
      }
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
                'Missed: $leftCounter',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          // Top center countdown
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$remainingSeconds',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
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
                'Caught: $rightCounter',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          // Game images
          ...images,
          // Show countdown before game starts
          if (showingCountdown)
            Center(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(64),
                child: Text(
                  countdownText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Show "Game Over" when finished
          if (!gameActive)
            Center(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Game Over',
                      style: TextStyle(color: Colors.white, fontSize: 40),
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
                            icon: const Icon(Icons.share),
                            color: Colors.black,
                            onPressed: () {
                              // TODO: Implement share functionality
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
                            icon: const Icon(Icons.refresh),
                            color: Colors.black,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
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
    Future.delayed(Duration(seconds: kImageVisibilitySeconds), () {
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
