import 'dart:async';
import 'dart:math';
import 'package:asteen_ka_sanp/widgets/blank_pixel.dart';
import 'package:asteen_ka_sanp/widgets/food_pixel.dart';
import 'package:asteen_ka_sanp/widgets/snake_pixel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SnakeDirection { up, down, left, right }

class _HomeScreenState extends State<HomeScreen> {
  // audio player
  late AudioPlayer player;
  late AudioPlayer backgrounPlayer;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    backgrounPlayer = AudioPlayer();
    // play background music
    playBackgroundMusic();
  }

  @override
  void dispose() {
    player.dispose();
    backgrounPlayer.dispose();
    super.dispose();
  }

  // method to play background music
  void playBackgroundMusic() async {
    await backgrounPlayer.setAsset('assets/audio/background_music.mp3');
    backgrounPlayer.setLoopMode(LoopMode.one);
    backgrounPlayer.play();
  }

  // grid dimensions
  int rows = 10;
  int area = 100;

  // game started
  bool gameHasStarted = false;

  // user score
  int currentScore = 0;
  int highScore = 0;

  // snake position
  List<int> snakePosition = [0, 1, 2];

  // snake direction (initially right)
  var currentDirection = SnakeDirection.right;

  // food position
  int foodPosition = 63;

  // start game method
  void startGame() async {
    await player.setAsset('assets/audio/ping.mp3');
    player.play();
    gameHasStarted = true;
    currentDirection = SnakeDirection.right;
    Timer.periodic(const Duration(milliseconds: 108), (timer) {
      setState(() async {
        // keep the snake moving
        moveSnake();

        // check if game over
        if (gameOver()) {
          await player.setAsset('assets/audio/game_over.mp3');
          player.play();
          gameHasStarted = false;
          timer.cancel();
          Vibration.vibrate();
          // show game over dialogue to user
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Game over'),
                content: Text('Your score is: $currentScore'),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      Share.share(
                          'Just racked up $currentScore pellets in Asteen ka Sanp!😎');
                    },
                    color: Colors.blueAccent,
                    child: const Text('Share'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      submitScore();
                      newGame();
                    },
                    color: Colors.blueAccent,
                    child: const Text('New game'),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  // submit score method
  void submitScore() {
    if (currentScore > highScore) {
      highScore = currentScore;
    }
  }

  // new game method
  void newGame() {
    setState(() {
      // reset game
      gameHasStarted = false;
      currentScore = 0;
      snakePosition = [0, 1, 2];
      currentDirection = SnakeDirection.right;
      foodPosition = 63;
      backgrounPlayer.play();
    });
  }

  // play sound efffect

  // eat food method
  void eatFood() {
    currentScore++;
    // new food shouldn't be where snake is
    while (snakePosition.contains(foodPosition)) {
      foodPosition = Random().nextInt(area);
    }
  }

  // move snake method
  void moveSnake() async {
    // add new head
    switch (currentDirection) {
      case SnakeDirection.right:
        // if at wall re-adjust
        if (snakePosition.last % rows == 9) {
          snakePosition.add(snakePosition.last + 1 - rows);
        } else {
          snakePosition.add(snakePosition.last + 1);
        }
        break;
      case SnakeDirection.left:
        // if at wall re-adjust
        if (snakePosition.last % rows == 0) {
          snakePosition.add(snakePosition.last - 1 + rows);
        } else {
          snakePosition.add(snakePosition.last - 1);
        }
        break;
      case SnakeDirection.up:
        // if at wall re-adjust
        if (snakePosition.last < rows) {
          snakePosition.add(snakePosition.last - rows + area);
        } else {
          snakePosition.add(snakePosition.last - rows);
        }
        break;
      case SnakeDirection.down:
        // if at wall re-adjust
        if (snakePosition.last > area - rows) {
          snakePosition.add(snakePosition.last + rows - area);
        } else {
          snakePosition.add(snakePosition.last + rows);
        }
        break;
      default:
    }

    // eat food or remove tail
    if (snakePosition.last == foodPosition) {
      await player.setAsset('assets/audio/pellet.mp3');
      player.play();
      eatFood();
    } else {
      snakePosition.removeAt(0);
    }
  }

  // game over method
  bool gameOver() {
    // game over when snake runs into itself
    // when there is a duplicate position in the snake position lits

    // body of the snake
    List<int> snakeBody = snakePosition.sublist(0, snakePosition.length - 1);

    if (snakeBody.contains(snakePosition.last)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        child: Column(
          children: [
            // high scores
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // user current score
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current score:',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Text(
                        currentScore.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),

                  // highscores
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Highscore:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: Colors.amber,
                        ),
                      ),
                      Text(
                        highScore.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // game grid
            Expanded(
              flex: 2,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      currentDirection != SnakeDirection.up) {
                    currentDirection = SnakeDirection.down;
                  } else if (details.delta.dy < 0 &&
                      currentDirection != SnakeDirection.down) {
                    currentDirection = SnakeDirection.up;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      currentDirection != SnakeDirection.left) {
                    currentDirection = SnakeDirection.right;
                  } else if (details.delta.dx < 0 &&
                      currentDirection != SnakeDirection.right) {
                    currentDirection = SnakeDirection.left;
                  }
                },
                child: GridView.builder(
                    itemCount: area,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rows,
                    ),
                    itemBuilder: (context, index) {
                      if (snakePosition.contains(index)) {
                        return const SnakePixel();
                      } else if (index == foodPosition) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    }),
              ),
            ),

            // play button
            Expanded(
              child: Container(
                child: Center(
                  child: MaterialButton(
                    onPressed: gameHasStarted ? () {} : startGame,
                    color: gameHasStarted ? Colors.grey : Colors.blueAccent,
                    child: const Text("Play"),
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
