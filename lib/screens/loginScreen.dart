import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:split_commute/screens/otpAuthScreen.dart';
import 'package:split_commute/widgets/policyDialog.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:split_commute/config/decorations.dart' as decoration;

import 'package:split_commute/config/palette.dart' as palette;

//this screen is used to login user in app
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isTermsOfServiceAgreed = false;
  String phoneNumber = "";
  int minPhoneLength = 0;
  int maxPhoneLength = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    scale: 5,
                  ),
                  const SizedBox(height: 50),
                  //text-field to enter country code and phone number
                  IntlPhoneField(
                    inputFormatters: [
                      //for below version 2
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      // for version 2 and greater
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: decoration.tileHeading14TS,
                    dropdownTextStyle: decoration.tileHeading14TS,
                    decoration: InputDecoration(
                      hintText: 'Enter Phone Number',
                      hintStyle: decoration.hint14TS,
                      contentPadding: const EdgeInsets.only(
                          top: 15), //content padding issue
                      // labelText: "Enter Phone Number",
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(decoration.boxBorderRadius),
                        borderSide: const BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                    dropdownIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueGrey,
                    ),
                    controller: phoneController,
                    disableLengthCheck: false,
                    initialCountryCode: 'IN',
                    onCountryChanged: (country) {
                      phoneController.text = "";
                      minPhoneLength =
                          country.minLength + 1 + country.dialCode.length;
                      maxPhoneLength =
                          country.maxLength + 1 + country.dialCode.length;
                    },
                    onChanged: (phone) {
                      phoneNumber = phone.completeNumber;
                    },
                  ),
                  decoration.sizedBoxWithHeight5,
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(decoration.boxBorderRadius),
                        ),
                      ),
                      onPressed: () async {
                        Country initialCountry = countries
                            .singleWhere((element) => element.code == "IN");

                        //to check min and max length of phone for validation
                        if (minPhoneLength == 0) {
                          minPhoneLength = initialCountry.minLength +
                              1 +
                              initialCountry.dialCode.length;
                        } //Total Length of "+" + "DialCode" + "phoneNumber"
                        if (maxPhoneLength == 0) {
                          maxPhoneLength = initialCountry.maxLength +
                              1 +
                              initialCountry.dialCode.length;
                        } //Total Length of "+" + "DialCode" + "phoneNumber"

                        if (!isTermsOfServiceAgreed) {
                          //show dialog if check box is not selected
                          showAlertDialog(
                              'Please agree to our terms and conditions by clicking on checkbox');
                        } else if (phoneNumber.length < minPhoneLength ||
                            phoneNumber.length > maxPhoneLength) {
                          //show dialog if phone number is invalid
                          showAlertDialog('Please enter a valid Phone Number ');
                        } else {
                          //if phone is valid and everything check out,then pass phone num to otpScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtpAuthScreen(phoneNumber: phoneNumber),
                            ),
                          );
                        }
                      },
                      child: Text('CONNECT', style: decoration.whiteBold14TS),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(
                        value: isTermsOfServiceAgreed,
                        onChanged: (value) {
                          setState(() {
                            isTermsOfServiceAgreed = value!;
                          });
                        },
                      ),

                      //show terms and condition widget
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "I agree to GoNews's ",
                                  style: decoration.tileHeading14TS),
                              TextSpan(
                                text: "Terms of Service ",
                                style: decoration.blueBold15TS,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    showDialog(context: context, builder: (context){
                                      return PolicyDialog(mdFileName: 'tos.md');
                                    });
                                  },
                              ),
                              TextSpan(
                                  text: "and acknowledge that I have read the ",
                                  style: decoration.tileHeading14TS),
                              TextSpan(
                                text: "Privacy Policy",
                                style: decoration.blueBold15TS,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    showDialog(context: context, builder: (context){
                                      return PolicyDialog(mdFileName: 'privacy-policy.md');
                                    });
                                  },
                              ),
                              TextSpan(
                                text: ".",
                                style: decoration.tileHeading14TS,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //show msg through alert dialog
  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: const Text('Message'),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'))
          ],
        );
      },
    );
  }
}