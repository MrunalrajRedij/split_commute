import 'package:flutter/material.dart';

// Primary Color - #1d3abb
// Bg-light color - #F1EFFF
// Text color - #202020


//this contains all color related values. (Note: not all the values are here some are directly coded into screen page)

//int and map for making primary swatch (for theme on main page)
const Map<int, Color> persianColorMap =
{
  50:Color.fromRGBO(28, 57, 187, .1),
  100:Color.fromRGBO(28, 57, 187, .2),
  200:Color.fromRGBO(28, 57, 187, .3),
  300:Color.fromRGBO(28, 57, 187, .4),
  400:Color.fromRGBO(28, 57, 187, .5),
  500:Color.fromRGBO(28, 57, 187, .6),
  600:Color.fromRGBO(28, 57, 187, .7),
  700:Color.fromRGBO(28, 57, 187, .8),
  800:Color.fromRGBO(28, 57, 187, .9),
  900:Color.fromRGBO(28, 57, 187, 1),
};
const int primaryColorInt = 0xFF1C39BB;

//basic colors
//white color
const Color whiteColor = Colors.white;
//green color
const Color greenColor = Colors.green;
//green accent
const Color greenAccentColor = Colors.greenAccent;
//Pink color
const Color pinkColor = Colors.pink;
//grey Color
const Color greyColor = Colors.grey;
//amber color
const Color amberColor = Colors.amber;
//red color
const Color redColor = Colors.red;
//teal color
const Color tealColor = Colors.teal;


//custom colors
//scaffold bg color
final Color? scaffoldBgColor = Colors.grey[300];

//primaryColor -- Royal blue
const Color primaryColor = Color(0xFF1C39BB);

//Text-field grey color
const Color textFieldGreyColor = Color(0xFFDCDCDC);

//colors used for different headings
const Color darkGreyColor = Color(0xFF464646);
const Color lightBlackColor = Color(0xFF535353);