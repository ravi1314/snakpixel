import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HighScore extends StatelessWidget {
  final String documentId;
  final double fontSize;
  final double width;

  const HighScore({
    Key? key,
    required this.documentId,
    required this.fontSize,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference highScores =
        FirebaseFirestore.instance.collection('highScores');

    return FutureBuilder<DocumentSnapshot>(
      future: highScores.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return ListTile(
            title: Text(
              "${data['name']} - ${data['score']}",
              style: TextStyle(fontSize: fontSize),
            ),
          );
        }

        return Text("loading...");
      },
    );
  }
}
