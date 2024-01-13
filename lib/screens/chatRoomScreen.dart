import 'package:split_commute/config/palette.dart' as palette;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_commute/widgets/messageTile.dart';
import 'package:split_commute/config/decorations.dart' as decoration;

class ChatRoomScreen extends StatefulWidget {
  final String startingPoint;
  final String endingPoint;
  final String groupId;
  final String userId;
  final String userName;
  const ChatRoomScreen({
    super.key,
    required this.groupId,
    required this.userId,
    required this.startingPoint,
    required this.endingPoint,
    required this.userName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = TextEditingController();
  bool priceExpanded = false;
  @override
  void initState() {
    super.initState();
    setChat();
  }

  void setChat() async {
    final val = db
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
    setState(() {
      chats = val;
    });
  }

  Widget _chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data!.docs[index]["message"],
                    sender: snapshot.data?.docs[index]["sender"],
                    sentByMe:
                        widget.userName == snapshot.data?.docs[index]["sender"],
                  );
                })
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      db
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .add(chatMessageMap);

      db.collection('groups').doc(widget.groupId).update({
        'recentMessage': chatMessageMap['message'],
        'recentMessageSender': chatMessageMap['sender'],
        'recentMessageTime': chatMessageMap['time'].toString(),
      });

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

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
          title: const Text("Chat Room"),
          centerTitle: true,
          backgroundColor: palette.primaryColor,
          foregroundColor: palette.whiteColor,
          elevation: 0.0,
          actions: [
            ElevatedButton(
              onPressed: () async {
                //await
                db.collection("users").doc(widget.userId).update({
                  "grouped": false,
                  "groupId": "",
                  "startingPoint": "",
                  "endingPoint": "",
                  "last": {
                    "startingPoint": widget.startingPoint,
                    "endingPoint": widget.endingPoint,
                  }
                });
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, "/HomeScreen", (route) => false);
              },
              child: const Text("Exit"),
            )
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  Flexible(child: _chatMessages()),
                  Container(
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      color: Colors.grey[300],
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: messageEditingController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  hintText: "Type a message ...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 20,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          GestureDetector(
                            onTap: () {
                              sendMessage();
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(50)),
                              child: const Center(
                                  child: Icon(Icons.send, color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 80),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 600,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        priceExpanded
                            ? Container(
                                width: 250,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: palette.primaryColor,
                                      spreadRadius: 0.5,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Ola : ",
                                          style: decoration.blueGreyBold18TS,
                                        ),
                                        Flexible(
                                          child: Text(
                                            "₹ 100 - ₹ 113",
                                            style: decoration.blueGreyBold18TS,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Uber : ",
                                          style: decoration.blueGreyBold18TS,
                                        ),
                                        Flexible(
                                          child: Text(
                                            "₹ 110 - ₹ 130",
                                            style: decoration.blueGreyBold18TS,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Rapido: ",
                                          style: decoration.blueGreyBold18TS,
                                        ),
                                        Flexible(
                                          child: Text(
                                            "₹ 140 - ₹ 150",
                                            style: decoration.blueGreyBold18TS,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Taxi : ",
                                          style: decoration.blueGreyBold18TS,
                                        ),
                                        Flexible(
                                          child: Text(
                                            "₹ 70 - ₹ 90",
                                            style: decoration.blueGreyBold18TS,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          backgroundColor: palette.primaryColor,
                          onPressed: () {
                            setState(() {
                              priceExpanded = !priceExpanded;
                            });
                          },
                          child: priceExpanded
                              ? const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 45,
                                  color: palette.whiteColor,
                                )
                              : Text(
                                  "₹",
                                  style: decoration.whiteBold25TS,
                                ),
                        ),
                      ],
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
