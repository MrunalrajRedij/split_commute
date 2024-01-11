import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//this class is used to implement common functionalities through out the app
//So less repeatable code is used
class UtilFunctions {
  //common func to show SnackBar msg
  void showScaffoldMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  Future clearSearchingFromDB() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection("searching")
        .doc("searching")
        .set({
      "startingPoint": "",
      "endingPoint": "",
    });
  }

  //logout func
  void logOut(context) async {
    await clearSearchingFromDB();
    Navigator.pushNamedAndRemoveUntil(
        context, "/LoginScreen", (route) => false);
    FirebaseAuth.instance.signOut();
  }
}
