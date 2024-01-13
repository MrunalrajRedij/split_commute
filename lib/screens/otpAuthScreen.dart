import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:split_commute/Screens/loginScreen.dart';
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/utils/utilFunctions.dart';

//after login screen show this screen for authentication through OTP
class OtpAuthScreen extends StatefulWidget {
  final phoneNumber;
  const OtpAuthScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OtpAuthScreen> createState() => _OtpAuthScreenState();
}

class _OtpAuthScreenState extends State<OtpAuthScreen> {
  String otpCodeString = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = "";
  int? resendToken;
  int _seconds = 60;
  Timer? timer;
  String resendTime = "";

  //this bool is used to determine when there is loading
  bool isCheckingOTP = false;

  @override
  void initState() {
    super.initState();
    //check phone number with incoming OTP
    phoneNumberVerificationFunc();
    //start timer for resending OTP
    startTimer();
  }

  //func for starting timer for resending OTP
  //check logic
  void startTimer() {
    _seconds = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
          if (_seconds < 10) {
            resendTime = '00:0$_seconds Sec';
          } else {
            resendTime = '00:$_seconds Sec';
          }
        } else {
          timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  //func to send OTP for verification
  void phoneNumberVerificationFunc() async {
    //bool is implemented for circularLoadingIndicator
    setState(() {
      isCheckingOTP = true;
    });

    //firebase phone verify func
    await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (phoneAuthCredential) async {
          //automatic OTP verification callback
          //signIn in firebase
          signInWithCredentialFunc(phoneAuthCredential);
        },
        verificationFailed: (verificationFailed) async {
          //if verification failed
          //we can still Check the otp from use if it fails
          setState(() {
            isCheckingOTP = false;
          });
          //show message from firebase
          UtilFunctions().showScaffoldMsg(context, verificationFailed.message!);
        },
        codeSent: (verificationId, resendingToken) async {
          //on successful otp sent
          setState(() {
            isCheckingOTP = false;
          });
          //store it in var for further implementation
          this.verificationId = verificationId;
          resendToken = resendingToken;
        },
        codeAutoRetrievalTimeout: (verificationId) async {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  decoration.sizedBoxWithHeight10,
                  isCheckingOTP
                      ?
                      //show loading widget, whenever there is loading
                      const SpinKitWave(
                          color: palette.primaryColor,
                          size: 25,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                scale: 3,
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Enter the OTP sent to  ${widget.phoneNumber}',
                                  style: decoration.tileHeading20TS,
                                ),
                              ),
                              decoration.sizedBoxWithHeight10,
                              //widget for inputting OTP
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: PinCodeTextField(
                                  keyboardType: TextInputType.number,
                                  appContext: context,
                                  length: 6,
                                  pinTheme: PinTheme(
                                    selectedFillColor: palette.primaryColor,
                                    activeColor: palette.primaryColor,
                                    selectedColor: palette.pinkColor,
                                    inactiveColor: palette.primaryColor,
                                    fieldWidth: 30.w,
                                  ),
                                  onChanged: (value) {
                                    otpCodeString = value;
                                  },
                                ),
                              ),
                              decoration.sizedBoxWithHeight5,
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: palette.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        decoration.boxBorderRadius,
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    //otp verification with phoneAuthCredential
                                    signInWithPhoneAuthCredential();
                                  },
                                  child: Text(
                                    'VERIFY OTP',
                                    style: decoration.whiteBold14TS,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  (_seconds != 0)
                                      ?
                                      //show timer
                                      Text(
                                          resendTime,
                                          style: decoration
                                              .resendAndEditPhoneTextStyle,
                                        )
                                      :
                                      //if timer is completed, show resend btn
                                      GestureDetector(
                                          child: Text(
                                            'Resend OTP',
                                            style: decoration
                                                .resendAndEditPhoneTextStyle,
                                          ),
                                          onTap: () {
                                            resendVerificationCode(
                                              widget.phoneNumber,
                                              resendToken,
                                            );
                                            startTimer();
                                          },
                                        ),

                                  //edit phone number btn, so that user can go back to login screen to change phone number
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Edit Phone number',
                                      style: decoration
                                          .resendAndEditPhoneTextStyle,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //func to resend OTP for verification
  //we have used two different func to send and resend OTP because resend token.
  // We get resend token from sending first OTP func, we used that in resend OTP func
  void resendVerificationCode(String phoneNumber, int? token) async {
    setState(() {
      isCheckingOTP = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (phoneAuthCredential) async {
        //automatic OTP verification callback
        //signIn in firebase
        signInWithCredentialFunc(phoneAuthCredential);
      },
      verificationFailed: (verificationFailed) async {
        //if verification failed
        //we can still Check the otp from use if it fails
        setState(() {
          isCheckingOTP = false;
        });
        //show message from firebase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verificationFailed.message!),
          ),
        );
      },
      codeSent: (verificationId, resendingToken) async {
        //on successful otp sent
        setState(() {
          isCheckingOTP = false;
        });
        //store it in var for further implementation
        this.verificationId = verificationId;
        resendToken = resendingToken;
      },
      forceResendingToken: resendToken,
      codeAutoRetrievalTimeout: (verificationId) async {},
    );
  }

  //func for otp verification with phoneAuthCredential
  void signInWithPhoneAuthCredential() async {
    //bool is implemented for circularLoadingIndicator
    setState(() {
      isCheckingOTP = true;
    });

    try {
      //get otpString to phoneAuthCredential object
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCodeString,
      );
      //signIn in firebase
      signInWithCredentialFunc(phoneAuthCredential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        isCheckingOTP = false;
      });
      //show error message from firebase
      UtilFunctions().showScaffoldMsg(context, e.message.toString());
    }
  }

  //func for signIn in Firebase
  void signInWithCredentialFunc(phoneAuthCredential) async {
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      if (authCredential.user != null) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, "/HomeScreen", (route) => false);
      }
    } catch (error) {
      setState(() {
        setState(() {
          isCheckingOTP = false;
        });
      });
      if (!mounted) return;
      //if error, show scaffold msg with firebase error response
      UtilFunctions().showScaffoldMsg(context, error.toString());
    }
  }
}
