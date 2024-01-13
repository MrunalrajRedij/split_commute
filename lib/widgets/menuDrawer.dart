import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/values.dart' as values;
import 'package:split_commute/utils/utilFunctions.dart';

class MenuDrawer extends Drawer {
  const MenuDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Flexible(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    'assets/images/bannerTransparent.png',
                    scale: 4,
                  ),
                ),
                const Divider(
                  height: 2,
                ),
                //home screen btn
                ListTile(
                  horizontalTitleGap: 10,
                  leading: const Icon(Icons.home),
                  title: Text(
                    'Home',
                    style: decoration.lightBlackHeading12TS,
                  ),
                  onTap: () => changeScreenFunc(context, "/HomeScreen"),
                ),
                //profile screen btn
                ListTile(
                  horizontalTitleGap: 10,
                  leading: const Icon(
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
                  horizontalTitleGap: 10,
                  leading: const Icon(Icons.policy),
                  title: Text(
                    'Privacy Policy',
                    style: decoration.lightBlackHeading12TS,
                  ),
                  onTap: () {
                    UtilFunctions().privacyPolicyWidget(context);
                  },
                ),

                //refer a friend screen btn
                ListTile(
                  horizontalTitleGap: 10,
                  leading: const Icon(Icons.share),
                  title: Text(
                    'Refer A Friend',
                    style: decoration.lightBlackHeading12TS,
                  ),
                  onTap: () {
                    Share.share('Check out this App:\n'
                        'https://play.google.com/store/apps/details?id=com.mobile.split_commute');
                  },
                ),

                //support screen btn
                ListTile(
                  horizontalTitleGap: 10,
                  leading: const Icon(Icons.support_agent),
                  title: Text(
                    'Support/Help',
                    style: decoration.lightBlackHeading12TS,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    UtilFunctions()
                        .showScaffoldMsg(context, "Soon to be added!!!");
                  },
                ),

                //logout btn
                ListTile(
                  horizontalTitleGap: 10,
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primaryColor,
                  foregroundColor: palette.whiteColor,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                    30,
                  ))),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return addCreditsAlertDialog(context);
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/donateIcon.png',
                      scale: 20,
                      color: palette.whiteColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Want to Support?',
                      style: decoration.whiteBold16TS,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
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

  //alert dialog so user can credits
  AlertDialog addCreditsAlertDialog(context) {
    String toBeCreditedAmount = "10";
    TextEditingController creditAmountController = TextEditingController();

    Razorpay razorpay;
    String showSelectedCredits = "10";
    void handlePaymentSuccess(PaymentSuccessResponse response) async {
      Navigator.pop(context);
      UtilFunctions().showScaffoldMsg(context, "Payment Successful!");
    }

    void handlePaymentError(PaymentFailureResponse response) {
      Navigator.pop(context);
      UtilFunctions()
          .showScaffoldMsg(context, response.message ?? "Error: Try Again!");
    }

    //create razorPay instance
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);

    void openCheckout(int amount) async {
      var options = {
        'key': values.api_key,
        'amount': amount,
        'description': "",
        'timeout': 300, // in seconds
        'prefill': {
          'contact': FirebaseAuth.instance.currentUser?.phoneNumber,
        }
      };
      try {
        razorpay.open(options);
      } catch (e) {
        print(e);
      }
    }

    return AlertDialog(
      actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      backgroundColor: palette.scaffoldBgColor,
      content: SingleChildScrollView(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Amount in Rs. to Donate',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: palette.primaryColor),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 50,
                  decoration: ShapeDecoration(
                    color: palette.whiteColor,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1.0,
                            style: BorderStyle.solid,
                            color: Colors.grey),
                        borderRadius:
                            BorderRadius.circular(decoration.boxBorderRadius)),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: DropdownButton<String>(
                      underline: const SizedBox(),
                      //for removing underline from drop down btn
                      isExpanded: true,
                      value: showSelectedCredits,
                      items: <String>[
                        '10',
                        '20',
                        '50',
                        '100',
                        '200',
                        '500',
                        '1000',
                        '2000'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          showSelectedCredits = value!;
                          creditAmountController.text = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: creditAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    //for below version 2
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    // for version 2 and greater
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    fillColor: palette.whiteColor,
                    filled: true,
                    prefixIcon: const Icon(Icons.currency_rupee),
                    labelText: 'Add Custom Amount',
                    contentPadding: const EdgeInsets.only(top: 15),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(decoration.boxBorderRadius),
                      borderSide: const BorderSide(
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            "PROCEED TO DONATE",
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () {
            if (creditAmountController.text.isNotEmpty) {
              toBeCreditedAmount = creditAmountController.text;
            }
            print(toBeCreditedAmount);
            openCheckout(int.parse(toBeCreditedAmount) * 100);
          },
        ),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );
  }
}
