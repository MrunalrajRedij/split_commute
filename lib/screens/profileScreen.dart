import  'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spiconn/widgets/expertiseWidget.dart';
import 'package:spiconn/widgets/menuDrawer.dart';
import 'package:spiconn/config/decoration.dart' as decoration;
import 'package:spiconn/config/palette.dart' as palette;
import 'package:spiconn/config/values.dart' as values;
import 'package:spiconn/widgets/tapEnabledSelectionWidget.dart';
import '../widgets/selectionWidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //local var
  TextEditingController userNameController = TextEditingController();
  TextEditingController totalExpController = TextEditingController();
  int? verifyStatus;
  String? verifiedOn;
  bool isAdvisor = false;
  bool isAdvisorTag = false;
  bool saving = false;
  List<ExpertiseWidget> expertiseWidgetList = <ExpertiseWidget>[];
  dynamic userData;
  UserInfo userInfo = UserInfo();
  File? image;
  TextEditingController designationController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController linkedInIdController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  bool isEnglish = true;
  bool isOtherLanguage = false;
  List languageList = [];
  List filteredLanguageList = [];
  List<TapEnabledSelectionWidget> languageSelectionListToDelete = [];
  List<TapEnabledSelectionWidget> languageSelectionWidgetList = [];

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
    //set user data fetched from server in UI
    setUserData();
    //check if user is advisor
    checkAndSetAdvisor();
    //check if user is verified
    checkAndSetVerified();
    //refresh state
    setState(() {});
  }

  //func to save profile
  void saveProfile() async {
    //saving bool for loading indication
    setState(() {
      saving = true;
    });

    //input validation
    if (userNameController.text.trim().isEmpty) {
      showInvalidInputDialog('Input valid Username');
      return;
    } else if (!await saveLanguages()) {
      showInvalidInputDialog('You have not selected any language.\n'
          'English will be the default language.');
    } else if (int.parse(totalExpController.text) > 50) {
      showInvalidInputDialog('Enter relevant years of experience');
      return;
    }

    //if user is not advisor
    final dynamic bodyObjIfNotAdvisor = {
      'name': userNameController.text,
      'designation': designationController.text,
      'organization': companyController.text,
      'address': locationController.text,
      'linkedin_link': linkedInIdController.text,
      'email': emailController.text,
      'about_me': aboutMeController.text.trim(),
      'total_exp':
      (totalExpController.text == '0' || totalExpController.text.isEmpty)
          ? 1
          : totalExpController.text,
    };
    //call api with created obj and flags
    await ApiServerUtils().updateProfileApi(bodyObjIfNotAdvisor);

    //further block in case of advisor
    if (isAdvisor) {
      if (designationController.text.trim().isEmpty) {
        showInvalidInputDialog('Input valid Designation');
        return;
      } else if (companyController.text.trim().isEmpty) {
        showInvalidInputDialog('Input valid Company');
        return;
      } else if (emailController.text.trim().isEmpty ||
          !EmailValidator.validate(emailController.text)) {
        showInvalidInputDialog('Input valid Email');
        return;
      } else if (chatBool && msgFeeController.text.trim().isEmpty) {
        showInvalidInputDialog('Please enter cost for each message');
        return;
      } else if (callBool && callFeeController.text.trim().isEmpty) {
        showInvalidInputDialog('Please enter cost for call/3min');
        return;
      } else if (callBool &&
          !sunBool &&
          !monBool &&
          !tueBool &&
          !wedBool &&
          !thursBool &&
          !friBool &&
          !satBool) {
        showInvalidInputDialog('Select at least a day for enabling Call');
        return;
      } else if (callBool &&
          // scheduleBool &&
          (fromTimeController.text.isEmpty || toTimeController.text.isEmpty)) {
        showInvalidInputDialog('Select timing of availability');
        return;
      }

      //if advisor
      String chatFlag, callFlag, scheduleCall, instantCall;
      chatBool ? chatFlag = "1" : chatFlag = "0";
      callBool ? callFlag = "1" : callFlag = "0";
      scheduleBool ? scheduleCall = "1" : scheduleCall = "0";
      instantBool ? instantCall = "1" : instantCall = "0";
      final List days = [
        sunBool ? "0" : null,
        monBool ? "1" : null,
        tueBool ? "2" : null,
        wedBool ? "3" : null,
        thursBool ? "4" : null,
        friBool ? "5" : null,
        satBool ? "6" : null,
      ];
      final timings = [];
      for (int i = 0; i < days.length; i++) {
        if (days[i] != null) {
          timings.add({
            "days": days[i],
            "start_time": fromTimeController.text,
            "end_time": toTimeController.text
          });
        }
      }

      //create bodyObj
      final dynamic bodyObjIfAdvisor = {
        'name': userNameController.text,
        'designation': designationController.text,
        'organization': companyController.text,
        'address': locationController.text,
        'linkedin_link': linkedInIdController.text,
        'email': emailController.text,
        'about_me': aboutMeController.text.trim(),
        'message_flg': chatFlag,
        'call_flg': callFlag,
        'fee_per_message': msgFeeController.text,
        'fee_per_call': callFeeController.text,
        'schedule_call': scheduleCall,
        'instant_call': instantCall,
        "timings": timings,
        'total_exp':
        (totalExpController.text == '0' || totalExpController.text.isEmpty)
            ? 1
            : totalExpController.text
      };

      //call api with created obj and flags
      await ApiServerUtils().updateProfileApi(bodyObjIfAdvisor);
      isAdvisorTag = true;
      isAdvisorMenu = true;

      if (!callBool && !chatBool) {
        //if call and msg both are disabled
        isAdvisorTag = false;
        isAdvisor = false;
        isAdvisorMenu = false;

        //show dialog stating that user is no longer advisor
        if (!mounted) return;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Profile Saved'),
                content: const Text(
                  "You are no longer an advisor as both chat and "
                      "call preferences are disabled",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Okay'),
                  ),
                ],
              );
            });
      }
    } //if advisor block ends

    //below code is common for both advisor as well as user

    if (userInfo.userName != userNameController.text) {
      //this condition means username has been updated, if yes then update username in connectycubes server too
      CubeUser userWithName = CubeUser(
        id: menuCurrentCubeUser!.id,
        login: menuCurrentCubeUser!.login,
        fullName: userNameController.text,
      );
      await updateUser(userWithName);
      userName = userNameController.text;
      userInfo.userName = userNameController.text;
    }

    //show message after updating
    if (!mounted) return;
    UtilFunctions().showScaffoldMsg(context, "Profile has been saved");
    //refresh state
    setState(() {
      //indicates loading stopped
      saving = false;
    });
  }

  //func for getting all info in userData obj and store that data into UserInfo class obj
  fetchUserData() async {
    userData = await ApiServerUtils().getSelfProfileApi();
    userInfo.userName = userData['name'] ?? "";
    userInfo.userRating = userData['overall_rating'].toDouble() ?? 0;
    userInfo.userDesignation = userData['designation'] ?? "";
    userInfo.userCompany = userData['organization'] ?? "";
    userInfo.userPhone = userData['phone_number'] ?? "";
    userInfo.userProfilePic = userData['profile_pic'] ?? "";
    userInfo.userLinkedInId = userData['linkedin_link'] ?? "";
    userInfo.userEmail = userData['email'] ?? "";
    userInfo.userLocation = userData['address'] ?? "";
    userInfo.userAboutMe = userData['about_me'] ?? "";
    userInfo.callFlag = userData['call_flg'] ?? "0";
    userInfo.messageFlag = userData['message_flg'] ?? "0";
    userInfo.userMsgFee = userData['fee_per_message'] ?? "";
    userInfo.userCallFee = userData['fee_per_call'] ?? "";
    userInfo.userScheduleCall = userData['schedule_call'] ?? 0;
    userInfo.userInstantCall = userData['instant_call'] ?? 0;
    userInfo.userTimings = userData['timings'] ?? [];
    userInfo.userExperience = userData['expertise'] ?? [];
    userInfo.userTotalExp = userData["total_exp"] ?? 0;
  }

  //func for setting all data to the profile page so that it is visible to user
  void setUserData() async {
    setGeneralInfo();
    setChatAndCallBool();
    setLanguageWidgetList();
    setExpertiseWidgetList();
    setCallPreferences();
    setAvailableDaysAndTime();
  }

  //func for setting general info of user in respective text-field
  void setGeneralInfo() {
    userNameController.text = userInfo.userName;
    designationController.text = userInfo.userDesignation;
    companyController.text = userInfo.userCompany;
    phoneController.text = userInfo.userPhone;
    emailController.text = userInfo.userEmail;
    locationController.text = userInfo.userLocation;
    linkedInIdController.text = userInfo.userLinkedInId;
    aboutMeController.text = userInfo.userAboutMe!;
    msgFeeController.text = userInfo.userMsgFee;
    callFeeController.text = userInfo.userCallFee;
    totalExpController.text = userInfo.userTotalExp.toString();
  }

  //this func checks if user enabled chat or call functionality
  void setChatAndCallBool() {
    (userInfo.messageFlag == 1) ? chatBool = true : chatBool = false;
    (userInfo.callFlag == 1) ? callBool = true : callBool = false;
  }

  //func for user experience/expertise
  void setLanguageWidgetList() {
    //for loop is for placing the experience data in list
    for (int i = 0; i < userInfo.userExperience.length; i++) {
      int expTypeId = userInfo.userExperience[i]['type_id'];
      String name = userInfo.userExperience[i]['exp_name'] ?? "";
      int expId = userInfo.userExperience[i]['id'];
      if (expTypeId == 4) {
        //exp type == 4 is for language expertise
        languageSelectionWidgetList.add(
          TapEnabledSelectionWidget(
            id: expId,
            selectionString: name,
            isSelected: true,
          ),
        );
        languageSelectionListToDelete.add(
          TapEnabledSelectionWidget(
            id: expId,
            selectionString: name,
            isSelected: true,
          ),
        );
      }
    }
    getFilterLanguagesApi();
    //refresh state
    setState(() {});
  }

  //func for setting user experience
  void setExpertiseWidgetList() {
    //for loop is for placing the experience data in list
    for (int i = 0; i < userInfo.userExperience.length; i++) {
      final int? profileLink = userInfo.userExperience[i]['profile_link'];
      int year = userInfo.userExperience[i]['year_of_exp'];
      int expTypeId = userInfo.userExperience[i]['type_id'];
      String typeName = "";
      String name = userInfo.userExperience[i]['exp_name'] ?? "";
      int expId = userInfo.userExperience[i]['id'];
      //setting types name and name based on type
      if (expTypeId == 1) {
        typeName = "Company";
      } else if (expTypeId == 2) {
        typeName = "Role";
      } else if (expTypeId == 3) {
        typeName = "Industry";
      }
      if (expTypeId != 4 && (profileLink == null || profileLink == 9)) {
        //actual adding the experience data into the list
        expertiseWidgetList.add(
          ExpertiseWidget(
            type: expTypeId,
            typeName: typeName,
            name: name,
            year: year.toString(),
            isUser: true,
            id: expId.toString(),
            editExpFunc: editExpFunc,
            refreshExpUI: refreshExpUI,
            profileLink: profileLink,
          ),
        );
      }
    }
  }

  //func for getting languages of user from server
  Future getFilterLanguagesApi() async {
    var jsonData = await ApiServerUtils().searchFilterApi();
    languageList.clear();
    for (int i = 0; i < jsonData["language"].length; i++) {
      languageList.add(jsonData["language"][i]);
    }
    //refresh state
    setState(() {});
  }

  //this func checks if user has schedule call or instant call enabled
  void setCallPreferences() {
    if (userInfo.userScheduleCall == 1) scheduleBool = true;
    if (userInfo.userInstantCall == 1) instantBool = true;
  }

  //this func checks and sets if user has any schedule
  void setAvailableDaysAndTime() {
    if (userInfo.userTimings.isNotEmpty) {
      for (int i = 0; i < userInfo.userTimings.length; i++) {
        switch (userInfo.userTimings[i]['days']) {
          case '0':
            sunBool = true;
            break;
          case '1':
            monBool = true;
            break;
          case '2':
            tueBool = true;
            break;
          case '3':
            wedBool = true;
            break;
          case '4':
            thursBool = true;
            break;
          case '5':
            friBool = true;
            break;
          case '6':
            satBool = true;
            break;
        }
      }
      //from and to time for schedule
      fromTimeController.text = userInfo.userTimings[0]['start_time'] ?? "";
      toTimeController.text = userInfo.userTimings[0]['end_time'] ?? "";
    }
  }

  //func for refreshing experience and set the data into the previous list
  void refreshExpUI() async {
    userData = await ApiServerUtils().getSelfProfileApi();
    userInfo.userExperience = userData['expertise'] ?? [];
    //previous list should be clear otherwise user will see duplicate data
    expertiseWidgetList.clear();
    //refresh state
    setState(() {
      setExpertiseWidgetList();
    });
  }

  //this func checks if user is advisor or not
  void checkAndSetAdvisor() {
    if (userData['role'] == 2) {
      isAdvisor = true;
      isAdvisorTag = true;
    }
  }

  //this func checks if user is verified or not
  //null - not initiated, 1 initiated , 9 is verified
  void checkAndSetVerified() {
    verifyStatus = userData['verification_status'];
    verifiedOn = userData['profile_verified_on'];
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

  //func for saving languages
  Future<bool> saveLanguages() async {
    List<int> selectedLanguage = [];
    for (int i = 0; i < languageSelectionWidgetList.length; i++) {
      if (languageSelectionWidgetList[i].isSelected == true) {
        selectedLanguage.add(i);
      }
    }
    if (languageSelectionListToDelete.isNotEmpty) {
      for (int i = 0; i < languageSelectionListToDelete.length; i++) {
        //call api for deleting existing lang
        await ApiServerUtils()
            .deleteExperienceApi(languageSelectionListToDelete[i].id);
      }
    }
    if (selectedLanguage.isEmpty) {
      await ApiServerUtils().addNewExperienceApi(
        {'exp_name': 'English', 'type_id': '4', 'year': '0'},
      );
      languageSelectionWidgetList.clear();
      languageSelectionWidgetList.add(
        TapEnabledSelectionWidget(
          selectionString: 'English',
          isSelected: true,
        ),
      );
      //refresh state
      setState(() {});
      return false;
    }

    languageSelectionListToDelete.clear();
    if (languageSelectionWidgetList.isNotEmpty) {
      for (int i = 0; i < languageSelectionWidgetList.length; i++) {
        if (languageSelectionWidgetList[i].isSelected == true) {
          int? id = languageSelectionWidgetList[i].id;
          String name = languageSelectionWidgetList[i].selectionString;
          languageSelectionListToDelete.add(
            TapEnabledSelectionWidget(
              id: id,
              selectionString: name,
              isSelected: true,
            ),
          );

          //call api for saving lang.
          await ApiServerUtils().addNewExperienceApi(
            {
              'exp_name': languageSelectionWidgetList[i].selectionString,
              'type_id': '4',
              'year': '0'
            },
          );
        }
      }
    }
    return true;
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
                    Hero(
                      tag: values.heroMenuProfile,
                      child: GestureDetector(
                        child: (userInfo.userProfilePic == "" ||
                            userInfo.userProfilePic == "null")
                            ? CircleAvatar(
                          radius: 50,
                          backgroundColor: palette.scaffoldBgColor,
                          child: const Icon(
                            Icons.person_outline,
                            color: palette.primaryColor,
                            size: 80,
                          ),
                        )
                            : CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                            values.imgStoragePath +
                                userInfo.userProfilePic,
                          ),
                        ),
                        onTap: () {
                          //if profile pic is clicked then run func for updating new profile pic
                          pickImageOptions();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 50,
                            maxWidth: MediaQuery.of(context).size.width * 0.80,
                          ),
                          child: IntrinsicWidth(
                            child: TextField(
                              cursorColor: palette.scaffoldBgColor,
                              style: decoration.whiteBold18TS,
                              controller: userNameController,
                              decoration: InputDecoration(
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 10,
                                  minHeight: 10,
                                ),
                                suffixIcon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: palette.scaffoldBgColor!),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        //STICKERS
                        //if 9 then verified
                        verifyStatus == 9 && verifiedOn != null
                            ? const Icon(
                          Icons.verified,
                          color: palette.greenAccentColor,
                          size: 20,
                        )
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    //star rating
                    GFRating(
                      color: palette.amberColor,
                      borderColor: palette.amberColor,
                      size: 20,
                      itemCount: 5,
                      value: userInfo.userRating,
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 10),
                    isAdvisorTag
                        ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        'Advisor',
                        style: decoration.blueBold14TS,
                      ),
                    )
                        : const SizedBox(),
                  ],
                ),
              ),
              //Basic Info text-fields form (isAdvisor bool is for Become advisor btn)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: palette.scaffoldBgColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2,
                      spreadRadius: 1,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: designationController,
                        style: decoration.normal14TS,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person,
                              color: palette.greyColor),
                          label: const Text("Designation"),
                          labelStyle: decoration.normal14TS,
                          contentPadding: const EdgeInsets.only(top: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                decoration.boxBorderRadius),
                            borderSide: const BorderSide(
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        style: decoration.normal14TS,
                        controller: companyController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.corporate_fare_outlined,
                              color: palette.greyColor),
                          label: const Text("Company"),
                          labelStyle: decoration.normal14TS,
                          contentPadding: const EdgeInsets.only(top: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                decoration.boxBorderRadius),
                            borderSide: const BorderSide(
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
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
                            borderRadius: BorderRadius.circular(
                                decoration.boxBorderRadius),
                            borderSide: const BorderSide(
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
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
                            borderRadius: BorderRadius.circular(
                                decoration.boxBorderRadius),
                            borderSide: const BorderSide(
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        style: decoration.normal14TS,
                        controller: locationController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on,
                              color: palette.greyColor),
                          label: const Text("Location"),
                          labelStyle: decoration.normal14TS,
                          contentPadding: const EdgeInsets.only(top: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                decoration.boxBorderRadius),
                            borderSide: const BorderSide(
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        style: decoration.normal14TS,
                        controller: linkedInIdController,
                        decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.link, color: palette.greyColor),
                          label: const Text("Linkedin ID"),
                          labelStyle: decoration.normal14TS,
                          contentPadding: const EdgeInsets.only(top: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                decoration.boxBorderRadius),
                            borderSide: const BorderSide(
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        style: decoration.normal14TS,
                        controller: aboutMeController,
                        textAlign: TextAlign.start,
                        maxLines: null,
                        minLines: 6,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: 'About Me',
                          labelStyle: decoration.normal14TS,
                          contentPadding:
                          const EdgeInsets.only(top: 25, left: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                decoration.boxBorderRadius),
                            borderSide: const BorderSide(
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      //Main btn
                      isAdvisor
                          ?
                      //if advisor
                      verifyStatus == null
                          ?
                      //if verification is not done show "Verify profile" btn for verification
                      SizedBox(
                        height: 35,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(5),
                              ),
                            ),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                palette.primaryColor),
                          ),
                          onPressed: () async {
                            //call api for verification of the user
                            await ApiServerUtils().updateProfileApi(
                                {"verification_status": 1});
                            //refresh state
                            setState(() {
                              verifyStatus = 1;
                            });
                          },
                          child: Text(
                            'VERIFY PROFILE',
                            style: decoration.whiteBold14TS,
                          ),
                        ),
                      )
                          : verifyStatus == 1 || verifiedOn == null
                          ?
                      //if verification flag is 1 but doesn't have verifiedOn meaning verification is in progress
                      SizedBox(
                        height: 35,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(5),
                              ),
                            ),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                palette.greyColor),
                          ),
                          onPressed: () {},
                          child: Text(
                            'VERIFICATION IS IN PROGRESS',
                            style: decoration.whiteBold14TS,
                          ),
                        ),
                      )
                          :
                      //else show nothing
                      const SizedBox()
                          :
                      //if not advisor, show become advisor btn
                      SizedBox(
                        height: 35,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                palette.primaryColor),
                          ),
                          onPressed: () {
                            setState(() {
                              isAdvisor = true;
                            });
                          },
                          child: Text(
                            'BECOME ADVISOR',
                            style: decoration.whiteBold14TS,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              decoration.sizedBoxWithHeight5,
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: palette.scaffoldBgColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2,
                      spreadRadius: 1,
                      offset: Offset(0, 1),
                    )
                  ],
                ),

                //language section
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Spoken languages",
                          style: decoration.tileHeading16TS,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          '*',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    Wrap(
                      children: <Widget>[
                        for (int i = 0;
                        i < languageSelectionWidgetList.length;
                        i++)
                          (languageSelectionWidgetList.isNotEmpty)
                              ? languageSelectionWidgetList[i]
                              : const SizedBox(),
                        GestureDetector(
                          child: SelectionWidget(
                              selectionString: 'Other',
                              isSelected: isOtherLanguage),
                          onTap: () {
                            setState(() {
                              if (!isOtherLanguage) {
                                isOtherLanguage = true;
                              } else {
                                isOtherLanguage = false;
                              }
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    isOtherLanguage
                        ? Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        children: [
                          ConstrainedBox(
                            constraints:
                            const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredLanguageList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title:
                                  Text(filteredLanguageList[index]),
                                  onTap: () async {
                                    languageSelectionWidgetList.add(
                                      TapEnabledSelectionWidget(
                                        selectionString:
                                        filteredLanguageList[index],
                                        isSelected: true,
                                      ),
                                    );
                                    languageList.remove(
                                        filteredLanguageList[index]);
                                    filteredLanguageList.removeAt(index);
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ),
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.language,
                                  color: palette.darkGreyColor),
                              labelText: 'Other language',
                              labelStyle: decoration.normal14TS,
                              contentPadding:
                              const EdgeInsets.only(top: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  width: 1,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              filteredLanguageList = languageList
                                  .where((element) => element
                                  .toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                                  .toList();
                              setState(() {});
                            },
                            onSubmitted: (value) {
                              languageSelectionWidgetList.add(
                                TapEnabledSelectionWidget(
                                  selectionString: value,
                                  isSelected: true,
                                ),
                              );
                              setState(() {});
                              isOtherLanguage = false;
                            },
                          ),
                        ],
                      ),
                    )
                        : const SizedBox(),
                  ],
                ),
              ),
              isAdvisor
                  ?
              //if advisor show communication preferences for changing call and msg settings
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: palette.scaffoldBgColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 2,
                        spreadRadius: 1,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  child: const CommPrefWidget(),
                ),
              )
                  : const SizedBox(),

              //expertise section
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: palette.scaffoldBgColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 2,
                        spreadRadius: 1,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expertise',
                            style: decoration.tileHeading16TS,
                          ),
                          //Experience add btn
                          Material(
                            child: InkWell(
                              child: const Icon(
                                Icons.add,
                                size: 25,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return expertiseAlertDialog(
                                        true, "", 1, "", "1");
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Years of Experience',
                            style: decoration.lightBlackHeading14TS,
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: 45,
                                minWidth: 30,
                                maxWidth:
                                MediaQuery.of(context).size.width * 0.30),
                            child: IntrinsicWidth(
                              child: SizedBox(
                                height: 10,
                                child: TextField(
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(2),
                                    //for below version 2
                                    FilteringTextInputFormatter.allow(RegExp(
                                      // r'^([1-9]|[1-4]\d|50)$'
                                        r'[0-9]')),
                                    // for version 2 and greater
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: decoration.normal14TS,
                                  keyboardType: TextInputType.number,
                                  controller: totalExpController,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(width: 50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      //Experience Lists
                      ConstrainedBox(
                        constraints:
                        const BoxConstraints(maxHeight: 350, minHeight: 0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: expertiseWidgetList.length,
                          itemBuilder: (context, index) {
                            return expertiseWidgetList[index];
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //func called when user wants to select profile pic from phone
  void pickImageOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Choose',
          style: decoration.normalBlueText,
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
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
                //set profile pic from gallery
                setProfilePic(true);
              },
            ),
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
                //set profile pic from camera
                setProfilePic(false);
              },
            )
          ],
        ),
        actions: [
          //cancel btn
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  //func for setting selected pic as a profile pic
  void setProfilePic(bool isGallery) async {
    Navigator.pop(context);
    await openPicker(isGallery);
    if (image == null) {
      if (mounted) return;
      //error msg
      UtilFunctions()
          .showScaffoldMsg(context, "Something went wrong. Please try again!");
    }
    //call server API
    await ApiServerUtils().updateProfilePic(image!);
    final profileImage = await ApiServerUtils().getSelfProfileApi();
    setState(() => userInfo.userProfilePic = profileImage['profile_pic'] ?? "");
  }

  //func for opening method to let user select pic from device
  Future<void> openPicker(bool isGallery) async {
    try {
      final image = await ImagePicker().pickImage(
          source: isGallery ? ImageSource.gallery : ImageSource.camera,
          imageQuality: 0);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } catch (error) {
      //error msg while selecting profile pic
      UtilFunctions().showScaffoldMsg(context, error.toString());
    }
  }

  //this function returns editExpAlertdialog
  //function is attached to ExpertiseListObj when initializing so when edit btn is clicked on that widget this function will run
  // (Note://editExpAlertDialog and addNewExpAlertDialog) are same but call different functions based on bool
  void editExpFunc(id, expTypeId, name, year) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //false bool is for isAdd boolean
        //if it is false the editExp functionality will work and if it is true addExp func will work
        return expertiseAlertDialog(false, id, expTypeId, name, year);
      },
    );
  }

  //alert dialog for adding experience
  AlertDialog expertiseAlertDialog(
      isAdd, expId, int expType, expName, expYear) {
    final formKey = GlobalKey<FormState>();
    int expertiseType = expType;
    String expertiseYear = expYear;
    int radioBtnValue = 1;
    TextEditingController expertiseNameTC = TextEditingController();
    expertiseNameTC.text = expName;

    if (expertiseType == 1) {
      radioBtnValue = 1;
    } else if (expertiseType == 2) {
      radioBtnValue = 2;
    } else {
      radioBtnValue = 3;
    }

    //function for adding new experience in back-end
    addNewExperienceFunc() async {
      final dynamic bodyObj = {
        'exp_name': expName,
        'type_id': expertiseType.toString(),
        'year': expertiseYear,
      };
      await ApiServerUtils().addNewExperienceApi(
        bodyObj,
      );
    }

    //function for editing experience in back-end
    editExperienceFunc() async {
      await ApiServerUtils().editExpertise(
        {
          "type_id": expertiseType.toString(),
          "exp_name": expName,
          "year": expertiseYear,
          "experience_id": expId,
        },
      );
    }

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      title: const Text("Add New Experience"),
      actionsPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Radio(
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            value: 1,
                            groupValue: radioBtnValue,
                            onChanged: (value) {
                              setState(() {
                                radioBtnValue = 1;
                                expertiseType = 1;
                              });
                            }),
                        const Text('Company'),
                        const SizedBox(width: 10),
                        Radio(
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            value: 2,
                            groupValue: radioBtnValue,
                            onChanged: (value) {
                              setState(() {
                                radioBtnValue = 2;
                                expertiseType = 2;
                              });
                            }),
                        const Text('Role'),
                        const SizedBox(width: 10),
                        Radio(
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            value: 3,
                            groupValue: radioBtnValue,
                            onChanged: (value) {
                              setState(() {
                                radioBtnValue = 3;
                                expertiseType = 3;
                              });
                            }),
                        const Text('Industry'),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: expertiseNameTC,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Field should not be empty';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your Expertise name',
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(decoration.boxBorderRadius),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Years of experience:",
                      style: decoration.lightSmallRobotoBoldTS,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 70,
                      height: 45,
                      decoration: ShapeDecoration(
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
                          underline:
                          const SizedBox(), //for removing underline from drop down btn
                          isExpanded: true,
                          value: expertiseYear,
                          items: <String>[
                            '1',
                            '2',
                            '3',
                            '4',
                            '5',
                            '6',
                            '7',
                            '8',
                            '9',
                            '10',
                            '11',
                            '12',
                            '13',
                            '14',
                            '15',
                            '16',
                            '17',
                            '18',
                            '19',
                            '20',
                            '21',
                            '22',
                            '23',
                            '24',
                            '25'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              expertiseYear = value!;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        TextButton(
          child: const Text("OK"),
          onPressed: () async {
            //validate form in expAlertDialog
            if (formKey.currentState!.validate()) {
              //set the selected data in respected variable
              expName = expertiseNameTC.text;

              //adding or editing of experience based on bool
              if (isAdd) {
                await addNewExperienceFunc();
              } else {
                await editExperienceFunc();
              }
              //whichever operation is over refresh the list
              refreshExpUI();
              //close the expertise dialog
              if (!mounted) return;
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
        ),
      ],
    );
  }
}