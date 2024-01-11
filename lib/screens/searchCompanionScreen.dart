import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchCompanionScreen extends StatefulWidget {
  final String startingPoint;
  final String endingPoint;
  const SearchCompanionScreen({
    super.key,
    required this.startingPoint,
    required this.endingPoint,
  });

  @override
  State<SearchCompanionScreen> createState() => _SearchCompanionScreenState();
}

class _SearchCompanionScreenState extends State<SearchCompanionScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    generateUserDoc(user!.phoneNumber!);
  }

  Future<void> generateUserDoc(String phoneNumber) async {
    await db.collection("users").doc(phoneNumber).set(
      {
        "startingPoint": widget.startingPoint,
        "endingPoint": widget.endingPoint,
        "userId": phoneNumber,
      },
    ).then((value) => searchCompanionFunc());
  }

  void searchCompanionFunc() async {
    db
        .collection("users")
        .where(
          "startingPoint",
          isEqualTo: widget.startingPoint,
        )
        .where(
          "endingPoint",
          isEqualTo: widget.endingPoint,
        )
        .snapshots()
        .listen((event) {
      for (int i = 0; i < event.size; i++) {
        print("///" + event.docs[i]['userId']);
      }
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
