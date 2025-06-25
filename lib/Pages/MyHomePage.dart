import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' as gmaps;
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
  String? selectedVehicle;
  late List<dynamic> TodaysTripLogs = [];
  TextEditingController OtherLocation = TextEditingController();
  TextEditingController DestinationLocation = TextEditingController();
  TextEditingController DescriptionText = TextEditingController();
  double? total_distance;
  double? total_expenditure;
  String API_KEY = "5b3ce3597851110001cf62480796a08341e447719309540c7e083620";
  bool checked = false;

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
    TodaysTripLogs = await triplogsMap?[todayKey] ?? [];
    print('LISTLIST: $TodaysTripLogs');
    isSquareButtonEnabled = await userData?['is_trip_started'];
    print("ENABLED BTN $isSquareButtonEnabled");
    setState(() {
      isLoading = false;
    });
    calculateTodaysTotalDistance();
    calculateTodaysTotalExpenditure();

    print(":::: $userData");
  }

  void calculateTodaysTotalDistance() {
    double total_distance2 = 0.0;

    TodaysTripLogs.forEach((log) {
      final distance = double.tryParse(log['distance']) ?? 0.0;
      print("_________$distance");
      if (distance != null) {
        total_distance2 += distance;
      }
    });

    setState(() {
      total_distance = total_distance2;
    });

    // print(":::TOTAL DISTANCE: ${total_distance.toStringAsFixed(2)}");
  }

  void calculateTodaysTotalExpenditure() {
    double total_expenditure2 = 0.0;
    TodaysTripLogs.forEach((log) {
      final expenditure = double.tryParse(log['travel_cost']);
      print("_________$expenditure");
      if (expenditure != null) {
        total_expenditure2 += expenditure;
      }
    });

    setState(() {
      total_expenditure = total_expenditure2;
    });
  }

  void showSignOutAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleAlertDialog(
          title: "Sign Out",
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: CupertinoColors.destructiveRed,
                size: 45,
              ),
              SizedBox(height: 20),
              Text(
                "Do you want to logout?",
                style: TextStyle(
                  color: CupertinoColors.systemGrey2,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          onConfirmButtonPressed: () {
            SignOut();
          },
          confirmBtnText: "Logout",
        );
      },
    );
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
              content:
                  isLoading
                      ? SizedBox(
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: CupertinoColors.activeBlue,
                            backgroundColor: Colors.lightBlueAccent,
                          ),
                        ),
                      )
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomDropdown<String>(
                            hint: "Select Your Vehicle",
                            value: selectedVehicle,
                            items: ["2-Wheeler", "4-Wheeler"],
                            onChanged: (vehicle) {
                              setState(() {
                                selectedVehicle = vehicle;
                              });
                            },
                          ),
                          const SizedBox(height: 18),
                          CustomDropdown<String>(
                            hint: "Select Start Location",
                            value: selectedLocation,
                            items: ["Home", "Kibbcom Office", "Other"],
                            checked: checked,
                            onChanged: (val) async {
                              setState(() {
                                selectedLocation = val;
                                isLoading = true;
                              });

                              Map<String, LatLng> locationCoordinates = {
                                "Home": LatLng(12.9715987, 77.594566),
                                "Kibbcom Office": LatLng(12.955343, 77.714901),
                              };

                              if (val != "Other") {
                                LatLng? target = locationCoordinates[val!];
                                if (target == null) return;
                                Position currentLocation =
                                    await Geolocator.getCurrentPosition();
                                double distancedifference =
                                    Geolocator.distanceBetween(
                                      currentLocation.latitude,
                                      currentLocation.longitude,
                                      target.latitude,
                                      target.longitude,
                                    );

                                if (distancedifference < 100) {
                                  setState(() {
                                    checked = true;
                                  });
                                } else {
                                  setState(() {
                                    checked = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  checked = true;
                                });
                              }
                              isLoading = false;
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
              confirmBtnState: !checked,
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
          confirmBtnText: "Save",
        );
      },
    );
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  void SignOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  StreamSubscription<Position>? positionStream;
  List<LatLng> routeCoordinates = [];

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
      final String? vehicle = selectedVehicle;

      String? collectionName =
          await StorageService.instance.getCollectionName();
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      final userDocRef = FirebaseFirestore.instance
          .collection(collectionName!)
          .doc(uid);

      final Map<String, dynamic> TripLog = {
        "tripId": tripId,
        "from": from,
        "to": "~",
        "depart": starttimestamp,
        "start": {"latitude": startlatitude, "longitude": startlongitude},
        "vehicle": vehicle,
        "route": [], // This will hold tracked route
      };

      await userDocRef.set({
        'triplogs': {
          date: FieldValue.arrayUnion([TripLog]),
        },
        'is_trip_started': true,
      }, SetOptions(merge: true));

      print("Firebase Updated Successfully");

      // Start continuous tracking
      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 7,
        ),
      ).listen((Position pos) async {
        LatLng current = LatLng(pos.latitude, pos.longitude);
        routeCoordinates.add(current);

        // Create a route list of maps
        final List<Map<String, dynamic>> routeList =
            routeCoordinates
                .map(
                  (coord) => {
                    'latitude': coord.latitude,
                    'longitude': coord.longitude,
                  },
                )
                .toList();

        // 👇 Update the specific trip log with route in Firebase
        DocumentSnapshot snapshot = await userDocRef.get();
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> todaysTrips = List.from(data['triplogs'][date] ?? []);

        // Find and update the specific trip by tripId
        for (int i = 0; i < todaysTrips.length; i++) {
          if (todaysTrips[i]['tripId'] == tripId) {
            todaysTrips[i]['route'] = routeList;
            break;
          }
        }

        await userDocRef.update({'triplogs.$date': todaysTrips});

        print("Route updated: ${current.latitude}, ${current.longitude}");
      });
    } catch (e) {
      print("An Error Occurred: $e");
    }
  }

  Future<double?> getRouteDistanceFromORS({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final apiKey = API_KEY; // Replace with your actual ORS key
    final url = 'https://api.openrouteservice.org/v2/directions/driving-car';

    final body = {
      "coordinates": [
        [startLng, startLat], // longitude, latitude
        [endLng, endLat],
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Updated structure based on actual ORS response
        if (data != null &&
            data['routes'] != null &&
            data['routes'] is List &&
            data['routes'].isNotEmpty &&
            data['routes'][0]['summary'] != null &&
            data['routes'][0]['summary']['distance'] != null) {
          final distanceInMeters = data['routes'][0]['summary']['distance'];
          final geometry = data['routes'][0]['geometry']['coordinates'];

          double distanceInKm = distanceInMeters / 1000;
          print("Route Distance: $distanceInKm KM");

          final List<LatLng> routePoints =
              geometry
                  .map<LatLng>((point) => LatLng(point[1], point[0]))
                  .toList();

          print("ROUTE::::::::::: $routePoints");

          return distanceInKm;
        } else {
          print("Malformed ORS response: ${jsonEncode(data)}");
        }
      } else {
        print("ORS API Error: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("ORS Exception: $e");
    }
    return null;
  }

  Future<void> stopTrip() async {
    await positionStream?.cancel();
    print("Tracking stopped");
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

      print("LAT AND LONGS REQ ::: $startlatitude, $startlongitude");

      // double? routeData = await getRouteDistanceFromORS(
      //   startLat: startlatitude,
      //   startLng: startlongitude,
      //   endLat: endlatitude,
      //   endLng: endlongitude,
      // );

      // if (routeData == null) {
      //   print("Failed to get route distance from ORS");
      //   return;
      // }
      //
      // print("::::total Distance:::: ${routeData}");
      //
      // double? totalDistance = routeData;

      await stopTrip();
      double totalDistance = 0.0;

      for (int i = 0; i < routeCoordinates.length - 1; i++) {
        totalDistance += Geolocator.distanceBetween(
          routeCoordinates[i].latitude,
          routeCoordinates[i].longitude,
          routeCoordinates[i + 1].latitude,
          routeCoordinates[i + 1].longitude,
        );
      }

      print("Total distance traveled: ${totalDistance / 1000} km");

      double companyTravelAllowance =
          tripsForToday[indexToUpdate]['vehicle'] == "2-Wheeler" ? 5 : 8;

      final Map<String, dynamic> endData = {
        "to": to,
        "arrive": endtimestamp,
        "end": {"latitude": endlatitude, "longitude": endlongitude},
        "desc": desc,
        "distance": (totalDistance / 1000).toStringAsFixed(2),
        "travel_cost": ((totalDistance / 1000) * companyTravelAllowance)
            .toStringAsFixed(2),
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
      floatingActionButton: TransparentFab(
        expenditure: total_expenditure?.toStringAsFixed(2) ?? "0.0",
        kms: total_distance?.toStringAsFixed(2) ?? "0.0",
        text1: "Today's Expenditure",
        text2: "Today's Distance",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        scrolledUnderElevation: 0,
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 22),
          //   child: GestureDetector(
          //     child: Icon(
          //       Icons.share_location,
          //       color: CupertinoColors.activeBlue,
          //     ),
          //     onTap: (){
          //       Navigator.pushNamed(context, "/quick_locations");
          //     },
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(right: 22.0),
            child: GestureDetector(
              child: Icon(
                Icons.logout_rounded,
                color: CupertinoColors.destructiveRed,
              ),
              onTap: () {
                showSignOutAlertDialog();
              },
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
              Text(
                getGreetingMessage(),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                  child:
                      TodaysTripLogs.isEmpty
                          ? Center(
                            child: Padding(
                                  padding: const EdgeInsets.only(top: 66.0),
                                  child: Text(
                                    "No Trip Logs yet!",
                                    style: TextStyle(
                                      color: CupertinoColors.systemGrey2,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                                .animate()
                                .fade(duration: 400.ms)
                                .scale(
                                  begin: Offset(0.8, 0.8),
                                  end: Offset(1, 1),
                                  curve: Curves.easeOut,
                                )
                                .moveY(
                                  begin: 30,
                                  end: 0,
                                  duration: 500.ms,
                                  curve: Curves.easeOutBack,
                                ),
                          )
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListView.builder(
                                itemCount: TodaysTripLogs.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return TripSummaryCard(
                                        from:
                                            TodaysTripLogs[index]['from'] ??
                                            "~",
                                        to: TodaysTripLogs[index]['to'] ?? "~",
                                        departureTime:
                                            TodaysTripLogs[index]['depart'] ??
                                            "~",
                                        arrivalTime:
                                            TodaysTripLogs[index]['arrive'] ??
                                            "~",
                                        distance:
                                            TodaysTripLogs[index]['distance'] ??
                                            "~",
                                        expense:
                                            TodaysTripLogs[index]['travel_cost'] ??
                                            "~",
                                        riding:
                                            TodaysTripLogs[index]['to'] == "~"
                                                ? true
                                                : false,
                                        assetImage:
                                            TodaysTripLogs[index]['vehicle'] ==
                                                    "2-Wheeler"
                                                ? "Assets/bg_icon.png"
                                                : "Assets/bg_icon2.png",
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
