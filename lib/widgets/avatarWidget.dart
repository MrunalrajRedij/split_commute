import 'package:flutter/material.dart';
import 'package:split_commute/config/palette.dart' as palette;

//avatar widgets
class AvatarWidget extends StatefulWidget {
  final avatarImage;
  bool selected = false;
  AvatarWidget({Key? key, this.avatarImage, required this.selected})
      : super(key: key);

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      // show bg color based on selected bool
      backgroundColor: widget.selected
          ? palette.primaryColor
          : palette.textFieldGreyColor,
      child: CircleAvatar(
        radius: 37,
        backgroundColor: palette.textFieldGreyColor,
        child: widget.avatarImage,
      ),
    );
  }
}