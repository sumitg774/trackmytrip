import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trip_tracker_app/Utils/CommonFunctions.dart';

import '../Components/AlertDialogs.dart';
import '../Components/Containers.dart';
import '../Utils/StorageService.dart';

class QuickLocations extends StatefulWidget {
  const QuickLocations({super.key});

  @override
  State<QuickLocations> createState() => _QuickLocationsState();
}

class _QuickLocationsState extends State<QuickLocations> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> quickLocations = {};
  TextEditingController AQLNameController = TextEditingController();
  TextEditingController AQLLatitudeController = TextEditingController();
  TextEditingController AQLLongitudeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getQuickLocationUserData();
  }

  void getQuickLocationUserData() async {
    userData = await CommonFunctions().getLoggedInUserInfo();
    setState(() {
      quickLocations = userData['quick_locations'];
    });
    print("USER:: ${quickLocations}");
  }

  void addQuickLocation(String LocationName, double lat, double long) async {
    String? collectionName = await StorageService.instance.getCollectionName();
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore.instance
        .collection(collectionName!)
        .doc(uid)
        .update({
          'quick_locations.$LocationName.lat': lat,
          'quick_locations.$LocationName.long': long,
        })
        .then((_) {
          print('Location updated!');
        })
        .catchError((e) {
          print('Error updating: $e');
        });
    getQuickLocationUserData();
  }

  void deleteQuickLocation(String LocationName) async {
    String? collectionName = await StorageService.instance.getCollectionName();
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance
        .collection(collectionName!)
        .doc(uid)
        .update({'quick_locations.$LocationName': FieldValue.delete()})
        .then((_) {
          Navigator.of(context).pop();
          print("Deleted '$LocationName' successfully.");
        })
        .catchError((error) {
          print("Failed to delete: $error");
        });
    getQuickLocationUserData();
  }

  void showAddQuickLocationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleAlertDialog(
          title: 'Add Quick Location',
          content: Container(
            child: AddQuickLocationContainer(
              nameController: AQLNameController,
              latController: AQLLatitudeController,
              longController: AQLLongitudeController,
            ),
          ),
          onConfirmButtonPressed: () {
            addQuickLocation(
              AQLNameController.text,
              double.parse(AQLLatitudeController.text),
              double.parse(AQLLongitudeController.text),
            );
            Navigator.pop(context);
          },
          confirmBtnText: "Add",
        );
      },
    );
  }

  void showEditQuickLocation(String locationName, double lat, double long) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleAlertDialog(
          title: "Edit Quick Location",
          content: AddQuickLocationContainer(
              nameController: AQLNameController,
              latController: AQLLatitudeController,
              longController: AQLLongitudeController,
            name: locationName,
            lat: lat,
            long: long,
            editing: true,
          ),
          onConfirmButtonPressed: () {},
          confirmBtnText: "Save",
        );
      },
    );
  }

  void showDeleteQuickLocation(String locationName, double lat, double long) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleAlertDialog(
          title: "Delete Quick Location",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$locationName", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
              SizedBox(height: 15),
              Text(
                "Are you sure you want to delete this quick location?",
                textAlign: TextAlign.center,
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ],
          ),
          onConfirmButtonPressed: () {deleteQuickLocation(locationName);},
          confirmBtnText: "Delete",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        scrolledUnderElevation: 0,
        backgroundColor: CupertinoColors.white,
        actionsPadding: EdgeInsets.only(right: 22),
        actions: [
          InkWell(
            onTap: () {
              showAddQuickLocationDialog();
            },
            child: Icon(
              Icons.add_circle_outline_rounded,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ],
        title: Text(
          "Quick Locations",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: quickLocations.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final entry = quickLocations.entries.toList()[index];
              final locationName = entry.key;
              final locationData = entry.value;
              final lat = locationData['lat'] ?? 0;
              final long = double.parse(locationData['long'].toString()) ?? 0;

              return SimpleContainer(
                title: "title",
                wantTitle: false,
                child: Column(
                  children: [
                    QuickLocationContainer(
                      locationName: locationName,
                      latitude: lat ?? 0,
                      longitude: long ?? 0,
                      onPressed: () {
                        showEditQuickLocation(locationName, lat, long);
                      },
                      onPressed2: () {
                        showDeleteQuickLocation(locationName, lat, long);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
