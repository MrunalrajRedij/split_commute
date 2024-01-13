import 'package:flutter/material.dart';
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/values.dart' as values;
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/screens/searchCompanionScreen.dart';

class SearchTaxiDriver extends StatefulWidget {
  const SearchTaxiDriver({super.key});

  @override
  State<SearchTaxiDriver> createState() => _SearchTaxiDriverState();
}

class _SearchTaxiDriverState extends State<SearchTaxiDriver> {
  late AnimationController _controller;
  bool hidden = true;


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
                  "Searching Ride...",
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
                    onPressed: () {},
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
