import 'dart:convert';

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:trip_tracker_app/Components/AlertDialogs.dart';
import 'package:trip_tracker_app/Components/Cards.dart';
import 'package:trip_tracker_app/Components/Containers.dart';
import '../Components/Buttons.dart';
import '../Components/TextFields.dart';
import '../Utils/AppColorTheme.dart';
import '../Utils/CommonFunctions.dart';
import 'dart:math';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TextEditingController singleDate = TextEditingController();
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  Map<String, dynamic>? userData;
  Map<String, dynamic> triplogs = {};
  bool isLoading = true;
  String? selectedDate;
  String API_KEY = "5b3ce3597851110001cf62480796a08341e447719309540c7e083620";
  bool showSummary = false;
  double total_expenditure = 0.0;
  double total_distance = 0.0;
  String? selectedVehicleFilter;

  String? selectedDate1;
  List<String> customSelectedDates=[];

  @override
  void initState() {
    super.initState();
    getUserData();
    setShowSummary(false);
  }

  void setShowSummary(bool value){
    setState(() {
      showSummary = value;
    });
  }

  List<String> getLastFiveDates() {
    return List.generate(5, (i) {
      return DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now().subtract(Duration(days: i)));
    });
  }

  void getUserData() async {
    userData = await CommonFunctions().getLoggedInUserInfo();
    triplogs = Map<String, dynamic>.from(userData?['triplogs'] ?? {});
    bool isSquareButtonEnabled = userData?['is_trip_started'] ?? false;
    print("ENABLED BTN $isSquareButtonEnabled");

    setState(() {
      isLoading = false;
    });

    print(":::: $userData");
  }

  // Future<void> _selectDate() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime.now(),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: ColorScheme.light(
  //             primary: Colors.blue,
  //             onPrimary: Colors.white,
  //             onSurface: Colors.black,
  //           ),
  //           textButtonTheme: TextButtonThemeData(
  //             style: TextButton.styleFrom(foregroundColor: Colors.blue),
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //
  //   if (picked != null) {
  //     setState(() {
  //       selectedDate = DateFormat('dd-MM-yyyy').format(picked);
  //     });
  //   }
  // }


  Future<void> OpenSetDateDialog() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        bool isSingleDateMode = true;
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setDialogState) {
            return SimpleAlertDialog(
              title: "Date Selection",
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomSwitchContentButtons(
                    firstWidget: Column(
                      children: [
                        DatePickerTextField(
                          controller: singleDate,
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
                          controller: fromDate,
                          label: "From",
                          prefillToday: false,
                          trialingIcon: Icon(Icons.calendar_month_rounded, color: CupertinoColors.activeBlue),
                          customBool: true,
                        ),
                        SizedBox(height: 30),
                        DatePickerTextField(
                          controller: toDate,
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
                        isSingleDateMode = useSingleDate;
                        if (isSingleDateMode) {
                          fromDate.clear();
                          toDate.clear();
                        } else {
                          singleDate.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              confirmBtnText: "Select",
                onConfirmButtonPressed: () {
                  try {
                    if (isSingleDateMode && singleDate.text.isNotEmpty) {
                      final picked = DateFormat('dd-MM-yyyy').parseStrict(singleDate.text);
                      final formatted = DateFormat('dd-MM-yyyy').format(picked);
                      Navigator.of(context).pop([formatted]); // Return List<String> with one formatted date
                    } else if (fromDate.text.isNotEmpty && toDate.text.isNotEmpty) {
                      final start = DateFormat('dd-MM-yyyy').parseStrict(fromDate.text);
                      final end = DateFormat('dd-MM-yyyy').parseStrict(toDate.text);

                      if (start.isAfter(end)) {
                        print("⚠️ Invalid date range: Start date is after end date.");
                        return;
                      }

                      final rangeDates = List.generate(
                        end.difference(start).inDays + 1,
                            (i) => DateFormat('dd-MM-yyyy').format(start.add(Duration(days: i))),
                      );

                      Navigator.of(context).pop(rangeDates); // Return full range as List<String>
                    } else {
                      print("⚠️ Please select valid date(s).");
                    }
                  } catch (e) {
                    print("❌ Error parsing date: $e");
                  }
                  setShowSummary(true);
                }


              // onConfirmButtonPressed: () {
              //   if (isSingleDateMode && singleDate.text.isNotEmpty) {
              //     final picked = DateFormat('yyyy-MM-dd').parseStrict(singleDate.text);
              //     final formatted = DateFormat('dd-MM-yyyy').format(picked);
              //     Navigator.of(context).pop([formatted]); // return single date
              //   } else if (fromDate.text.isNotEmpty && toDate.text.isNotEmpty) {
              //     final start = DateFormat('yyyy-MM-dd').parseStrict(fromDate.text);
              //     final end = DateFormat('yyyy-MM-dd').parseStrict(toDate.text);
              //
              //     if (start.isAfter(end)) {
              //       print("⚠️ Invalid date range.");
              //       return;
              //     }
              //
              //     final rangeDates = List.generate(
              //       end.difference(start).inDays + 1,
              //           (i) => DateFormat('dd-MM-yyyy').format(start.add(Duration(days: i))),
              //     );
              //
              //     Navigator.of(context).pop(rangeDates); // return range
              //   } else {
              //     print("⚠️ Please select valid date(s).");
              //   }
              // },
            );
          },
        );
      },
    );

    // 👇🏻 Update main state after dialog closes
    if (result != null && result.isNotEmpty) {
      setState(() {
        customSelectedDates = result;
        selectedDate = result.length == 1 ? result.first : "${result.first} to ${result.last}";
      });
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

  @override
  Widget build(BuildContext context) {
    List<String> datesToShow = customSelectedDates.isNotEmpty
        ? customSelectedDates
        : List.generate(5, (i) {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.now().subtract(Duration(days: i)));
    });

    print("Dates to show: $datesToShow");

    void calculateTodaysTotalDistanceAndExpenditure() {
      double total_expenditure2 = 0.0;
      double total_distance2 = 0.0;

      for (String date in datesToShow) {
        final logs = triplogs[date];

        if (logs != null && logs is List) {
          for (var log in logs) {
            final expenditure = double.tryParse(log['travel_cost'].toString());
            final distance = double.tryParse(log['distance'].toString());
            if (expenditure != null && distance != null) {
              total_expenditure2 += expenditure;
              total_distance2 += distance;
            }
          }
        } else {
          print("No trip logs found for $date");
        }
      }

      setState(() {
        total_expenditure = total_expenditure2;
        total_distance = total_distance2;
      });

      print("TOTAL:EXP =  $total_expenditure");
      print("TOTAL:DIST = $total_distance");
    }

    calculateTodaysTotalDistanceAndExpenditure();
    bool twoWheeler = false;
    bool fourWheeler = false;


    return Scaffold(
      backgroundColor: CupertinoColors.white,
      floatingActionButton: showSummary ? TransparentFab(
        expenditure: total_expenditure.toStringAsFixed(2) ?? "0.0",
        kms: total_distance.toStringAsFixed(2) ?? "0.0",
        text1: "Total Expenditure",
        text2: "Total Distance",
      ): SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        toolbarHeight: 80,
        scrolledUnderElevation: 0,
        backgroundColor: CupertinoColors.white,
        actionsPadding: EdgeInsets.only(right: 22),
        actions: [
          //TODO Needs Work Yet
          PopupMenuButton<String>(
            surfaceTintColor: CupertinoColors.white,
            icon: Icon(Icons.filter_alt_rounded, color: CupertinoColors.activeBlue),
            onSelected: (value) {
              setState(() {
                selectedVehicleFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: "2-Wheeler", child: Row(
                children: [
                  Checkbox(value: true, onChanged: (bool? value) {  },),
                  Text("2-Wheeler"),
                ],
              )),
              PopupMenuItem(value: "4-Wheeler", child: Row(
                children: [
                  Checkbox(value: true, onChanged: (bool? value) { value = false; },),
                  Text("4-Wheeler"),
                ],
              )),
            ],
          ),

          IconButton(
            onPressed: OpenSetDateDialog,
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
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: CupertinoColors.activeBlue,
                  backgroundColor: Colors.lightBlueAccent,
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SingleChildScrollView(
                  child: ListView.builder(
                    itemCount: datesToShow.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, dateIndex) {
                      String date = datesToShow[dateIndex];
                      List<dynamic> dayTrips = triplogs[date] ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SimpleContainer(
                            title: date,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                dayTrips.isEmpty
                                    ? Center(
                                      child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              "No logs to show!",
                                              style: TextStyle(
                                                color:
                                                    CupertinoColors.systemGrey2,
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
                                    : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: dayTrips.length,
                                      itemBuilder: (context, tripIndex) {
                                        final trip = Map<String, dynamic>.from(
                                          dayTrips[tripIndex],
                                        );
                                        print("trip info ${trip['distance']}");

                                        return ExpandableTripSummaryCard(
                                              from: trip['from'] ?? "~",
                                              to: trip['to'] ?? "~",
                                              departureTime:
                                                  trip['depart'] ?? "~",
                                              arrivalTime:
                                                  trip['arrive'] ?? "~",
                                              distance:
                                                  trip['distance']
                                                      ?.toString() ??
                                                  "~",
                                              expense:
                                                  trip['travel_cost']
                                                      ?.toString() ??
                                                  "~",
                                              riding: trip['to'] == "~",
                                              assetImage:
                                                  trip['vehicle'] == "2-Wheeler"
                                                      ? "Assets/bg_icon.png"
                                                      : "Assets/bg_icon2.png",
                                            startLat: trip["start"]?['latitude'] ?? 0.0,
                                            startLng: trip["start"]?['longitude'] ?? 0.0,
                                            endLat: trip["end"]?['latitude'] ?? 0.0,
                                            endLng: trip["end"]?['longitude'] ?? 0.0,
                                            routeData: trip['route'] ?? []
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
                ),
              ),
    );
  }
}
