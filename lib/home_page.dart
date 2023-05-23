import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snake/blank_pixel.dart';
import 'package:snake/food_pixel.dart';
import 'package:snake/highscore_tile.dart';
import 'package:snake/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  //grid dimensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;
  

  //game settings
  final _nameController = TextEditingController();
  bool gameStarted = false;
  //user score
  int currentScore = 0;
  //snake position
  List<int> snakePos = [0, 1, 2];
  //snake direction is initially to the right
  var currentDirection = snake_Direction.RIGHT;
  //food position
  int foodPos = 55;

  //highscore List
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
    
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
    .collection("highscores")
    .orderBy("score", descending: true)
    .limit(10)
    .get()
    .then((value) => value.docs.forEach((element) {
      highscore_DocIds.add(element.reference.id);
    }));
  }

  //start game
  void startGame() {
    gameStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();
        if (gameOver()) {
          timer.cancel();

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Game Over!"),
                  content: Column(
                    children: [
                      Text("Tu puntuación fue $currentScore"),
                      TextField(
                        controller: _nameController,
                        decoration:
                            InputDecoration(hintText: "Registra tu nombre"),
                      )
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        submitScore();
                        Navigator.pop(context);
                        newGame();
                      },
                      color: Colors.pink,
                      child: const Text("Enviar"),
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void submitScore() {
    //get acces to the collection
    var database = FirebaseFirestore.instance;

    //add data to firebase
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    }
    );
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [0, 1, 2];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gameStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore += 1;
    //making sure the food is not where the snake is
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          //add a head
          //if snake is at the right wall
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
      case snake_Direction.LEFT:
        {
          //add a head
          //if snake is at the right wall
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
      case snake_Direction.UP:
        {
          //add a head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
      case snake_Direction.DOWN:
        {
          //add a head
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }

        break;
      default:
    }
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      //remove tail
      snakePos.removeAt(0);
    }
  }

  //game over
  bool gameOver() {
    //the game is over when the snake hits itself
    List<int> snakeBody = snakePos.sublist(0, snakePos.length - 1);

    if (snakeBody.contains(snakePos.last)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {

    // screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth > 428 ? 428 : screenWidth,
        child: Column(
          children: [
            //high scores
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //user current score
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Puntuación actual"),
                        Text(
                          currentScore.toString(),
                          style: TextStyle(fontSize: 36),
                        ),
                      ],
                    ),
                  ),
                  //highscores
                  Expanded(
                    child: gameStarted ? Container() 
                    : FutureBuilder(
                      future: letsGetDocIds,
                      builder: (context , snapshot){
                        return ListView.builder(
                          itemCount: highscore_DocIds.length,
                          itemBuilder: (context, index) {
                            return HighScoreTile(documentId: highscore_DocIds[index]);  
                      },
                      );
                    }
                    ),
                  )

                  
                ],
              ),
            ),
            //game grid
            Expanded(
              flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      currentDirection != snake_Direction.UP) {
                    currentDirection = snake_Direction.DOWN;
                  } else if (details.delta.dy < 0 &&
                      currentDirection != snake_Direction.DOWN) {
                    currentDirection = snake_Direction.UP;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      currentDirection != snake_Direction.LEFT) {
                    currentDirection = snake_Direction.RIGHT;
                  } else if (details.delta.dx < 0 &&
                      currentDirection != snake_Direction.RIGHT) {
                    currentDirection = snake_Direction.LEFT;
                  }
                },
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
            ),
            //playbtn
            Expanded(
              child: Center(
                child: MaterialButton(
                  onPressed: gameStarted ? () {} : startGame,
                  color: gameStarted ? Colors.grey : Colors.pink,
                  child: const Text("Jugar"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
