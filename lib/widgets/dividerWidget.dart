import 'package:flutter/material.dart';
import 'package:split_commute/config/palette.dart' as palette;

//this class is for placing dividers in between widgets
class DividerWidget extends StatelessWidget {
  const DividerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //simple divider
    return const Divider(color: palette.textFieldGreyColor,thickness: 1.5);
  }
}