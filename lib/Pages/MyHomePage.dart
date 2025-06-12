import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSquareButtonEnabled = true;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? selectedLocation;

  @override
  void initState() {
    Geolocator.requestPermission();
    super.initState();
    getUserData();
  }

  void getUserData() async {
    userData = await CommonFunctions().getLoggedInUserInfo();
    setState(() {
      isLoading = false;
    });
    print(":::: $userData");
  }

  void showStartTripAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleAlertDialog(
          title: "Start Trip",
          selectedLocation: selectedLocation,
          onPressed: () async{
            await startTrip();
            setEnabledStatus(false);
            Navigator.pop(context);
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
          title: "End trip",
          selectedLocation: selectedLocation,
          onPressed: () {
            setEnabledStatus(true);
            Navigator.pop(context);
          },
          endDialog: true,
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
      final String starttimestamp = DateTime.now().toIso8601String();
      final String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final String? from = selectedLocation;
      final String? to = '~';
      final String tripId = _uuid.v4();

      final Map<String, dynamic> TripLog = {
          "tripId": tripId,
          "from": from,
          "depart": starttimestamp,
          'arrive': "~",
          "to": to,
          "start": {
            "latitude":startlatitude,
            "longitude":startlongitude
          },
      };
      String? collectionName = await StorageService.instance.getCollectionName();
      print("CO: $collectionName");

      String? uid = FirebaseAuth.instance.currentUser?.uid;
      print("U $uid");

      final userDocRef = FirebaseFirestore.instance.collection(collectionName!).doc(uid);

      Map<String, dynamic> userData = await CommonFunctions().getLoggedInUserInfo() ?? {};
      Map<String, dynamic> triplogs = Map<String, dynamic>.from(userData['triplogs'] ?? {});
      List<dynamic> tripsForToday = List.from(triplogs[date]?['trips'] ?? []);
      tripsForToday.add(TripLog);

      await userDocRef.set({
        'triplogs': {
          date: FieldValue.arrayUnion([TripLog]),
        }
      }, SetOptions(merge: true));
      print("Firebase Updated Successfully");

    } catch (e) {
      print("An Error Occurred ${e}");
    }
  }

  void setEnabledStatus(bool val) {
    setState(() {
      isSquareButtonEnabled = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: CupertinoColors.activeBlue),
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
                MaterialPageRoute(builder: (context) => const LoginPage());
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
                      isEnabled: isSquareButtonEnabled,
                      color: CupertinoColors.systemBlue,
                    ),
                    SquareIconButton(
                      onPressed: () {
                        showEndTripAlertDialog();
                      },
                      icon: Icons.stop_rounded,
                      label: 'End Trip',
                      isEnabled: !isSquareButtonEnabled,
                      color: CupertinoColors.systemRed,
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                SimpleContainer(
                  title: "Today's Trip Logs",
                  child: Column(
                    children: const [
                      TripSummaryCard(
                        from: "Kibbcom",
                        to: "Client A",
                        departureTime: "9:00",
                        arrivalTime: "12:00",
                        distance: "20 kms",
                        expense: "200",
                        riding: false,
                      ),
                      TripSummaryCard(
                        from: "Client A",
                        to: "~",
                        departureTime: "12:30",
                        arrivalTime: "~",
                        distance: "~ kms",
                        expense: "~",
                        riding: true,
                      ),
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
