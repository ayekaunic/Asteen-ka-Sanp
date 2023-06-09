import 'dart:async';
import 'dart:math';

import 'package:asteen_ka_sanp/widgets/blank_pixel.dart';
import 'package:asteen_ka_sanp/widgets/food_pixel.dart';
import 'package:asteen_ka_sanp/widgets/snake_pixel.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snakeDirection { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // grid dimensions
  int rows = 10;
  int area = 100;

  // snake position
  List<int> snakePosition = [0, 1, 2];

  // snake direction (initially right)
  var currentDirection = snakeDirection.RIGHT;

  // food position
  int foodPosition = 63;

  // start game method
  void startGame() {
    Timer.periodic(const Duration(milliseconds: 135), (timer) {
      setState(() {
        // keep the snake moving
        moveSnake();

        // check if game over
        if (gameOver()) {
          timer.cancel();
          // show game over dialogue to user
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text('Game over'),
              );
            },
          );
        }
      });
    });
  }

  // eat food method
  void eatFood() {
    // new food shouldn't be where snake is
    while (snakePosition.contains(foodPosition)) {
      foodPosition = Random().nextInt(area);
    }
  }

  // move snake method
  void moveSnake() {
    // add new head
    switch (currentDirection) {
      case snakeDirection.RIGHT:
        // if at wall re-adjust
        if (snakePosition.last % rows == 9) {
          snakePosition.add(snakePosition.last + 1 - rows);
        } else {
          snakePosition.add(snakePosition.last + 1);
        }
        break;
      case snakeDirection.LEFT:
        // if at wall re-adjust
        if (snakePosition.last % rows == 0) {
          snakePosition.add(snakePosition.last - 1 + rows);
        } else {
          snakePosition.add(snakePosition.last - 1);
        }
        break;
      case snakeDirection.UP:
        // if at wall re-adjust
        if (snakePosition.last < rows) {
          snakePosition.add(snakePosition.last - rows + area);
        } else {
          snakePosition.add(snakePosition.last - rows);
        }
        break;
      case snakeDirection.DOWN:
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // high scores
          Expanded(
            child: Container(),
          ),

          // game grid
          Expanded(
            flex: 3,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 &&
                    currentDirection != snakeDirection.UP) {
                  currentDirection = snakeDirection.DOWN;
                } else if (details.delta.dy < 0 &&
                    currentDirection != snakeDirection.DOWN) {
                  currentDirection = snakeDirection.UP;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 &&
                    currentDirection != snakeDirection.LEFT) {
                  currentDirection = snakeDirection.RIGHT;
                } else if (details.delta.dx < 0 &&
                    currentDirection != snakeDirection.RIGHT) {
                  currentDirection = snakeDirection.LEFT;
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
                  onPressed: startGame,
                  color: Colors.blueAccent,
                  child: const Text("Play"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
