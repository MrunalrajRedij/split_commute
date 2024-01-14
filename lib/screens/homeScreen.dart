import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:split_commute/screens/chatRoomScreen.dart';
import 'package:split_commute/screens/searchCompanionScreen.dart';
import 'package:split_commute/utils/utilFunctions.dart';
import 'package:split_commute/widgets/menuDrawer.dart';
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/decorations.dart' as decoration;
import 'package:split_commute/widgets/shimmerWidget.dart';
import 'package:split_commute/widgets/sizedBoxWidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<String> startingPoints = [];
  List<String> endingPoints = [];
  TextEditingController startingPointTC = TextEditingController();
  TextEditingController endingPointTC = TextEditingController();
  bool openChatRoom = false;
  String groupId = "";
  String userName = "";
  Map last = {};
  String startingPoint = "";
  String endingPoint = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    UtilFunctions().checkIfUserFirstTime(context);
    getStartingPoints();
    getEndingPoints();
    getUserInfo();
  }

  void getStartingPoints() async {
    await db.collection("startingPoints").snapshots().forEach((element) {
      startingPoints.clear();
      for (var element in element.docs) {
        startingPoints.add(element.get("startingPoint"));
      }
    });
  }

  void getEndingPoints() async {
    await db.collection("endingPoints").snapshots().forEach((element) {
      endingPoints.clear();
      for (var element in element.docs) {
        endingPoints.add(element.get("endingPoint"));
      }
    });
  }

  void getUserInfo() async {
    await db.collection("users").doc(user!.phoneNumber).get().then((value) {
      userName = value["userName"];
      groupId = value["groupId"];
      last = value["last"];
      startingPoint = value["startingPoint"];
      endingPoint = value["endingPoint"];
      if (value["groupId"] != "") {
        openChatRoom = true;
      }
    });
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palette.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: palette.primaryColor,
        foregroundColor: palette.whiteColor,
        title: Text(
          'Split Commute',
          style: decoration.whiteBold18TS,
        ),
      ),
      drawer: const MenuDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: palette.primaryColor,
                        spreadRadius: 0.5,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Column(
                            children: [
                              Icon(
                                Icons.circle_outlined,
                                size: 20,
                              ),
                              SizedBoxWidget(height: 15),
                              Icon(Icons.arrow_downward),
                              SizedBoxWidget(height: 15),
                              Icon(
                                Icons.circle_outlined,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              children: [
                                TypeAheadField(
                                  debounceDuration:
                                      const Duration(milliseconds: 500),
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: startingPointTC,
                                    style: decoration.normal18TS,
                                    onChanged: (val) {
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Starting Point",
                                      suffixIcon: startingPointTC.text.isEmpty
                                          ? const SizedBox(
                                              width: 0,
                                              height: 0,
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  startingPointTC.clear();
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.clear,
                                                color: palette.greyColor,
                                              ),
                                            ),
                                    ),
                                  ),
                                  noItemsFoundBuilder: (context) => Center(
                                      child: Text(
                                    'No Items Found!',
                                    style: decoration.normal18TS,
                                  )),
                                  suggestionsCallback: (String search) async {
                                    return startingPoints.where((element) =>
                                        element
                                            .toLowerCase()
                                            .contains(search.toLowerCase()));
                                  },
                                  onSuggestionSelected: (suggestions) {
                                    startingPointTC.text = suggestions;
                                    setState(() {});
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Text(
                                            suggestion,
                                            style: decoration.normal18TS,
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const Divider(
                                  height: 30,
                                ),
                                TypeAheadField(
                                  debounceDuration:
                                      const Duration(milliseconds: 500),
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: endingPointTC,
                                    style: decoration.normal18TS,
                                    onChanged: (val) {
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Ending Point",
                                      suffixIcon: endingPointTC.text.isEmpty
                                          ? const SizedBox(
                                              width: 0,
                                              height: 0,
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  endingPointTC.clear();
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.clear,
                                                color: palette.greyColor,
                                              ),
                                            ),
                                    ),
                                  ),
                                  noItemsFoundBuilder: (context) => Center(
                                      child: Text(
                                    'No Items Found!',
                                    style: decoration.normal18TS,
                                  )),
                                  suggestionsCallback: (String search) async {
                                    return endingPoints.where((element) =>
                                        element
                                            .toLowerCase()
                                            .contains(search.toLowerCase()));
                                  },
                                  onSuggestionSelected: (suggestions) {
                                    endingPointTC.text = suggestions;
                                    setState(() {});
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Text(
                                            suggestion,
                                            style: decoration.normal18TS,
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBoxWidget(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.primaryColor,
                            foregroundColor: palette.whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                decoration.boxBorderRadius,
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (startingPointTC.text.isEmpty ||
                                endingPointTC.text.isEmpty) {
                              UtilFunctions().showScaffoldMsg(context,
                                  "Input Starting and Ending points !!!");
                            } else if (startingPointTC.text ==
                                endingPointTC.text) {
                              UtilFunctions().showScaffoldMsg(context,
                                  "Starting and Ending points cannot be same !!!");
                            } else if (!startingPoints
                                    .contains(startingPointTC.text) ||
                                !endingPoints.contains(endingPointTC.text)) {
                              UtilFunctions().showScaffoldMsg(context,
                                  "Enter valid Starting and Ending point !!!");
                            } else if (endingPointTC.text
                                .contains(startingPointTC.text.split(" ")[0])) {
                              UtilFunctions().showScaffoldMsg(context,
                                  "Points cannot be close to each other !!!");
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchCompanionScreen(
                                    startingPoint: startingPointTC.text,
                                    endingPoint: endingPointTC.text,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Find New Companions',
                            style: decoration.whiteBold16TS,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loading
                  ? const ShimmerWidget()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: palette.primaryColor,
                              spreadRadius: 0.5,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: openChatRoom
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Open ChatRooms",
                                    style: decoration.blueGreyBold18TS,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    groupId,
                                    style: decoration.lightBlackHeading16TS,
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: palette.primaryColor,
                                        foregroundColor: palette.whiteColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            decoration.boxBorderRadius,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChatRoomScreen(
                                              userId: user!.phoneNumber!,
                                              groupId: groupId,
                                              startingPoint: startingPoint,
                                              endingPoint: endingPoint,
                                              userName: userName,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Go to ChatRoom",
                                        style: decoration.whiteBold16TS,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Open ChatRooms",
                                    style: decoration.blueGreyBold18TS,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "No open ChatRooms",
                                    style: decoration.blueGreyBold15TS,
                                  ),
                                ],
                              ),
                      ),
                    ),
              loading
                  ? const ShimmerWidget()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: palette.primaryColor,
                              spreadRadius: 0.5,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: (last["startingPoint"] == "" ||
                                last["endingPoint"] == "")
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Recent journey",
                                    style: decoration.blueGreyBold18TS,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "No recent journeys",
                                    style: decoration.blueGreyBold15TS,
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Recent journey",
                                    style: decoration.blueGreyBold18TS,
                                  ),
                                  const SizedBox(height: 10),
                                  Material(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SearchCompanionScreen(
                                              startingPoint:
                                                  last["startingPoint"],
                                              endingPoint: last["endingPoint"],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "${last["startingPoint"]} -\n${last["endingPoint"]}",
                                              style: decoration
                                                  .lightBlackHeading16TS,
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
