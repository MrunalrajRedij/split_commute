import 'package:flutter/material.dart';
import 'package:split_commute/config/palette.dart' as palette;

class RadarAvatarWidget extends StatefulWidget {
  final String profilePicUrl;
  const RadarAvatarWidget({super.key, required this.profilePicUrl});

  @override
  State<RadarAvatarWidget> createState() => _RadarAvatarWidgetState();
}

class _RadarAvatarWidgetState extends State<RadarAvatarWidget> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 35,
      // show bg color based on selected bool
      backgroundColor: Colors.blueAccent,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: palette.primaryColor,
        child: CircleAvatar(
          backgroundImage: NetworkImage(widget.profilePicUrl),
          radius: 35,
        ),
      ),
    );
  }
}
