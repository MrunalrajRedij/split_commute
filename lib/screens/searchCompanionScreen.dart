import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_commute/config/palette.dart' as palette;

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

class _SearchCompanionScreenState extends State<SearchCompanionScreen>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;

  late AnimationController _controller;
  final String imageUrl =
      'https://user-images.githubusercontent.com/58719230/218909229-67867fec-6f4a-43fb-bfc3-33d6bc42ae2e.png';

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    generateUserDoc(user!.phoneNumber!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void generateUserDoc(String phoneNumber) {
    db
        .collection("users")
        .doc(phoneNumber)
        .collection("searching")
        .doc("searching")
        .set(
      {
        "startingPoint": widget.startingPoint,
        "endingPoint": widget.endingPoint,
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
      appBar: AppBar(
        backgroundColor: palette.primaryColor,
        foregroundColor: palette.scaffoldBgColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.black,
              Colors.teal,
              palette.primaryColor,
            ],
            radius: 0.9,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/radar.png')),
              ),
              child: RadarSignal(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}

class RadarSignal extends StatelessWidget {
  const RadarSignal({
    super.key,
    required AnimationController controller,
  }) : _controller = controller;

  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 3.0).animate(_controller),
      child: Container(
        decoration: BoxDecoration(
          gradient: SweepGradient(
            center: FractionalOffset.center,
            colors: <Color>[
              Colors.transparent,
              Colors.white,
              Colors.transparent,
            ],
            stops: <double>[0.06, 0.11, 0],
          ),
        ),
      ),
    );
  }
}
