import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_commute/widgets/messageTile.dart';

class ChatRoomScreen extends StatefulWidget {
  final String groupId;
  final String userId;
  const ChatRoomScreen(
      {super.key, required this.groupId, required this.userId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = TextEditingController();

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

  void joinGroup() async {}

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
                        widget.userId == snapshot.data?.docs[index]["sender"],
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
        "sender": widget.userId,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupId, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black87,
        elevation: 0.0,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            _chatMessages(),
            // Container(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                color: Colors.grey[700],
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageEditingController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Send a message ...",
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                            child: Icon(Icons.send, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
