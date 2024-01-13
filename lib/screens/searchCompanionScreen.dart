import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/values.dart' as values;
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/screens/chatRoomScreen.dart';
import 'package:split_commute/utils/models/userModel.dart';
import 'package:split_commute/utils/utilFunctions.dart';
import 'package:split_commute/widgets/radarAvatarWidget.dart';

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
  bool hidden = true;
  List<UserModel> userModels = [];
  List<UserModel> selectedUsers = [];
  int joinedUsers = 1;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        hidden = false;
      });
    });
    generateUserDoc(user!.phoneNumber!);
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    UtilFunctions().clearSearchingFromDB(user!.phoneNumber!);
    super.dispose();
  }

  void generateUserDoc(String phoneNumber) {
    db.collection("users").doc(phoneNumber).update(
      {
        "startingPoint": widget.startingPoint,
        "endingPoint": widget.endingPoint,
      },
    ).then((value) => searchCompanionFunc(phoneNumber));
  }

  void searchCompanionFunc(String phoneNumber) async {
    db
        .collection("users")
        .orderBy("userId")
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
      userModels.clear();
      for (int i = 0; i < selectedUsers.length; i++) {
        selectedUsers.add(
          UserModel(
            userId: event.docs[i]['userId'],
            userName: event.docs[i]['userName'],
            profilePicUrl: "event.docs[i]['profilePicUrl']",
          ),
        );
        joinedUsers++;
        setState(() {});
      }
      checkForGroupAndCreateGroup();
    });
  }

  void checkForGroupAndCreateGroup() async {
    if (selectedUsers.isEmpty) return;
    print("////////Not empty");
    for (int i = 0; i < 4; i++) {
      if (selectedUsers[0].userId == user!.phoneNumber) {
        await db
            .collection("groups")
            .doc(selectedUsers[0].userId)
            .set({"ownerId": selectedUsers[0].userId});

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              userId: selectedUsers[0].userId,
              groupId: selectedUsers[0].userId,
            ),
          ),
        );
        return;
      } else {
        final tempUserId = selectedUsers[i].userId;
        db.collection("groups").doc(tempUserId).get().then((value) {
          if (value.exists) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  userId: user!.phoneNumber!,
                  groupId: tempUserId,
                ),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: palette.primaryColor,
        foregroundColor: palette.scaffoldBgColor,
      ),
      body: SafeArea(
        child: Container(
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
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Companion searched:\n$joinedUsers/4",
                  textAlign: TextAlign.center,
                  style: decoration.whiteBold18TS,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/radar.png')),
                ),
                child: RadarSignal(
                  controller: _controller,
                  hideBool: hidden,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: palette.greenColor,
                        foregroundColor: palette.whiteColor,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                          30,
                        ))),
                    onPressed: () {},
                    child: Text(
                      'Proceed',
                      style: decoration.whiteBold16TS,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RadarSignal extends StatefulWidget {
  final hideBool;
  final AnimationController controller;
  const RadarSignal({
    super.key,
    this.hideBool,
    required this.controller,
  });

  @override
  State<RadarSignal> createState() => _RadarSignalState();
}

class _RadarSignalState extends State<RadarSignal> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: !widget.hideBool,
          child: Align(
            alignment: Alignment(-0.55, -0.3),
            child: RadarAvatarWidget(
              profilePicUrl: values.womanProfilePicLink,
            ),
          ),
        ),
        Visibility(
          visible: !widget.hideBool,
          child: Align(
            alignment: Alignment(0.35, -0.2),
            child: RadarAvatarWidget(
              profilePicUrl: values.girlProfilePicLink,
            ),
          ),
        ),
        Visibility(
          visible: !widget.hideBool,
          child: Align(
            alignment: Alignment(-0.4, 0.25),
            child: RadarAvatarWidget(
              profilePicUrl: values.boyProfilePicLink,
            ),
          ),
        ),
        Visibility(
          visible: !widget.hideBool,
          child: Align(
            alignment: Alignment(0.6, 0.35),
            child: RadarAvatarWidget(
              profilePicUrl: values.manProfilePicLink,
            ),
          ),
        ),
        RotationTransition(
          turns: Tween(begin: 0.0, end: 3.0).animate(widget.controller),
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
        ),
      ],
    );
  }
}
