import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake/blank_pixel.dart';
import 'package:snake/food_pixel.dart';
import 'package:snake/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //grid dimensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;
  //snake position
  List<int> snakePos = [0, 1, 2];
  //food position
  int foodPos = 55;
  //start game
  void startGame() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        //add a new head
        snakePos.add(snakePos.last + 1);

        //remove the tail
        snakePos.remove(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //high scores
          Expanded(
            child: Container(),
          ),
          //game grid
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: totalNumberOfSquares,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowSize,
              ),
              itemBuilder: (BuildContext context, int index) {
                if (snakePos.contains(index)) {
                  return const SnakePixel();
                } else if (foodPos == index) {
                  return const FoodPixel();
                } else {
                  return const BlankPixel();
                }
              },
            ),
          ),
          //playbtn
          Expanded(
            child: Container(
              child: Center(
                child: MaterialButton(
                  onPressed: startGame,
                  child: Text("Jugar"),
                  color: Colors.pink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
