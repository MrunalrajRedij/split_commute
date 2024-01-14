import 'package:flutter/material.dart';
import 'package:split_commute/config/palette.dart' as palette;

class MessageTile extends StatelessWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final bool hasLeft;
  final bool hasJoined;

  const MessageTile({
    super.key,
    required this.message,
    required this.sender,
    required this.sentByMe,
    required this.hasLeft,
    required this.hasJoined,
  });

  @override
  Widget build(BuildContext context) {
    return (hasLeft || hasJoined)
        ? Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23),
                    bottomRight: Radius.circular(23),
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          )
        : Container(
            padding: EdgeInsets.only(
                top: 10,
                bottom: 4,
                left: sentByMe ? 0 : 15,
                right: sentByMe ? 15 : 0),
            alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: sentByMe
                  ? const EdgeInsets.only(left: 30)
                  : const EdgeInsets.only(right: 30),
              padding: const EdgeInsets.only(
                  top: 10, bottom: 17, left: 20, right: 20),
              decoration: BoxDecoration(
                borderRadius: sentByMe
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomLeft: Radius.circular(23))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomRight: Radius.circular(23)),
                color: sentByMe ? Colors.blueAccent : Colors.grey[700],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(sender.toUpperCase(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(message,
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontSize: 18, color: palette.whiteColor)),
                ],
              ),
            ),
          );
  }
}
