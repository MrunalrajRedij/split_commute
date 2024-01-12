import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/values.dart' as values;
import 'package:split_commute/screens/homeScreen.dart';
import 'package:split_commute/utils/utilFunctions.dart';
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
  String profilePicUrl = "";
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
                    scale: 5,
                  ),
                ),
                SizedBox(height: 10),
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
                            profilePicUrl = values.boyProfilePicLink;
                            isAvatar1 = true;
                            isAvatar2 = false;
                            isAvatar3 = false;
                            isAvatar4 = false;
                            isCustomAvatar = false;
                          }
                          setState(() {});
                        },
                        child: AvatarWidget(
                          avatarImage: CachedNetworkImage(
                            imageUrl: values.boyProfilePicLink,
                            placeholder: (context, url) => Container(
                              width: 50.0,
                              height: 50.0,
                              padding: const EdgeInsets.all(70.0),
                              decoration: const BoxDecoration(
                                color: Color(0xffE8E8E8),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xfff5a623)),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                //if there is any error in showing img show this instead
                                Material(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
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
                            profilePicUrl = values.girlProfilePicLink;
                            isAvatar1 = false;
                            isAvatar2 = true;
                            isAvatar3 = false;
                            isAvatar4 = false;
                            isCustomAvatar = false;
                          }
                          setState(() {});
                        },
                        child: AvatarWidget(
                          avatarImage: CachedNetworkImage(
                            imageUrl: values.girlProfilePicLink,
                            placeholder: (context, url) => Container(
                              width: 50.0,
                              height: 50.0,
                              padding: const EdgeInsets.all(70.0),
                              decoration: const BoxDecoration(
                                color: Color(0xffE8E8E8),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xfff5a623)),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                //if there is any error in showing img show this instead
                                Material(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          selected: isAvatar2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (isAvatar3) {
                            isAvatar3 = false;
                          } else {
                            //set profilePic path
                            profilePicUrl = values.manProfilePicLink;
                            isAvatar1 = false;
                            isAvatar2 = false;
                            isAvatar3 = true;
                            isAvatar4 = false;
                            isCustomAvatar = false;
                          }
                          setState(() {});
                        },
                        child: AvatarWidget(
                          avatarImage: CachedNetworkImage(
                            imageUrl: values.manProfilePicLink,
                            placeholder: (context, url) => Container(
                              width: 50.0,
                              height: 50.0,
                              padding: const EdgeInsets.all(70.0),
                              decoration: const BoxDecoration(
                                color: Color(0xffE8E8E8),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xfff5a623)),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                //if there is any error in showing img show this instead
                                Material(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          selected: isAvatar3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (isAvatar4) {
                            isAvatar4 = false;
                          } else {
                            //set profilePic path
                            profilePicUrl = values.womanProfilePicLink;
                            isAvatar1 = false;
                            isAvatar2 = false;
                            isAvatar3 = false;
                            isAvatar4 = true;
                            isCustomAvatar = false;
                          }
                          setState(() {});
                        },
                        child: AvatarWidget(
                          avatarImage: CachedNetworkImage(
                            imageUrl: values.womanProfilePicLink,
                            placeholder: (context, url) => Container(
                              width: 50.0,
                              height: 50.0,
                              padding: const EdgeInsets.all(70.0),
                              decoration: const BoxDecoration(
                                color: Color(0xffE8E8E8),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xfff5a623)),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                //if there is any error in showing img show this instead
                                Material(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          selected: isAvatar4,
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
                            backgroundColor: palette.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  decoration.boxBorderRadius),
                            ),
                          ),
                          onPressed: () async {
                            if (userNameTC.text.trim().isEmpty) {
                              UtilFunctions().showScaffoldMsg(
                                  context, "Enter Valid Name!");
                            } else if (!isAvatar1 &&
                                !isAvatar2 &&
                                !isAvatar3 &&
                                !isAvatar4 &&
                                !isCustomAvatar) {
                              UtilFunctions().showScaffoldMsg(
                                context,
                                "Select any one Avatar or upload your custom profile pic!",
                              );
                            } else {
                              //starts loading indicator, if everything validates
                              //update profile pic separately
                              if (isCustomAvatar && image != null) {
                                setState(() {
                                  loading = true;
                                });
                                await uploadPic(image);
                              } else if (isCustomAvatar && image == null) {
                                UtilFunctions().showScaffoldMsg(context,
                                    "Upload Custom Image or select from Avatars");
                              } else {
                                setState(() {
                                  loading = true;
                                });
                                saveDataAndRoute();
                              }
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

  Future<void> uploadPic(File? file) async {
    //Create a reference to the location you want to upload to in firebase
    Reference ref =
        FirebaseStorage.instance.ref().child("profilePics/${image!.path}");
    UploadTask uploadTask = ref.putFile(file!);
    // Waits till the file is uploaded then stores the download url
    await uploadTask.whenComplete(() {
      ref.getDownloadURL().then((value) {
        profilePicUrl = value;
        saveDataAndRoute();
      });
    });
  }

  void saveDataAndRoute() {
    String? phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber;
    //update profile
    FirebaseFirestore.instance.collection("users").doc(phoneNumber).set({
      "userId": phoneNumber,
      "userName": userNameTC.text,
      "profilePicUrl": profilePicUrl,
    });

    //update UI
    setState(() {
      loading = false;
    });

    if (!mounted) return;
    //redirect to role selection screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
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
