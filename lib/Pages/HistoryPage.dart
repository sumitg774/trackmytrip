import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:trip_tracker_app/Components/AlertDialogs.dart';
import 'package:trip_tracker_app/Components/Cards.dart';
import 'package:trip_tracker_app/Components/Containers.dart';
import 'package:trip_tracker_app/ViewModels/HistoryViewModel.dart';
import '../Components/Buttons.dart';
import '../Components/HeatMapCalender.dart';
import '../Components/TextFields.dart';
import '../Utils/AppColorTheme.dart';
import '../Utils/CommonFunctions.dart';
import 'dart:math';

import '../Utils/PdfGenerator.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  // Map<String, dynamic>? userData;
  String API_KEY = "5b3ce3597851110001cf62480796a08341e447719309540c7e083620";

  @override
  void initState() {
    super.initState();
    Future.microtask((){
      Provider.of<HistoryViewModel>(context, listen: false).getUserData();
    });
  }

  void setShowSummary(bool value, HistoryViewModel viewModel) {
      viewModel.showSummary = value;
      viewModel.calculateTotalDistanceAndExpenditure();
  }

  Future<void> OpenSetDateDialog(HistoryViewModel viewModel) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return SimpleAlertDialog(
              title: "Date Selection",
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomSwitchContentButtons(
                    firstWidget: Column(
                      children: [
                        DatePickerTextField(
                          controller: viewModel.singleDate,
                          label: "Pick a Date",
                          prefillToday: false,
                          trialingIcon: Icon(Icons.calendar_month_rounded, color: CupertinoColors.activeBlue),
                          customBool: true,
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                    secondWidget: Column(
                      children: [
                        DatePickerTextField(
                          controller: viewModel.fromDate,
                          label: "From",
                          prefillToday: false,
                          trialingIcon: Icon(Icons.calendar_month_rounded, color: CupertinoColors.activeBlue),
                          customBool: true,
                        ),
                        SizedBox(height: 30),
                        DatePickerTextField(
                          controller: viewModel.toDate,
                          label: "To",
                          prefillToday: false,
                          trialingIcon: Icon(Icons.calendar_month_rounded, color: CupertinoColors.activeBlue),
                          customBool: true,
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                    onToggle: (bool useSingleDate) {
                      setDialogState(() {
                        viewModel.toggleDateMode(useSingleDate);
                      });
                    },
                  ),
                ],
              ),
              confirmBtnText: "Submit",
              onConfirmButtonPressed: () {
                try {
                  final dates = viewModel.getSelectedDates();
                  Navigator.of(context).pop(dates);
                } catch (e) {
                  print("⚠️ Error selecting dates: $e");
                }
              },
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      viewModel.updateSelectedDates(result);
    }
  }

  Future<double?> getRouteDistanceFromORS({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final apiKey = API_KEY; // Replace with your actual ORS key
    final url = 'https://api.openrouteservice.org/v2/directions/driving-car?geometry_format=geojson';

    final body = {
      "coordinates": [
        [startLng, startLat], // longitude, latitude
        [endLng, endLat],
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json',
        },
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

          double distanceInKm = distanceInMeters / 1000;

          void prettyPrintJson(Map<String, dynamic> data) {
            const chunkSize = 800; // Adjust based on your console's limit
            final prettyJson = const JsonEncoder.withIndent('  ').convert(data);

            for (int i = 0; i < prettyJson.length; i += chunkSize) {
              final end = (i + chunkSize < prettyJson.length)
                  ? i + chunkSize
                  : prettyJson.length;
              print(prettyJson.substring(i, end));
            }
          }
          // prettyPrintJson(data);
          print("Route Distance: $distanceInKm KM");

          final encodedPolyline = data['routes'][0]['geometry'];

          PolylinePoints polylinePoints = PolylinePoints();
          List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPolyline);
          // print("148: $decodedPoints");

          final routePoints = decodedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();

          print("151: $routePoints");
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

  void showDeleteTripLogDialog(int index, String date, HistoryViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<HistoryViewModel>(
          builder: (context, viewModel, _) {
            return SimpleAlertDialog(
              title: 'Delete Trip log',
              content: viewModel.isDeletingTriplog
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
                viewModel.deleteTripLog(index, date, context);
              },
              confirmBtnText: 'Delete',
              confirmBtnState: viewModel.isDeletingTriplog,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HistoryViewModel>(context);

    final datesToShow = viewModel.datesToShow;
    final noLogsAvailable = viewModel.noLogsAvailable;
    final heatMapData = viewModel.dataForHeatMap;

    print("Dates to show: $datesToShow");

    return Scaffold(
      backgroundColor: CupertinoColors.white,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: IconButton(
                      onPressed: () async {
                        final flatData = viewModel.getFlatTripList();
                        await generateTripPdfReport(
                          flatData,
                          context,
                          viewModel.totalDistance.toStringAsFixed(2),
                          viewModel.totalExpenditure.toStringAsFixed(2),
                          viewModel.user!.name,
                          viewModel.user!.empId
                        );
                      },
                      icon: Icon(
                        Icons.file_download_rounded,
                        size: 25,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          viewModel.showSummary
              ? TransparentFab(
                expenditure: viewModel.totalExpenditure.toStringAsFixed(2) ?? "0.0",
                kms: viewModel.totalDistance.toStringAsFixed(2) ?? "0.0",
                text1: "Total Expenditure",
                text2: "Total Distance",
              )
              : SizedBox(),
        ],
      ),
      floatingActionButtonLocation:
          viewModel.showSummary
              ? FloatingActionButtonLocation.centerDocked
              : FloatingActionButtonLocation.endDocked,
      appBar: AppBar(
        toolbarHeight: 80,
        scrolledUnderElevation: 0,
        backgroundColor: CupertinoColors.white,
        actionsPadding: EdgeInsets.only(right: 22),
        actions: [
          IconButton(
            onPressed:(){OpenSetDateDialog(viewModel);},
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.black87,
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: const Text(
            "Recent",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: viewModel.isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: CupertinoColors.activeBlue,
          backgroundColor: Colors.lightBlueAccent,
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeatMapCalendarWidget(
                dateTimeMap: heatMapData,
                showCalender: true,
                onDateSelected: (DateTime date, int count) {
                  String formattedDate =
                  DateFormat('dd-MM-yyyy').format(date);
                    viewModel.customSelectedDates = [formattedDate];
                    viewModel.notifyListeners();
                    setShowSummary(true, viewModel);
                },
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      FilterButton(
                        onPressed: () {
                            viewModel.selectedVehicleFilter = '2-Wheeler';
                            viewModel.notifyListeners();
                        },
                        icon: Icons.two_wheeler,
                        backgroundColor: viewModel.selectedVehicleFilter == '2-Wheeler'
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        iconColor: viewModel.selectedVehicleFilter == '2-Wheeler'
                            ? CupertinoColors.white
                            : CupertinoColors.activeBlue,
                      ),
                      SizedBox(width:10),
                      FilterButton(
                        icon: Icons.directions_car_filled,
                        backgroundColor:
                        viewModel.selectedVehicleFilter == '4-Wheeler'
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        onPressed: () {
                          viewModel.selectedVehicleFilter = '4-Wheeler';
                          viewModel.notifyListeners();
                        },
                        iconColor: viewModel.selectedVehicleFilter == '4-Wheeler'
                            ? CupertinoColors.white
                            : CupertinoColors.activeBlue,
                      ),
                      SizedBox(width:10),
                      FilterButton(
                        wantText: true,
                        BtnText: " All ",
                        iconColor: viewModel.selectedVehicleFilter == null
                            ? CupertinoColors.white
                            : CupertinoColors.activeBlue,
                        backgroundColor:
                        viewModel.selectedVehicleFilter == null
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        onPressed: () {
                          viewModel.selectedVehicleFilter = null;
                          viewModel.notifyListeners();
                        },
                      ),
                      SizedBox(width:10),
                    ],
                  ),
                ],
              ),
                      const SizedBox(height: 10),

              if (noLogsAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Center(
                    child: Text(
                      "No logs to show!",
                      style: TextStyle(
                        color: CupertinoColors.systemGrey2,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  itemCount: viewModel.datesToShow.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, dateIndex) {
                    String date = viewModel.datesToShow[dateIndex];
                    // List<dynamic> dayTrips = triplogs[date] ?? [];
                    List<dynamic> originalTrips = viewModel.user?.triplogs[date] ?? [];
                    List<dynamic> dayTrips = viewModel.selectedVehicleFilter == null
                        ? originalTrips
                        : originalTrips.where((trip) => trip.vehicle == viewModel.selectedVehicleFilter).toList();

                    if (dayTrips.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SimpleContainer(
                          title: date,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                itemCount: dayTrips.length,
                                itemBuilder: (context, tripIndex) {
                                  final trip = dayTrips[tripIndex].toMap();

                                  return ExpandableTripSummaryCard(
                                    from: trip['from'] ?? "~",
                                    to: trip['to'] ?? "~",
                                    departureTime: trip['depart'] ?? "~",
                                    arrivalTime: trip['arrive'] ?? "~",
                                    distance:
                                    trip['distance']?.toString() ?? "~",
                                    expense: trip['travelCost']
                                        ?.toString() ??
                                        "~",
                                    riding: trip['to'] == "~",
                                    assetImage: trip['vehicle'] ==
                                        "2-Wheeler"
                                        ? "Assets/bg_icon.png"
                                        : "Assets/bg_icon2.png",
                                    startLat: trip["start"]['latitude'],
                                    startLng: trip['start']['longitude'],
                                    endLat: trip['end']?['latitude'] ?? 0,
                                    endLng: trip['end']?['longitude'] ?? 0,
                                    routeData: trip['route'],
                                    onSlideFunction: (context)async{
                                      showDeleteTripLogDialog(tripIndex, date, viewModel);
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
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              SizedBox(height: 50,)
            ],
          ),
        ),
      ),
    );
  }
}
