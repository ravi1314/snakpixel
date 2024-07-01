import 'dart:math';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:snakpix/widget/high_score.dart';
import 'package:snakpix/widget/food_pixel.dart';
import 'package:snakpix/widget/black_pixel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snakpix/widget/snak_pixel_postion.dart';


// ignore_for_file: unnecessary_import

// ignore_for_file: prefer_interpolation_to_compose_strings

// ignore_for_file: camel_case_types

// ignore_for_file: constant_identifier_names

// ignore_for_file: avoid_unnecessary_containers

// ignore_for_file: sort_child_properties_last

// ignore_for_file: prefer_const_literals_to_create_immutables

// ignore_for_file: prefer_const_constructors

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum snake_Direction {
  UP,
  DOWN,
  LEFT,
  RIGHT,
}

class _HomeScreenState extends State<HomeScreen> {
  //ads

  // late BannerAd bannerAd;
  // bool isBannerAdLoaded = false;

 

  // initBannerAd() {
  //   bannerAd = BannerAd(
  //       size: AdSize.banner,
  //       adUnitId:'ca-app-pub-3357982424842884/6250018816',
  //       listener: BannerAdListener(onAdLoaded: (ad) {
  //         setState(() {
  //           isBannerAdLoaded = true;
  //         });
  //       }, onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //         print(error);
  //       }),
  //       request: AdRequest());
  //   bannerAd.load();
  // }

  
  final _nameController = TextEditingController();
  //grid dimension
  int rowSize = 10;
  int totalNumberOfSquares = 120;

  //user score

  int currentScore = 0;

  //if game is started

  bool gameHasStarted = false;

  //snake Position
  List<int> snakePos = [0, 1, 2];

  //snake direction initially to the right

  var currentDirection = snake_Direction.RIGHT;

  //food position

  int foodPos = 55;

  //start game method
  Timer? _gameTimer; // Declare the Timer variable

  //high score list

  List<String> highScore_DocId = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    letsGetDocIds = getDocId();
  }

  @override
  void dispose() {
    // Cancel the timer in the dispose method
    _gameTimer?.cancel();
    super.dispose();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('highScores')
        .orderBy('score', descending: true)
        .limit(3)
        .get()
        .then((value) => value.docs.forEach((element) {
              highScore_DocId.add(element.reference.id);
            }));
  }

  void startGame() {
    gameHasStarted = true;
    _gameTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        // Check if the widget is still mounted before calling setState
        timer.cancel();
        return;
      }

      setState(() {
        moveSnake();

        if (gameOver()) {
          timer.cancel();
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Game is Over'),
                actions: [
                  Column(
                    children: [
                      Text('Your Score is : ' + currentScore.toString()),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Name',
                        ),
                      ),
                      MaterialButton(
                        color: Colors.white,
                        onPressed: () {
                          submitScore();
                          Navigator.pop(context);
                          newGame();
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    ],
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  //submit method

  void submitScore() async {
    //get access data collection

    var dataBase = FirebaseFirestore.instance;
    await dataBase
        .collection('highScores')
        .add({'name': _nameController.text, 'score': currentScore});

    print("data is store");
  }

  //start new game

  Future newGame() async {
    highScore_DocId = [];
    await getDocId();
    setState(() {
      snakePos = [0, 1, 2];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  //eat food
  void eatFood() {
    //when food is eating by snake then score is ++
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          //if snake is at the right wall, need to re-adjust

          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
          // add head

          //remove a tail
        }
        break;
      case snake_Direction.LEFT:
        {
          // add head

          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }

          //remove a tail
        }
        break;
      case snake_Direction.UP:
        {
          // add head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }

          //remove a tail
        }
        break;
      case snake_Direction.DOWN:
        {
          // add head

          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
          //remove a tail
        }
        break;
      default:
    }
    //eat food
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  // game over method
  bool gameOver() {
    //the game is over when snake runs into itself

    //this occurs when there is a duplicate snake position in the snakepos list
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);
    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth > 428 ? 428 : screenWidth,
        child: Column(
          children: [
            SizedBox(height: 20), // Adding space here

            //ad banner

            // Container(
            //   height: 100,
            //   width: 500, 
            //   child: bannerAd!= null? StartAppBanner(bannerAd!):Container(),
              
            //         ),
            

            //game grid
            Expanded(
              flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: (detail) {
                  if (detail.delta.dy > 0 &&
                      currentDirection != snake_Direction.UP) {
                    currentDirection = snake_Direction.DOWN;
                  } else if (detail.delta.dy < 0 &&
                      currentDirection != snake_Direction.DOWN) {
                    currentDirection = snake_Direction.UP;
                  }
                },
                onHorizontalDragUpdate: (detail) {
                  if (detail.delta.dx > 0 &&
                      currentDirection != snake_Direction.LEFT) {
                    currentDirection = snake_Direction.RIGHT;
                  } else if (detail.delta.dx < 0 &&
                      currentDirection != snake_Direction.RIGHT) {
                    currentDirection = snake_Direction.LEFT;
                  }
                },
                child: GridView.builder(
                  physics: PageScrollPhysics(),
                  itemCount: totalNumberOfSquares,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowSize),
                  itemBuilder: (BuildContext context, int index) {
                    if (snakePos.contains(index)) {
                      return const MySnakePixel();
                    } else if (foodPos == index) {
                      return const FoodPixel();
                    } else {
                      return const MyBlackPixel();
                    }
                  },
                ),
              ),
            ),

            //play button
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('Current Score'),
                        Text(
                          currentScore.toString(),
                          style: TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: MaterialButton(
                      onPressed: gameHasStarted ? () {} : startGame,
                      child: Text('P L A Y'),
                      color: gameHasStarted ? Colors.grey[900] : Colors.amber,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text('Highest Score'),
                            Container(
                              height: 100,
                              width: 300,
                              child: gameHasStarted
                                  ? Container()
                                  : FutureBuilder(
                                      builder: (context, snapshot) {
                                        return ListView.builder(
                                            itemCount: highScore_DocId.length,
                                            itemBuilder: (context, index) {
                                              return HighScore(
                                                documentId:
                                                    highScore_DocId[index],
                                                fontSize: 16,
                                                width: 10,
                                              );
                                            });
                                      },
                                      future: letsGetDocIds,
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
