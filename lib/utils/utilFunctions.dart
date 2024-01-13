import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_commute/widgets/policyDialog.dart';

import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/decorations.dart' as decoration;

//this class is used to implement common functionalities through out the app
//So less repeatable code is used
class UtilFunctions {
  //common func to show SnackBar msg
  void showScaffoldMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: decoration.whiteBold14TS,
        ),
      ),
    );
  }

  Future checkIfUserFirstTime(context) async {
    final doc = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .get();

    await doc.then((value) {
      if (!value.exists) {
        Navigator.pushNamedAndRemoveUntil(
            context, "/GetInfoScreen", (route) => false);
        return true;
      } else {
        return false;
      }
    });
  }

  void privacyPolicyWidget(context) {
    showDialog(
        context: context,
        builder: (context) {
          return PolicyDialog(mdFileName: 'tos.md');
        });
  }

  Future clearSearchingFromDB(String userId) {
    return FirebaseFirestore.instance.collection("users").doc(userId).update({
      "startingPoint": "",
      "endingPoint": "",
    });
  }

  //logout func
  void logOut(context) async {
    await clearSearchingFromDB(FirebaseAuth.instance.currentUser!.phoneNumber!);
    Navigator.pushNamedAndRemoveUntil(
        context, "/LoginScreen", (route) => false);
    FirebaseAuth.instance.signOut();
  }
}
