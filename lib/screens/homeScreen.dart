import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:split_commute/screens/searchCompanionScreen.dart';
import 'package:split_commute/utils/utilFunctions.dart';
import 'package:split_commute/widgets/menuDrawer.dart';
import 'package:split_commute/config/palette.dart' as palette;
import 'package:split_commute/config/decorations.dart' as decoration;
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

  @override
  void initState() {
    super.initState();
    UtilFunctions().checkIfUserFirstTime(context);
    getStartingPoints();
    getEndingPoints();
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
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
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            children: [
                              TypeAheadField(
                                debounceDuration:
                                    const Duration(milliseconds: 500),
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: startingPointTC,
                                  style: decoration.normal18TS,
                                  onChanged: (val) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Starting Point",
                                    suffixIcon: startingPointTC.text.isEmpty
                                        ? SizedBox(
                                            width: 0,
                                            height: 0,
                                          )
                                        : IconButton(
                                            onPressed: () {
                                              setState(() {
                                                startingPointTC.clear();
                                              });
                                            },
                                            icon: Icon(
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
                                        SizedBox(height: 10),
                                        Text(
                                          suggestion,
                                          style: decoration.normal18TS,
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                height: 30,
                              ),
                              TypeAheadField(
                                debounceDuration:
                                    const Duration(milliseconds: 500),
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: endingPointTC,
                                  style: decoration.normal18TS,
                                  onChanged: (val) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Ending Point",
                                    suffixIcon: endingPointTC.text.isEmpty
                                        ? SizedBox(
                                            width: 0,
                                            height: 0,
                                          )
                                        : IconButton(
                                            onPressed: () {
                                              setState(() {
                                                endingPointTC.clear();
                                              });
                                            },
                                            icon: Icon(
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
                                  return endingPoints.where((element) => element
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
                                        SizedBox(height: 10),
                                        Text(
                                          suggestion,
                                          style: decoration.normal18TS,
                                        ),
                                        SizedBox(height: 10),
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
                    SizedBoxWidget(height: 15),
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
                          'Find Companions',
                          style: decoration.whiteBold16TS,
                        ),
                      ),
                    ),

                    //recent journey
                    //recent companions
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
