import 'package:flutter/material.dart';
import 'package:split_commute/config/palette.dart' as palette;
import 'package:flutter_screenutil/flutter_screenutil.dart';

//different types of repeated const values for UI (Note: not all the values are here some are directly coded into screen page)

//radius for theme specific rectangular boxes ex. Buttons, textfields, containers
const double boxBorderRadius = 5.0;
//horizontalBtnSize
const double btnHeight = 40;
//sizedBoxes
const Widget sizedBoxWithHeight5 = SizedBox(height: 5);
const Widget sizedBoxWithHeight8 = SizedBox(height: 8);
const Widget sizedBoxWithHeight10 = SizedBox(height: 10);

//text-styles
//separate TS
TextStyle aboutTS = TextStyle(
  height: 1.5,
  letterSpacing: 0.2,
  fontWeight: FontWeight.bold,
  fontSize: 12.sp,
  color: palette.lightBlackColor,
);
TextStyle msgDeletedTS = TextStyle(
  decoration: TextDecoration.lineThrough,
  decorationThickness: 2,
  color: palette.lightBlackColor,
  fontSize: 12.sp,
);
TextStyle slotRejectedTS = TextStyle(
    decoration: TextDecoration.lineThrough,
    decorationThickness: 2.5,
    color: palette.lightBlackColor,
    fontSize: 14.sp,
    fontWeight: FontWeight.bold);

TextStyle hint14TS = TextStyle(fontSize: 14.sp);

const TextStyle spiconnProStatus3TS = TextStyle(
  color: Colors.green,
  fontWeight: FontWeight.bold,
);
//custom textStyle for resend and edit phone button on OtpAuthPage
TextStyle resendAndEditPhoneTextStyle = TextStyle(
  shadows: const [Shadow(color: palette.primaryColor, offset: Offset(0, -5))],
  color: Colors.transparent,
  decoration: TextDecoration.underline,
  decorationColor: palette.primaryColor,
  fontSize: 16.sp,
  fontWeight: FontWeight.bold,
);

//normalStyle text
TextStyle normal12TS = TextStyle(fontSize: 12.sp);
TextStyle normal14TS = TextStyle(fontSize: 14.sp);
TextStyle normal18TS = TextStyle(fontSize: 18.sp);

//lightblack tile heading text
TextStyle lightBlackHeading12TS = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12.sp,
    color: palette.lightBlackColor);
TextStyle lightBlackHeading14TS = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14.sp,
    color: palette.lightBlackColor);
TextStyle lightBlackHeading16TS = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.sp,
    color: palette.lightBlackColor);
TextStyle lightBlackHeading25TS = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 25.sp,
    color: palette.lightBlackColor);

//black tile heading text
TextStyle tileHeading12TS = TextStyle(
    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12.sp);
TextStyle tileHeading13TS = TextStyle(
    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.sp);
TextStyle tileHeading14TS = TextStyle(
    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.sp);
TextStyle tileHeading16TS = TextStyle(
    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp);
TextStyle tileHeading20TS = TextStyle(
    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.sp);

//grey small TS
TextStyle blueGreyBold10TS = TextStyle(
    color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 10.sp);
TextStyle blueGreyBold12TS = TextStyle(
    color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 12.sp);
TextStyle blueGreyBold15TS = TextStyle(
    color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 15.sp);

//redHeading text
TextStyle redBold14TS = TextStyle(
    fontWeight: FontWeight.bold, color: palette.redColor, fontSize: 14.sp);
TextStyle redBold12TS = TextStyle(
    fontWeight: FontWeight.bold, color: palette.redColor, fontSize: 12.sp);

//pinkBoldTS
TextStyle pinkBold14TS = TextStyle(
    fontWeight: FontWeight.bold, color: palette.pinkColor, fontSize: 14.sp);
TextStyle pinkBold20TS = TextStyle(
    fontWeight: FontWeight.bold, color: palette.pinkColor, fontSize: 20.sp);

//blueHeading text
TextStyle blueBold12TS = TextStyle(
    color: palette.primaryColor, fontWeight: FontWeight.bold, fontSize: 12.sp);
TextStyle blueBold14TS = TextStyle(
    color: palette.primaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp);
TextStyle blueBold15TS = TextStyle(
    color: palette.primaryColor, fontWeight: FontWeight.bold, fontSize: 15.sp);
TextStyle blueBold18TS = TextStyle(
    color: palette.primaryColor, fontWeight: FontWeight.bold, fontSize: 18.sp);
TextStyle blueBold20TS = TextStyle(
    color: palette.primaryColor, fontWeight: FontWeight.bold, fontSize: 20.sp);
TextStyle blueBold30TS = TextStyle(
    fontWeight: FontWeight.bold, color: palette.primaryColor, fontSize: 30.sp);

//whiteBtnText
TextStyle whiteBold10TS = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.sp);
TextStyle whiteBold12TS = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp);
TextStyle whiteBold14TS = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp);
TextStyle whiteBold16TS = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp);
TextStyle whiteBold18TS = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp);
TextStyle whiteBold25TS = TextStyle(
    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25.sp);

//TEXT-STYLES:
//general text with blue color
const TextStyle normalBlueText = TextStyle(color: palette.primaryColor);
//general white small roboto ts
TextStyle smallWhiteTS = TextStyle(fontSize: 15.sp, color: Colors.white);
//general white large roboto-bold ts
TextStyle largeWhiteTS = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 30.sp, color: Colors.white);
//general small roboto-bold ts
TextStyle lightSmallRobotoBoldTS = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15.sp,
    color: palette.lightBlackColor);
//general light-black semi large roboto-bold ts
TextStyle lightRobotoBoldTS = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 17.sp,
    color: palette.lightBlackColor);
//general black semi large roboto-bold ts

TextStyle robotoBoldTS =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp);
//Large blueHeadingTS
TextStyle blueHeadingTS = TextStyle(
    fontWeight: FontWeight.bold, color: palette.primaryColor, fontSize: 35.sp);
//medium heading ts
TextStyle mediumBlueHeadingTS = TextStyle(
    fontWeight: FontWeight.bold, color: palette.primaryColor, fontSize: 25.sp);

//test styles used for privacyPolicy text on LoginPage
TextStyle defaultPrivacyPolicyTextStyle = TextStyle(
    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp);
TextStyle linkedPrivacyPolicyTextStyle = TextStyle(
    color: palette.primaryColor, fontWeight: FontWeight.bold, fontSize: 16.sp);

//TS for semi bold headings
TextStyle mediumBlackBoldText = TextStyle(
  fontSize: 16.sp,
  fontWeight: FontWeight.bold,
);

//By Screen textStyles

//userList screen
//TS for filter tile text for userListScreen
TextStyle userListFilterTilesText = TextStyle(
    color: palette.whiteColor, fontWeight: FontWeight.bold, fontSize: 16.sp);
//TS for filter tile text for userListScreen
TextStyle spiConnProRequestValueStyle = TextStyle(
    color: palette.lightBlackColor,
    fontWeight: FontWeight.bold,
    fontSize: 16.sp);
//TS for widget tile text for userListScreen
TextStyle userListWidgetBlueText = TextStyle(
    color: palette.primaryColor, fontWeight: FontWeight.bold, fontSize: 20.sp);

//history screen
//history column title
TextStyle historyColumnTitle = TextStyle(
  color: palette.whiteColor,
  fontWeight: FontWeight.bold,
  fontSize: 15.sp,
);
//Ts for historyScreen column
TextStyle historyListHeadingTS = TextStyle(
  color: palette.whiteColor,
  fontWeight: FontWeight.bold,
  fontSize: 14.sp,
);
