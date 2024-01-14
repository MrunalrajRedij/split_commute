import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/values.dart' as values;
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/screens/chatRoomScreen.dart';
import 'package:split_commute/utils/models/userModel.dart';
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
  // List<UserModel> userModels = [];
  List<UserModel> selectedUsers = [];
  int joinedUsers = 1;
  String groupId = "";
  int roomId = 0;
  String userName = "";
  bool grouped = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    generateUserDoc(user!.phoneNumber!);
    getUserInfo();
  }

  void getUserInfo() {
    db.collection("users").doc(user!.phoneNumber).get().then((value) {
      userName = value["userName"];
    });
  }

  void exp() async {
    while (true) {
      await db.collection("groups").doc(groupId).get().then((value) {
        setState(() {
          joinedUsers = value['count'];
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
    roomId = Random().nextInt(10000);
    while (groupId == "") {
      String tempGroupId = "${widget.startingPoint}-${widget.endingPoint}-$i";
      await db.collection("groups").doc(tempGroupId).get().then((value) async {
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
                  .get()
                  .then((value1) async {
                if (value1["groupId"] == tempGroupId) {
                } else {
                  String temp = "";
                  await db
                      .collection("users")
                      .doc(user!.phoneNumber)
                      .get()
                      .then((value) {
                    temp = value["groupId"];
                  });
                  if (temp == tempGroupId) {}
                  await db.collection("users").doc(user!.phoneNumber).update({
                    "groupId": tempGroupId,
                  });
                  groupId = tempGroupId;
                  tempCount++;
                  await db
                      .collection('groups')
                      .doc(tempGroupId)
                      .set({"count": tempCount});
                  setState(() {
                    loading = false;
                  });
                  sendCloseMessage();
                  Future.delayed(const Duration(milliseconds: 2000))
                      .then((value) {
                    routeToChatScreen();
                  });
                  return;
                }
              });
            }
          });
        } else {
          await db.collection('groups').doc(tempGroupId).set({"count": 1});
          await db
              .collection('groups')
              .doc(tempGroupId)
              .collection('messages')
              .doc()
              .set({
            'recentMessage': "",
            'recentMessageSender': "",
            'recentMessageTime': "",
          });
          await db.collection("users").doc(user!.phoneNumber).update({
            "groupId": tempGroupId,
          });
          groupId = tempGroupId;
          setState(() {
            loading = false;
          });
          sendCloseMessage();
          Future.delayed(const Duration(milliseconds: 2000)).then((value) {
            routeToChatScreen();
          });
          return;
        }
      });
      i++;
      print("//////" + groupId);
      exp();
    }
  }

  sendCloseMessage() {
    Map<String, dynamic> chatMessageMap = {
      "message": "$userName has joined",
      "sender": userName,
      'time': DateTime.now().millisecondsSinceEpoch,
      'hasLeft': true,
      'hasJoined': true,
    };
    db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(chatMessageMap);

    db.collection('groups').doc(groupId).update({
      'recentMessage': chatMessageMap['message'],
      'recentMessageSender': chatMessageMap['sender'],
      'recentMessageTime': chatMessageMap['time'].toString(),
    });
  }

  void routeToChatScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          userId: user!.phoneNumber!,
          groupId: groupId,
          startingPoint: widget.startingPoint,
          endingPoint: widget.endingPoint,
          userName: userName,
        ),
      ),
    );
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
    return WillPopScope(
      onWillPop: () {
        Navigator.pushNamedAndRemoveUntil(
            context, "/HomeScreen", (route) => false);
        return Future(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: palette.primaryColor,
          foregroundColor: palette.scaffoldBgColor,
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
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
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/radar.png')),
                  ),
                  child: RadarSignal(
                    controller: _controller,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: !loading
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 40),
                            child: Text(
                              "ChatRoom joined...",
                              style: decoration.whiteBold18TS,
                            )
                            // ElevatedButton(
                            //   style: ElevatedButton.styleFrom(
                            //       backgroundColor: palette.greenColor,
                            //       foregroundColor: palette.whiteColor,
                            //       elevation: 10,
                            //       shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(
                            //         30,
                            //       ))),
                            //   onPressed: () async {
                            //     // grouped = true;
                            //     // for (int i = 0; i < selectedUsers.length; i++) {
                            //     //   if (i == 0) {
                            //     //     await db
                            //     //         .collection("users")
                            //     //         .doc(selectedUsers[0].userId)
                            //     //         .update({
                            //     //       "grouped": true,
                            //     //       "groupId": selectedUsers[0].userId
                            //     //     });
                            //     //     groupId = selectedUsers[0].userId;
                            //     //   } else {
                            //     //     await db
                            //     //         .collection("users")
                            //     //         .doc(selectedUsers[i].userId)
                            //     //         .update({
                            //     //       "grouped": true,
                            //     //       "groupId": selectedUsers[0].userId
                            //     //     });
                            //     //     groupId = selectedUsers[i].userId;
                            //     //   }
                            //     // }
                            //
                            //     Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => ChatRoomScreen(
                            //           userId: user!.phoneNumber!,
                            //           groupId: groupId,
                            //           startingPoint: widget.startingPoint,
                            //           endingPoint: widget.endingPoint,
                            //           userName: userName,
                            //         ),
                            //       ),
                            //     );
                            //   },
                            //   child: Text(
                            //     'Proceed',
                            //     style: decoration.whiteBold16TS,
                            //   ),
                            // ),
                            )
                        : const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: CircularProgressIndicator(
                              color: palette.greenColor,
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RadarSignal extends StatefulWidget {
  final AnimationController controller;
  const RadarSignal({
    super.key,
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
        const Align(
          alignment: Alignment(-0.55, -0.3),
          child: RadarAvatarWidget(
            path: values.womanProfilePicLink,
          ),
        ),
        const Align(
          alignment: Alignment(0.35, -0.2),
          child: RadarAvatarWidget(
            path: values.girlProfilePicLink,
          ),
        ),
        const Align(
          alignment: Alignment(-0.4, 0.25),
          child: RadarAvatarWidget(
            path: values.boyProfilePicLink,
          ),
        ),
        const Align(
          alignment: Alignment(0.6, 0.35),
          child: RadarAvatarWidget(
            path: values.manProfilePicLink,
          ),
        ),
        RotationTransition(
          turns: Tween(begin: 0.0, end: 3.0).animate(widget.controller),
          child: Container(
            decoration: const BoxDecoration(
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
