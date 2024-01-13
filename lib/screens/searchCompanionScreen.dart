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
  // List<UserModel> userModels = [];
  List<UserModel> selectedUsers = [];
  int joinedUsers = 0;
  String groupId = "";
  bool grouped = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        hidden = false;
      });
    });
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    generateUserDoc(user!.phoneNumber!);
  }

  @override
  void dispose() {
    _controller.dispose();
    UtilFunctions().clearSearchingFromDB(user!.phoneNumber!);
    super.dispose();
  }

  void generateUserDoc(String phoneNumber) async {
    await db.collection("users").doc(phoneNumber).update(
      {
        "startingPoint": widget.startingPoint,
        "endingPoint": widget.endingPoint,
      },
    );
    searchForRoomOrCreateOne();
  }

  void searchForRoomOrCreateOne() async {
    int i = 0;
    int tempCount = 0;
    while (true) {
      String tempGroupId = "${widget.startingPoint}-${widget.endingPoint}-$i}";
      await db.collection("groups").doc(tempGroupId).get().then((value) async {
        if (groupId != "") return;
        if (value.exists) {
          await db
              .collection("groups")
              .doc(tempGroupId)
              .get()
              .then((value) async {
            tempCount = value['count'];
            if (tempCount < 2) {
              await db
                  .collection("users")
                  .doc(user!.phoneNumber)
                  .update({"grouped": true, "groupId": tempGroupId});
              groupId = tempGroupId;
              tempCount++;
              await db
                  .collection('groups')
                  .doc("${widget.startingPoint}-${widget.endingPoint}-$i}")
                  .set({"count": tempCount});
              return;
            }
          });
        } else {
          await db
              .collection('groups')
              .doc("${widget.startingPoint}-${widget.endingPoint}-$i}")
              .set({"count": 1});
          await db
              .collection('groups')
              .doc("${widget.startingPoint}-${widget.endingPoint}-$i}")
              .collection('messages')
              .doc()
              .set({
            'recentMessage': "",
            'recentMessageSender': "",
            'recentMessageTime': "",
          });
          await db.collection("users").doc(user!.phoneNumber).update({
            "grouped": true,
            "groupId": "${widget.startingPoint}-${widget.endingPoint}-$i}"
          });
          groupId = "${widget.startingPoint}-${widget.endingPoint}-$i}";
          return;
        }
      });
      i++;
    }
  }

  // Future searchCompanionFunc(String phoneNumber) async {
  //   db
  //       .collection("users")
  //       .where(
  //         "startingPoint",
  //         isEqualTo: widget.startingPoint,
  //       )
  //       .where(
  //         "endingPoint",
  //         isEqualTo: widget.endingPoint,
  //       )
  //       // .orderBy("userId", descending: false)
  //       .get()
  //       .then((event) async {
  //     if (grouped) return;
  //     int tempSize = 0;
  //     if (event.size > 4) {
  //       tempSize = 4;
  //     } else {
  //       tempSize = event.size;
  //     }
  //     // selectedUsers.clear();
  //     joinedUsers = 0;
  //     for (int i = 0; i < tempSize; i++) {
  //       selectedUsers.add(
  //         UserModel(
  //           userId: event.docs[i]['userId'],
  //           userName: event.docs[i]['userName'],
  //           profilePicUrl: "event.docs[i]['profilePicUrl']",
  //         ),
  //       );
  //       setState(() {
  //         joinedUsers++;
  //       });
  //
  //       // checkForCompanionsJoined(true, selectedUsers.length);
  //     }
  //   });
  // }

  // void checkForCompanionsJoined(bool wait, int len) async {
  //   if (wait && selectedUsers.length > 4) {
  //     checkForGroupAndCreateGroup();
  //   } else if (!wait) {
  //     checkForGroupAndCreateGroup();
  //   }
  // }
  //
  // void checkForGroupAndCreateGroup() async {
  //   if (selectedUsers.isEmpty) return;
  //   print(selectedUsers[0].userId);
  //   for (int i = 0; i < 4; i++) {
  //     if (selectedUsers[0].userId == user!.phoneNumber) {
  //       await db
  //           .collection("groups")
  //           .doc(selectedUsers[0].userId)
  //           .set({"ownerId": selectedUsers[0].userId});
  //       if (!mounted) return;
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ChatRoomScreen(
  //             userId: selectedUsers[0].userId,
  //             groupId: selectedUsers[0].userId,
  //           ),
  //         ),
  //       );
  //       return;
  //     } else {
  //       final tempUserId = selectedUsers[i].userId;
  //       db.collection("groups").doc(tempUserId).get().then((value) {
  //         if (value.exists) {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => ChatRoomScreen(
  //                 userId: user!.phoneNumber!,
  //                 groupId: tempUserId,
  //               ),
  //             ),
  //           );
  //         }
  //       });
  //     }
  //   }
  // }

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
                    onPressed: () async {
                      // grouped = true;
                      // for (int i = 0; i < selectedUsers.length; i++) {
                      //   if (i == 0) {
                      //     await db
                      //         .collection("users")
                      //         .doc(selectedUsers[0].userId)
                      //         .update({
                      //       "grouped": true,
                      //       "groupId": selectedUsers[0].userId
                      //     });
                      //     groupId = selectedUsers[0].userId;
                      //   } else {
                      //     await db
                      //         .collection("users")
                      //         .doc(selectedUsers[i].userId)
                      //         .update({
                      //       "grouped": true,
                      //       "groupId": selectedUsers[0].userId
                      //     });
                      //     groupId = selectedUsers[i].userId;
                      //   }
                      // }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            userId: user!.phoneNumber!,
                            groupId: groupId,
                          ),
                        ),
                      );
                    },
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
