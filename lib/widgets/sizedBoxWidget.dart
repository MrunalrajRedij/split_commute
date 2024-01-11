import 'package:flutter/material.dart';

class SizedBoxWidget extends StatelessWidget {
  final double? width;
  final double? height;
  const SizedBoxWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 0,
      height: height ?? 0,
    );
  }
}
