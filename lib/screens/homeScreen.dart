import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:split_commute/screens/searchCompanionScreen.dart';
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
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Starting Point",
                                  ),
                                ),
                                itemBuilder: (BuildContext context, value) {
                                  return ListTile();
                                },
                                noItemsFoundBuilder: (context) => Center(
                                  child: Text(
                                    'No Items Found!',
                                    style: decoration.normal14TS,
                                  ),
                                ),
                                suggestionsCallback: (String search) {
                                  return db
                                      .collection("startingPoints")
                                      .snapshots()
                                      .toList();
                                },
                                onSuggestionSelected:
                                    (QuerySnapshot<Map<String, dynamic>>
                                        suggestion) {},
                              ),
                              Divider(
                                height: 30,
                              ),
                              TypeAheadField(
                                debounceDuration:
                                    const Duration(milliseconds: 500),
                                textFieldConfiguration: TextFieldConfiguration(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Ending Point",
                                  ),
                                ),
                                itemBuilder: (BuildContext context, value) {
                                  return ListTile();
                                },
                                noItemsFoundBuilder: (context) => Center(
                                  child: Text(
                                    'No Items Found!',
                                    style: decoration.normal14TS,
                                  ),
                                ),
                                suggestionsCallback: (String search) {
                                  return db
                                      .collection("startingPoints")
                                      .snapshots()
                                      .toList();
                                },
                                onSuggestionSelected:
                                    (QuerySnapshot<Map<String, dynamic>>
                                        suggestion) {},
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchCompanionScreen(
                                startingPoint: "VJTI",
                                endingPoint: "Dadar",
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Find Companions',
                          style: decoration.whiteBold16TS,
                        ),
                      ),
                    ),
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
