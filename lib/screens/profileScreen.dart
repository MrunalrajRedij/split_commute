import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_commute/utils/utilFunctions.dart';
import 'package:split_commute/widgets/menuDrawer.dart';
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/values.dart' as values;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //local var
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool saving = false;
  File? image;
  String profilePicUrl = "";
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    //func for calling all other functions
    loadPage();
  }

  //wait for fetch api from server and then calls other func
  void loadPage() async {
    //fetch user data from server
    await fetchUserData();
    setState(() {});
  }

  fetchUserData() async {
    db.collection("users").doc(user!.phoneNumber).get().then((value) {
      userNameController.text = value['userName'] ?? "";
      phoneController.text = value['userId'] ?? "";
      emailController.text = value['email'] ?? "";
      profilePicUrl = value['profilePicUrl'] ?? "";
    });
  }

  void saveProfile() async {
    setState(() {
      saving = true;
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(phoneController.text)
        .update({
      "email": emailController.text,
      "userName": userNameController.text,
    });
    setState(() {
      saving = false;
    });
    UtilFunctions().showScaffoldMsg(context, "Profile Saved!!!");
  }

  //func for showing error dialog
  void showInvalidInputDialog(String stringToShow) {
    //refresh state
    setState(() {
      saving = false;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: Text(stringToShow),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palette.scaffoldBgColor,
      drawer: const MenuDrawer(),
      appBar: AppBar(
        titleSpacing: 5,
        iconTheme: const IconThemeData(color: palette.whiteColor),
        backgroundColor: palette.primaryColor,
        elevation: 0,
        title: Text(
          'My Profile',
          style: decoration.whiteBold18TS,
        ),
        actions: [
          //save btn, below bool indicates whether profile is saving or not
          saving
              ? const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: SpinKitCircle(
                    color: palette.whiteColor,
                    size: 30,
                  ),
                )
              : IconButton(
                  icon: Column(
                    children: [
                      const Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                      Text('Save', style: decoration.whiteBold10TS),
                    ],
                  ),
                  onPressed: () {
                    if (!saving) {
                      //save profile once all inputted
                      saveProfile();
                    }
                  },
                ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: palette.primaryColor,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //profile pic if imgPath is valid other wise default icon
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: GestureDetector(
                        child: CachedNetworkImage(
                          imageUrl: values.boyProfilePicLink,
                          placeholder: (context, url) => Container(
                            width: 10.0,
                            height: 10.0,
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
                        onTap: () {
                          //if profile pic is clicked then run func for updating new profile pic
                          pickImageOptions();
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              //Basic Info text-fields form (isAdvisor bool is for Become advisor btn)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: palette.scaffoldBgColor,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    TextFormField(
                      style: decoration.normal14TS,
                      controller: userNameController,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.phone, color: palette.greyColor),
                        label: const Text("User Name"),
                        labelStyle: decoration.normal14TS,
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
                    const SizedBox(height: 30),
                    TextFormField(
                      style: decoration.normal14TS,
                      readOnly: true,
                      controller: phoneController,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.phone, color: palette.greyColor),
                        label: const Text("Phone"),
                        labelStyle: decoration.normal14TS,
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
                    const SizedBox(height: 30),
                    TextFormField(
                      style: decoration.normal14TS,
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.email, color: palette.greyColor),
                        label: const Text("Email"),
                        labelStyle: decoration.normal14TS,
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
                ),
              ),
            ],
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
      uploadPic(imageTemp);
    } catch (e) {}
  }

  Future<void> uploadPic(File? file) async {
    //Create a reference to the location you want to upload to in firebase
    Reference ref =
        FirebaseStorage.instance.ref().child("profilePics/${file!.path}");
    UploadTask uploadTask = ref.putFile(file);
    // Waits till the file is uploaded then stores the download url
    await uploadTask.whenComplete(() async {
      await ref.getDownloadURL().then((value) async {
        profilePicUrl = value;
        setState(() {});
        await FirebaseFirestore.instance
            .collection("users")
            .doc(phoneController.text)
            .update({
          "profilePicUrl": profilePicUrl,
        });
        UtilFunctions().showScaffoldMsg(context, "Profile Saved!!!");
      });
    });
  }
}
