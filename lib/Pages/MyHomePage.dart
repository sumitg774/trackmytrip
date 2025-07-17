import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:trip_tracker_app/Components/AlertDialogs.dart';
import 'package:trip_tracker_app/Components/Buttons.dart';
import 'package:trip_tracker_app/Components/Cards.dart';
import 'package:trip_tracker_app/Components/Containers.dart';
import '../ViewModels/HomeViewModel.dart';
import '../Components/TextFields.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String API_KEY = "5b3ce3597851110001cf62480796a08341e447719309540c7e083620";

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<HomeViewModel>(context, listen: false).loadUserData(),
    );
  }

  void showSignOutAlertDialog(HomeViewModel viewmodel) {
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
            Navigator.pop(context);
            viewmodel.signOut(context);
          },
          confirmBtnText: "Logout",
        );
      },
    );
  }

  void showStartTripAlertDialog(HomeViewModel viewmodel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<HomeViewModel>(
          builder: (context, viewModel, _) {
            return SimpleAlertDialog(
              title: "Start Trip",
              content:
                  viewmodel.isStartTripLoading
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
                            value: viewmodel.selectedVehicle,
                            items: ["2-Wheeler", "4-Wheeler"],
                            onChanged: (vehicle) {
                                viewmodel.selectedVehicle = vehicle;
                                viewmodel.notifyListeners();
                            },
                          ),
                          const SizedBox(height: 18),
                          CustomDropdown<String>(
                            hint: "Select Start Location",
                            value: viewmodel.selectedLocation,
                            items: ["Home", "Kibbcom Office", "Other"],
                            checked: viewmodel.isStartLocationChecked,
                            onChanged: (val) async {
                                viewmodel.verifyStartLocation(val);
                                viewmodel.notifyListeners();
                            },
                          ),
                          const SizedBox(height: 18),
                          viewmodel.selectedLocation == "Other"
                              ? CustomTextField(
                                hintText: "Enter Other Location",
                                controller: viewmodel.OtherLocation,
                              )
                              : const SizedBox(height: 0),
                        ],
                      ),
              onConfirmButtonPressed: () async {
                viewmodel.handleStartTrip(context);
              },
              confirmBtnText: "Start",
              confirmBtnState: !viewmodel.isStartLocationChecked ||
                  viewmodel.isStartTripLoading,
            );
          },
        );
      },
    );
  }

  void showEndTripAlertDialog(HomeViewModel viewmodel) {
    viewmodel.listenToEndTripContentFields();
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<HomeViewModel>(
          builder: (context, viewModel, _) {
            return SimpleAlertDialog(
              title: "End Trip",
              content:
                  viewmodel.isEndTripLoading
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
                          CustomTextField(
                            hintText: "Enter Destination",
                            controller: viewmodel.DestinationLocation,
                          ),
                          const SizedBox(height: 18),
                          DescriptionTextField(
                            hintText: "Description",
                            controller: viewmodel.DescriptionText,
                          ),
                        ],
                      ),
              onConfirmButtonPressed: () async {
                await viewmodel.endTrip(context);
              },
              confirmBtnText: "Save",
              confirmBtnState: viewmodel.isEndTripLoading || !viewmodel.isEndTripContentFilled,
            );
          },
        );
      },
    );
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

  void showTripStartedBanner(BuildContext context) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeGreen.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_bike_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trip Started!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Tracking in progress...",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    overlay.insert(entry);
    Future.delayed(Duration(seconds: 3), () => entry.remove());
  }

  void showDeleteTripLogDialog(int index, HomeViewModel viewmodel) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<HomeViewModel>(
          builder: (context, viewModel ,_) {
            return SimpleAlertDialog(
              title: 'Delete Trip log',
              content:
                  viewmodel.isDeletingTriplog
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
                          Icon(
                            Icons.delete,
                            size: 40,
                            color: CupertinoColors.destructiveRed,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Are you sure to permanently delete this trip log?",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
              onConfirmButtonPressed: () async {
                viewmodel.deleteTripLog(index, context);
              },
              confirmBtnText: 'Delete',
              confirmBtnState: viewmodel.isDeletingTriplog,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    if (viewModel.isLoading) {
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
      floatingActionButton:
          viewModel.isSquareButtonEnabled
              ? GestureDetector(
            onTap: (){ Navigator.pushNamed(context, "/quick_locations");},
              child: TripStartedContainer())
              : TransparentFab(
                expenditure:
                    viewModel.totalExpenditure.toStringAsFixed(2) ?? "0.0",
                kms: viewModel.totalDistance.toStringAsFixed(2) ?? "0.0",
                text1: "Today's Expenditure",
                text2: "Today's Distance",
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22),
            child: GestureDetector(
              child: Icon(
                Icons.share_location,
                color: CupertinoColors.activeBlue,
              ),
              onTap: () {
                Navigator.pushNamed(context, "/quick_locations");
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 22.0),
            child: GestureDetector(
              child: Icon(
                Icons.logout_rounded,
                color: CupertinoColors.destructiveRed,
              ),
              onTap: () {
                showSignOutAlertDialog(viewModel);
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
                viewModel.getGreetingMessage(),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                // userData?['name'] ?? '',
                viewModel.user?.name ?? '',
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
                        showStartTripAlertDialog(viewModel);
                      },
                      icon: Icons.play_arrow_rounded,
                      label: 'Start Trip',
                      isEnabled: !viewModel.isSquareButtonEnabled,
                      color: CupertinoColors.systemBlue,
                    ),
                    SquareIconButton(
                      onPressed: () {
                        showEndTripAlertDialog(viewModel);
                      },
                      icon: Icons.stop_rounded,
                      label: 'End Trip',
                      isEnabled: viewModel.isSquareButtonEnabled,
                      color: CupertinoColors.systemRed,
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                SimpleContainer(
                  title: "Today's Trip Logs",
                  child:
                  viewModel.todaysTriplogs.isEmpty
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
                                itemCount: viewModel.todaysTriplogs.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final trip = viewModel.todaysTriplogs[index];
                                  return TripSummaryCard(
                                        from: trip.from ?? "~",
                                        to: trip.to ?? "~",
                                        departureTime: trip.depart ?? "~",
                                        arrivalTime: trip.arrive ?? "~",
                                        distance: trip.distance ?? "~",
                                        expense: trip.travelCost ?? "~",
                                        riding: trip.to == "~" ? true : false,
                                        assetImage:
                                            trip.vehicle == "2-Wheeler"
                                                ? "Assets/bg_icon.png"
                                                : "Assets/bg_icon2.png",
                                        onSlideFunction: (context) async {
                                          showDeleteTripLogDialog(index, viewModel);
                                        },
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
