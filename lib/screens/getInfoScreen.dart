import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/screens/homeScreen.dart';
import 'package:split_commute/widgets/avatarWidget.dart';
import 'package:split_commute/widgets/dividerWidget.dart';

//after initial login of the user and if user is new user, this screen shows up to get basic info of the user
class GetInfoScreen extends StatefulWidget {
  const GetInfoScreen({Key? key}) : super(key: key);

  @override
  State<GetInfoScreen> createState() => _GetInfoScreenState();
}

class _GetInfoScreenState extends State<GetInfoScreen> {
  TextEditingController userNameTC = TextEditingController();
  String profileAvatarName = "";
  //booleans for avatar selection
  bool isAvatar1 = false;
  bool isAvatar2 = false;
  bool isAvatar3 = false;
  bool isAvatar4 = false;
  bool isCustomAvatar = false;
  File? image;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    scale: 9,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'How should we call you?',
                      style: decoration.tileHeading16TS,
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                //name text-field
                TextField(
                  controller: userNameTC,
                  style: decoration.normal14TS,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline,
                        color: palette.darkGreyColor),
                    hintText: 'Name',
                    hintStyle: decoration.normal14TS,
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
                const SizedBox(height: 10),
                const DividerWidget(),
                Row(
                  children: [
                    Text(
                      'Choose your avatar',
                      style: decoration.tileHeading16TS,
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                //horizontal list of selecting profile pic, first one is custom img user can upload from files
                //otherwise user can select ready-made profile avatars
                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: () {
                          //selecting this, a interface opens from which user can select the img from file
                          pickImageOptions();
                          //set all other bool to false and custom avatar to true
                          isAvatar1 = false;
                          isAvatar2 = false;
                          isAvatar3 = false;
                          isAvatar4 = false;
                          isCustomAvatar = true;
                          setState(() {});
                        },
                        child: AvatarWidget(
                          avatarImage: (image == null)
                              ?
                              //if img is not selected show icon
                              const Icon(
                                  Icons.add,
                                  size: 45,
                                )
                              :
                              //if img is selected show small preview of img instead of icon
                              CircleAvatar(
                                  backgroundImage: FileImage(image!),
                                  radius: 50,
                                ),
                          selected: isCustomAvatar,
                        ),
                      ),
                      const SizedBox(width: 10),
                      //if any below avatar is selected, set value of respective bool to true and others to false and
                      //set profile path to respective name

                      GestureDetector(
                        onTap: () {
                          if (isAvatar1) {
                            isAvatar1 = false;
                          } else {
                            //set profilePic path
                            profileAvatarName = "";
                            isAvatar1 = true;
                            isAvatar2 = false;
                            isAvatar3 = false;
                            isAvatar4 = false;
                            isCustomAvatar = false;
                          }
                          setState(() {});
                        },
                        child: AvatarWidget(
                          avatarImage: Image.asset('assets/images/logo.png'),
                          selected: isAvatar1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (isAvatar2) {
                            isAvatar2 = false;
                          } else {
                            //set profilePic path
                            profileAvatarName = "";
                            isAvatar1 = false;
                            isAvatar2 = true;
                            isAvatar3 = false;
                            isAvatar4 = false;
                            isCustomAvatar = false;
                          }
                          setState(() {});
                        },
                        child: AvatarWidget(
                          avatarImage: Image.asset('assets/images/logo.png'),
                          selected: isAvatar2,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const DividerWidget(),
                const SizedBox(height: 10),
                loading
                    ?
                    //when loading don't show btn
                    const Center(
                        child: SpinKitWave(
                        color: palette.pinkColor,
                        size: 25,
                      ))
                    :
                    //btn for validating and going to next screen
                    SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  decoration.boxBorderRadius),
                            ),
                          ),
                          onPressed: () async {
                            if (userNameTC.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Enter Valid Name!'),
                                ),
                              );
                            } else if (!isAvatar1 &&
                                !isAvatar2 &&
                                !isAvatar3 &&
                                !isAvatar4 &&
                                !isCustomAvatar) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Select any one Avatar or upload your custom profile pic!'),
                                ),
                              );
                            } else {
                              //starts loading indicator, if everything validates
                              setState(() {
                                loading = true;
                              });

                              String? phoneNumber = FirebaseAuth
                                  .instance.currentUser!.phoneNumber;
                              //update profile
                              FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(phoneNumber)
                                  .set({
                                "userId": phoneNumber,
                                "profilePic": "",
                              });

                              //update UI
                              setState(() {
                                loading = false;
                              });

                              if (!mounted) return;
                              //redirect to role selection screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                          child: Text(
                            'NEXT',
                            style: decoration.whiteBold16TS,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //func to get img from phone storage
  void pickImageOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Choose',
          style: decoration.blueBold18TS,
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //select from gallery btn
            GestureDetector(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.image,
                    size: 50,
                  ),
                  Text('Gallery'),
                ],
              ),
              onTap: () async {
                openPicker(true);
              },
            ),
            //capture live pic from camera btn
            GestureDetector(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.camera_alt,
                    size: 50,
                  ),
                  Text('Camera'),
                ],
              ),
              onTap: () async {
                openPicker(false);
              },
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  //func for capturing/selecting img based on bool
  void openPicker(bool isGallery) async {
    //close previous alert dialog
    Navigator.pop(context);
    try {
      //Image picker method (if isGallery is true then will open storage otherwise will open camera for taking picture)
      final image = await ImagePicker().pickImage(
          source: isGallery ? ImageSource.gallery : ImageSource.camera,
          imageQuality: 0);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } catch (e) {}
  }
}
