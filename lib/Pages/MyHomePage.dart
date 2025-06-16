import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:trip_tracker_app/Components/AlertDialogs.dart';
import 'package:trip_tracker_app/Components/Buttons.dart';
import 'package:trip_tracker_app/Components/Cards.dart';
import 'package:trip_tracker_app/Components/Containers.dart';
import 'package:trip_tracker_app/Utils/CommonFunctions.dart';
import 'package:trip_tracker_app/Utils/StorageService.dart';
import 'package:uuid/uuid.dart';

import 'LoginPage.dart';

import '../Components/TextFields.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool isSquareButtonEnabled;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? selectedLocation;
  late List<dynamic> TodaysTripLogs = [];
  TextEditingController OtherLocation = TextEditingController();
  TextEditingController DestinationLocation = TextEditingController();
  TextEditingController DescriptionText = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    userData = await CommonFunctions().getLoggedInUserInfo();
    final triplogsMap = userData?['triplogs'] as Map<String, dynamic>?;
    final todayKey = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now()); // import intl
    TodaysTripLogs = triplogsMap?[todayKey] ?? [];
    print('LISTLIST: $TodaysTripLogs');
    isSquareButtonEnabled = await userData?['is_trip_started'];
    print("ENABLED BTN $isSquareButtonEnabled");
    setState(() {
      isLoading = false;
    });
    print(":::: $userData");
  }

  void showStartTripAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setState,
          ) {
            return SimpleAlertDialog(
              title: "Start Trip",
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomDropdown<String>(
                    hint: "Select Start Location",
                    value: selectedLocation,
                    items: ["Home", "Kibbcom Office", "Other"],
                    onChanged: (val) {
                      setState(() {
                        selectedLocation = val;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  selectedLocation == "Other"
                      ? CustomTextField(
                        hintText: "Enter Other Location",
                        controller: OtherLocation,
                      )
                      : const SizedBox(height: 0),
                ],
              ),
              onConfirmButtonPressed: () async {
                await startTrip();
                setEnabledStatus(true);
                print("SELECTED LOC :: $selectedLocation");
                getUserData();
                Navigator.pop(context);
              },
              confirmBtnText: "Start",
            );
          },
        );
      },
    );
  }

  void showEndTripAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleAlertDialog(
          title: "End Trip",
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                hintText: "Enter Destination",
                controller: DestinationLocation,
              ),
              const SizedBox(height: 18),
              DescriptionTextField(
                hintText: "Description",
                controller: DescriptionText,
              ),
            ],
          ),
          onConfirmButtonPressed: () async {
            await endTrip();
            setEnabledStatus(false);
            getUserData();
            Navigator.pop(context);
          },
          confirmBtnText: "End",
        );
      },
    );
  }

  Future<void> startTrip() async {
    final Uuid _uuid = Uuid();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location Permissions are denied!");
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final double startlatitude = position.latitude;
      final double startlongitude = position.longitude;
      final String starttimestamp = DateFormat.Hm().format(DateTime.now());
      final String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final String? from =
          selectedLocation == 'Other' ? OtherLocation.text : selectedLocation;
      final String tripId = _uuid.v4();

      final Map<String, dynamic> TripLog = {
        "tripId": tripId,
        "from": from,
        "to": "~",
        "depart": starttimestamp,
        "start": {"latitude": startlatitude, "longitude": startlongitude},
      };
      String? collectionName =
          await StorageService.instance.getCollectionName();
      print("CO: $collectionName");

      String? uid = FirebaseAuth.instance.currentUser?.uid;
      print("U $uid");

      final userDocRef = FirebaseFirestore.instance
          .collection(collectionName!)
          .doc(uid);
      Map<String, dynamic> userData =
          await CommonFunctions().getLoggedInUserInfo() ?? {};
      Map<String, dynamic> triplogs = Map<String, dynamic>.from(
        userData['triplogs'] ?? {},
      );
      List<dynamic> tripsForToday = List.from(triplogs[date] ?? []);
      tripsForToday.add(TripLog);

      await userDocRef.set({
        'triplogs': {
          date: FieldValue.arrayUnion([TripLog]),
        },
      }, SetOptions(merge: true));
      print("Firebase Updated Successfully");
    } catch (e) {
      print("An Error Occurred ${e}");
    }
  }

  Future<void> endTrip() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location Permissions are denied!");
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final double endlatitude = position.latitude;
      final double endlongitude = position.longitude;
      final String endtimestamp = DateFormat.Hm().format(DateTime.now());
      final String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final String to = DestinationLocation.text;
      final String desc = DescriptionText.text;

      String? collectionName =
          await StorageService.instance.getCollectionName();
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (collectionName == null || uid == null) {
        print("Collection name or UID is null.");
        return;
      }

      final userDocRef = FirebaseFirestore.instance
          .collection(collectionName)
          .doc(uid);

      Map<String, dynamic> userData =
          await CommonFunctions().getLoggedInUserInfo() ?? {};
      Map<String, dynamic> triplogs = Map<String, dynamic>.from(
        userData['triplogs'] ?? {},
      );
      List<dynamic> tripsForToday = List.from(triplogs[date] ?? []);

      int indexToUpdate = tripsForToday.lastIndexWhere(
        (trip) => trip['to'] == "~",
      );

      if (indexToUpdate == -1) {
        print("No ongoing trip found with 'to': ~");
        return;
      }

      double startlatitude = tripsForToday[indexToUpdate]['start']['latitude'];
      double startlongitude =
          tripsForToday[indexToUpdate]['start']['longitude'];

      double totalDistance =
          Geolocator.distanceBetween(
            startlatitude,
            startlongitude,
            endlatitude,
            endlongitude,
          ) /
          1000;
      print(":::: total Distance::::: $totalDistance");

      final Map<String, dynamic> endData = {
        "to": to,
        "arrive": endtimestamp,
        "end": {"latitude": endlatitude, "longitude": endlongitude},
        "desc": desc,
        "distance": totalDistance.toStringAsFixed(2),
        "travel_cost": (totalDistance * 10).toStringAsFixed(2),
      };

      Map<String, dynamic> existingTrip = Map<String, dynamic>.from(
        tripsForToday[indexToUpdate],
      );
      existingTrip.addAll(endData);

      tripsForToday[indexToUpdate] = existingTrip;

      await userDocRef.set({
        'triplogs': {date: tripsForToday},
      }, SetOptions(merge: true));

      print("Trip ended and Firebase updated successfully.");
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void setEnabledStatus(bool val) async {
    try {
      String? collectionName =
          await StorageService.instance.getCollectionName();
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null && collectionName != null) {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(uid)
            .update({'is_trip_started': val});

        print("Updated 'is_trip_started' to $val in Firebase");
      } else {
        print("Error: uid or collection name is null");
      }
    } catch (e) {
      print("Failed to update 'is_trip_started': $e");
    }
    setState(() {
      isSquareButtonEnabled = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userData == null) {
      return const Scaffold(
        backgroundColor: CupertinoColors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: CupertinoColors.activeBlue,
            backgroundColor: Colors.lightBlueAccent,
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: TransparentFab(expenditure: "200.0", kms: "20.0"),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22.0),
            child: GestureDetector(
              child: Icon(
                Icons.logout_rounded,
                color: CupertinoColors.destructiveRed,
              ),
              onTap:(){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              }
            ),
          ),
        ],
        flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double screenwidth = constraints.maxWidth;
            return Stack(
              children: [
                Positioned(
                  right: screenwidth * 0.855,
                  bottom: -5,
                  child: Icon(
                    Icons.circle,
                    size: 100,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
            );
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Good Morning!",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                userData?['name'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: CupertinoColors.white,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SquareIconButton(
                      onPressed: () {
                        showStartTripAlertDialog();
                      },
                      icon: Icons.play_arrow_rounded,
                      label: 'Start Trip',
                      isEnabled: !isSquareButtonEnabled,
                      color: CupertinoColors.systemBlue,
                    ),
                    SquareIconButton(
                      onPressed: () {
                        showEndTripAlertDialog();
                      },
                      icon: Icons.stop_rounded,
                      label: 'End Trip',
                      isEnabled: isSquareButtonEnabled,
                      color: CupertinoColors.systemRed,
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                SimpleContainer(
                  title: "Today's Trip Logs",
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.builder(
                        itemCount: TodaysTripLogs.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return TripSummaryCard(
                                from: TodaysTripLogs[index]['from'] ?? "~",
                                to: TodaysTripLogs[index]['to'] ?? "~",
                                departureTime:
                                    TodaysTripLogs[index]['depart'] ?? "~",
                                arrivalTime:
                                    TodaysTripLogs[index]['arrive'] ?? "~",
                                distance:
                                    TodaysTripLogs[index]['distance'] ?? "~",
                                expense:
                                    TodaysTripLogs[index]['travel_cost'] ??
                                    "~",
                                riding:
                                    TodaysTripLogs[index]['to'] == "~"
                                        ? true
                                        : false,
                              )
                              .animate()
                              .fade(
                                duration: 100.ms,
                                curve: Curves.easeOut,
                                delay: 100.ms,
                              )
                              .slideY(
                                begin: 1.8,
                                curve: Curves.fastEaseInToSlowEaseOut,
                                duration: 1000.ms,
                              );
                        },
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
