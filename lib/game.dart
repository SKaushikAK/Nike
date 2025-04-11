import 'package:flutter/material.dart';
import 'dart:async';

// environment:
//   sdk: ">2.12.0 <3.7.0"
//   # > 2.12.0 < 3.7.0

// # Dependencies specify other packages that your package needs in order to work.
// # To automatically upgrade your package dependencies to the latest versions
// # consider running `flutter pub upgrade --major-versions`. Alternatively,
// # dependencies can be manually updated by changing the version numbers below to
// # the latest version available on pub.dev. To see which dependencies have newer
// # versions available, run `flutter pub outdated`.
// dependencies:
//   flutter:
//     sdk: flutter
//   screenshot: ^2.1.0
//   path_provider: ^2.0.15

//   # The following adds the Cupertino Icons font to your application.
//   # Use with the CupertinoIcons class for iOS style icons.
//   cupertino_icons: ^1.0.8
//   provider: ^6.1.2

// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   nike:
//     git: "https://github.com/SKaushikAK/Nike.git"


void main() {
  runApp(CatchGame());
}



class CatchGame extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Ball variables
  double ballX = 0;
  double ballY = -1;
  double ballSize = 40;
  double ballSpeedX = 0.02; // Horizontal speed
  double ballSpeedY = 0.02; // Vertical speed
  bool movingDown = true; // Ball moving down

  // Basket variables
  double basketX = 0;
  double basketWidth = 100;

  // Game variables
  int score = 0;
  int lives = 3;
  bool gameHasStarted = false;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  // Start the game
  void startGame() {
    gameHasStarted = true;
    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        moveBall();
        checkCollision();
      });
    });
  }

  // Reset the game
  void resetGame() {
    setState(() {
      ballX = 0;
      ballY = -1;
      ballSpeedY = 0.02;
      score = 0;
      lives = 3;
      gameHasStarted = false;
    });
  }

  // Move the ball with bouncing logic
  void moveBall() {
    // Move horizontally
    ballX += ballSpeedX;

    // Bounce off left or right walls
    if (ballX <= -1 || ballX >= 1) {
      ballSpeedX *= -1; // Reverse direction
    }

    // Move vertically
    if (movingDown) {
      ballY += ballSpeedY;
    } else {
      ballY -= ballSpeedY;
    }

    // Ball hits bottom - bounce back
    if (ballY > 0.95) {
      if (ballX >= basketX - basketWidth / 200 &&
          ballX <= basketX + basketWidth / 200) {
        score += 1; // Ball caught, increase score
      } else {
        lives -= 1; // Missed the ball
        if (lives == 0) {
          gameOver();
          return;
        }
      }
      movingDown = false; // Bounce upward after hitting bottom
    }

    // Ball hits top - change direction
    if (ballY < -1) {
      movingDown = true; // Start moving down again
    }
  }

  // Check if ball goes beyond limits
  void checkCollision() {
    if (lives == 0) {
      gameOver();
    }
  }

  // Game over - show dialog
  void gameOver() {
    gameTimer?.cancel();
    gameHasStarted = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text("Score: $score"),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context);
              },
              child: const Text("Restart"),
            ),
          ],
        );
      },
    );
  }

  // Move basket horizontally on drag
  void moveBasket(DragUpdateDetails details) {
    setState(() {
      double dragX = details.delta.dx / MediaQuery.of(context).size.width;
      basketX += dragX * 2;

      // Keep basket within boundaries
      if (basketX < -1) {
        basketX = -1;
      } else if (basketX > 1) {
        basketX = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!gameHasStarted) {
          startGame(); // Start the game on initial tap
        }
      },
      onHorizontalDragUpdate: moveBasket, // Move basket on drag
      child: Scaffold(
        backgroundColor: Colors.blue[200],
        body: Column(
          children: [
            // Game Area
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // Ball
                  AnimatedContainer(
                    alignment: Alignment(ballX, ballY),
                    duration: const Duration(milliseconds: 0),
                    child: Container(
                      width: ballSize,
                      height: ballSize,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Basket
                  Container(
                    alignment: Alignment(basketX, 1),
                    child: Container(
                      width: basketWidth,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  // Tap to Start Message
                  gameHasStarted
                      ? const SizedBox.shrink()
                      : const Center(
                    child: Text(
                      "TAP TO START",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom UI
            Expanded(
              child: Container(
                color: Colors.brown[300],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Score: $score",
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    Text(
                      "Lives: $lives",
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
