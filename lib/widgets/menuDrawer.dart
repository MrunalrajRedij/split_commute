import 'package:flutter/material.dart';
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/utils/utilFunctions.dart';
import 'package:split_commute/config/palette.dart' as palette;

String userName = "Logging in...";
String phoneNumber = "";

//menu drawer for navigation between different screens
class MenuDrawer extends Drawer {
  const MenuDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Image.asset(
              'assets/images/bannerTransparent.png',
              scale: 4,
            ),
          ),
          Divider(
            height: 2,
          ),
          //home screen btn
          ListTile(
            horizontalTitleGap: 0,
            leading: const Icon(Icons.home),
            title: Text(
              'Home',
              style: decoration.lightBlackHeading12TS,
            ),
            onTap: () => changeScreenFunc(context, "/HomeScreen"),
          ),

          //list of msg screen btn
          ListTile(
            horizontalTitleGap: 0,
            leading: const Icon(Icons.sms),
            title: Text(
              'Messages',
              style: decoration.lightBlackHeading12TS,
            ),
            onTap: () {
              //if ccLogin then do further process
              changeScreenFunc(context, "/SelectDialogScreen");
            },
          ),

          //history btn
          ListTile(
            horizontalTitleGap: 0,
            leading: const Icon(Icons.history),
            title: Text(
              'My History',
              style: decoration.lightBlackHeading12TS,
            ),
            onTap: () => changeScreenFunc(context, "/HistoryScreen"),
          ),

          //profile screen btn
          ListTile(
            horizontalTitleGap: 0,
            leading: Icon(
              Icons.person,
            ),
            title: Text(
              'My Profile',
              style: decoration.lightBlackHeading12TS,
            ),
            onTap: () => changeScreenFunc(context, "/ProfileScreen"),
          ),
          //privacy policy btn
          ListTile(
            horizontalTitleGap: 0,
            leading: const Icon(Icons.policy),
            title: Text(
              'Privacy Policy',
              style: decoration.lightBlackHeading12TS,
            ),
            onTap: () async {
              Navigator.pop(context);
            },
          ),

          //refer a friend screen btn
          ListTile(
            horizontalTitleGap: 0,
            leading: const Icon(Icons.share),
            title: Text(
              'Refer A Friend',
              style: decoration.lightBlackHeading12TS,
            ),
            onTap: () async {},
          ),

          //support screen btn
          ListTile(
            horizontalTitleGap: 0,
            leading: const Icon(Icons.support_agent),
            title: Text(
              'Support/Help',
              style: decoration.lightBlackHeading12TS,
            ),
            onTap: () => changeScreenFunc(context, "/SupportScreen"),
          ),

          //logout btn
          ListTile(
            horizontalTitleGap: 0,
            leading: const Icon(Icons.logout),
            title: Text(
              'Logout',
              style: decoration.lightBlackHeading12TS,
            ),
            onTap: () {
              //signOut from the firebase and redirect to loginScreen
              UtilFunctions().logOut(context);
            },
          ),
        ],
      ),
    );
  }

  //Routing screen functionality
  void changeScreenFunc(context, routeName) {
    final currentRouteName =
        ModalRoute.of(context)?.settings.name; //get currentScreen

    //check if its on home-screen or not
    final bool isOnHomeScreen =
        currentRouteName == "/HomeScreen" || currentRouteName == "/";

    if (isOnHomeScreen && routeName == "/HomeScreen") {
      //onHomeScreen and trying to get to homeScreen
      Navigator.pop(context); //close the menu
    } else if (isOnHomeScreen && routeName != "/HomeScreen") {
      //onHomeScreen and trying to get to other screen
      Navigator.pushNamed(context, routeName!);
    } else if (currentRouteName == routeName) {
      //trying to get to similar screen
      Navigator.pop(context); //close the menu
    } else if (routeName == "/HomeScreen") {
      //trying to get to homeScreen
      Navigator.pushNamedAndRemoveUntil(
          context, routeName!, (Route<dynamic> route) => false);
    } else {
      //trying to get to other screen
      Navigator.pushReplacementNamed(context, routeName!);
    }
  }
}
