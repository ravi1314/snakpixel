import 'dart:async';
import 'home_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:snakpix/widget/high_score.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showSplash = true;
  List<String> highScore_DocId = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    super.initState();
    letsGetDocIds = getDocId();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 200),
          child: _showSplash
              ? Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      alignment: Alignment.center,
                      child: Text(
                        'Snake Pixel',
                        style: GoogleFonts.pressStart2p(
                          textStyle: const TextStyle(
                              color: Colors.amber,
                              letterSpacing: .5,
                              fontSize: 30),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text(
                        "Are you Beating this Score?",
                        style: GoogleFonts.pressStart2p(
                          textStyle: const TextStyle(
                              color: Colors.amber,
                              letterSpacing: .2,
                              fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      height: 100,
                      width: 300,
                      child: FutureBuilder(
                        future: letsGetDocIds,
                        builder: (context, snapshot) {
                          return ListView.builder(
                            itemCount: highScore_DocId.length,
                            itemBuilder: (context, index) {
                              return HighScore(
                                documentId: highScore_DocId[index],
                                fontSize: 23,
                                width: 30,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      elevation: 10,
                      color: Colors.white,
                      onPressed: _showDialogBox,
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  void _showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Game is Started",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you are beating this score?",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text(
                "Yes I Do",
                style: GoogleFonts.pressStart2p(
                    textStyle: const TextStyle(color: Colors.red)),
              ),
              onPressed: () {
                Get.to(() => const HomeScreen());
              },
            ),
          ],
        );
      },
    );
  }
}
