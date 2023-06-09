import 'dart:async';

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
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();
      });
    });
  }

  void moveSnake() {
    // add new head
    switch (currentDirection) {
      case snakeDirection.RIGHT:
        snakePosition.add(snakePosition.last + 1);
        break;
      case snakeDirection.LEFT:
        snakePosition.add(snakePosition.last - 1);
        break;
      case snakeDirection.UP:
        snakePosition.add(snakePosition.last - rows);
        break;
      case snakeDirection.DOWN:
        snakePosition.add(snakePosition.last + rows);
        break;
      default:
    }

    // remove tail
    snakePosition.removeAt(0);
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
                if (details.delta.dy > 0) {
                  currentDirection = snakeDirection.DOWN;
                } else if (details.delta.dy < 0) {
                  currentDirection = snakeDirection.UP;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  currentDirection = snakeDirection.RIGHT;
                } else if (details.delta.dx < 0) {
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
