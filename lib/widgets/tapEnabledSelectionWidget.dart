import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/decorations.dart' as decoration;

//reusable selection Widget
class TapEnabledSelectionWidget extends StatefulWidget {
  String selectionString;
  bool isSelected;
  int? id;
  TapEnabledSelectionWidget(
      {Key? key,
      required this.selectionString,
      required this.isSelected,
      this.id})
      : super(key: key);

  @override
  State<TapEnabledSelectionWidget> createState() =>
      _TapEnabledSelectionWidgetState();
}

class _TapEnabledSelectionWidgetState extends State<TapEnabledSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10),
      child: GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isSelected ? palette.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(decoration.boxBorderRadius),
            border: Border.all(
                color: widget.isSelected ? palette.primaryColor : Colors.black),
          ),
          child: Text(
            widget.selectionString,
            style: TextStyle(
              fontSize: 12.sp,
              color: widget.isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
        onTap: () {
          setState(() {
            if (!widget.isSelected) {
              widget.isSelected = true;
            } else {
              widget.isSelected = false;
            }
          });
        },
      ),
    );
  }
}
