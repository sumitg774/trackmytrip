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
import 'package:trip_tracker_app/Components/AlertDialogs.dart';
import 'package:trip_tracker_app/Components/Cards.dart';
import 'package:trip_tracker_app/Components/Containers.dart';
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

  Map<DateTime, int?> dataforHeatMap = {};
  String? selectedDate1;
  List<String> customSelectedDates = [];

  @override
  void initState() {
    super.initState();
    getUserData();
    setShowSummary(false);
    customSelectedDates = [];
  }

  void setShowSummary(bool value) {
    setState(() {
      showSummary = value;
    });
    final bool showCalender = true;
  }

  List<String> getLastFiveDates() {
    return List.generate(5, (i) {
      return DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now().subtract(Duration(days: i)));
    });
  }

  void getUserData() async {
    Permission.manageExternalStorage.request();
    userData = await CommonFunctions().getLoggedInUserInfo();
    triplogs = Map<String, dynamic>.from(userData?['triplogs'] ?? {});
    bool isSquareButtonEnabled = userData?['is_trip_started'] ?? false;
    print("ENABLED BTN $isSquareButtonEnabled");

    setState(() {
      isLoading = false;
    });

    print(":::: $userData");
  }

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
                confirmBtnText: "Submit",
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
            );
          },
        );
      },
    );
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

    Map<String, dynamic> triplogs = Map<String, dynamic>.from(
      userData?['triplogs'] ?? {},
    );
    bool noLogsAvailable = datesToShow.every((date) =>
    triplogs[date] == null || (triplogs[date] as List).isEmpty);

    // Populate heat map data
    triplogs.forEach((dateStr, entries) {
      if (entries != null && entries.isNotEmpty) {
        final parts = dateStr.split('-');
        final date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        dataforHeatMap[date] = 1;
      }
    });

    print("Dates to show: $datesToShow");

    void calculateTodaysTotalDistanceAndExpenditure() {
      double totalExpenditure = 0.0;
      double totalDistance = 0.0;

      for (String date in datesToShow) {
        List<dynamic> originalTrips = triplogs[date] ?? [];
        List<dynamic> dayTrips = selectedVehicleFilter == null
            ? originalTrips
            : originalTrips.where((trip) => trip['vehicle'] == selectedVehicleFilter).toList();

        for (var trip in dayTrips) {
          final expenditure = double.tryParse(trip['travel_cost'].toString());
          final distance = double.tryParse(trip['distance'].toString());

          if (expenditure != null && distance != null) {
            totalExpenditure += expenditure;
            totalDistance += distance;
          }}

      }

      setState(() {
        total_expenditure = totalExpenditure;
        total_distance = totalDistance;
      });

      print("TOTAL:EXP = $total_expenditure");
      print("TOTAL:DIST = $total_distance");
    }

    calculateTodaysTotalDistanceAndExpenditure();

    List<Map<String, dynamic>> getFlatTripList() {
      List<Map<String, dynamic>> allTrips = [];

      for (String date in datesToShow) {
        // List<dynamic> dayTrips = triplogs[date] ?? [];
        // List<dynamic> dayTrips = triplogs[date] ?? [];
        List<dynamic> originalTrips = triplogs[date] ?? [];
        List<dynamic> dayTrips = selectedVehicleFilter == null
            ? originalTrips
            : originalTrips.where((trip) => trip['vehicle'] == selectedVehicleFilter).toList();

        for (var tripRaw in dayTrips) {
          final trip = Map<String, dynamic>.from(tripRaw);

          allTrips.add({
            'Date': date,
            'From': trip['from'] ?? '~',
            'To': trip['to'] ?? '~',
            'Departure': trip['depart'] ?? '~',
            'Arrival': trip['arrive'] ?? '~',
            'Distance (km)': double.parse(trip['distance']!.toString()) ?? '~',
            'Expenditure (₹)':
                double.parse(trip['travel_cost']!.toString()) ?? '~',
            'Vehicle': trip['vehicle'] ?? '~',
          });
        }
      }
      return allTrips;
    }

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
                        final flatData = getFlatTripList();
                        await generateTripPdfReport(
                          flatData,
                          context,
                          total_distance.toStringAsFixed(2),
                          total_expenditure.toStringAsFixed(2),
                          userData?['name'],
                          userData?['emp_id']
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
          showSummary
              ? TransparentFab(
                expenditure: total_expenditure.toStringAsFixed(2) ?? "0.0",
                kms: total_distance.toStringAsFixed(2) ?? "0.0",
                text1: "Total Expenditure",
                text2: "Total Distance",
              )
              : SizedBox(),
        ],
      ),
      floatingActionButtonLocation:
          showSummary
              ? FloatingActionButtonLocation.centerDocked
              : FloatingActionButtonLocation.endDocked,
      appBar: AppBar(
        toolbarHeight: 80,
        scrolledUnderElevation: 0,
        backgroundColor: CupertinoColors.white,
        actionsPadding: EdgeInsets.only(right: 22),
        actions: [
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
      body: isLoading
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
                dateTimeMap: dataforHeatMap,
                showCalender: true,
                onDateSelected: (DateTime date, int count) {
                  String formattedDate =
                  DateFormat('dd-MM-yyyy').format(date);
                  setState(() {
                    customSelectedDates = [formattedDate];
                    setShowSummary(true);
                    // date1 =datesToShow as String;
                  });
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
                          setState(() {
                            selectedVehicleFilter = '2-Wheeler';
                          });
                        },
                        icon: Icons.two_wheeler,
                        backgroundColor: selectedVehicleFilter == '2-Wheeler'
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        iconColor: selectedVehicleFilter == '2-Wheeler'
                            ? CupertinoColors.white
                            : CupertinoColors.activeBlue,
                      ),
                      SizedBox(width:10),
                      FilterButton(
                        icon: Icons.directions_car_filled,
                        backgroundColor:
                        selectedVehicleFilter == '4-Wheeler'
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        onPressed: () {
                          setState(() {
                            selectedVehicleFilter = '4-Wheeler';
                          });
                        },
                        iconColor: selectedVehicleFilter == '4-Wheeler'
                            ? CupertinoColors.white
                            : CupertinoColors.activeBlue,
                      ),
                      SizedBox(width:10),
                      FilterButton(
                        wantText: true,
                        BtnText: " All ",
                        iconColor: selectedVehicleFilter == null
                            ? CupertinoColors.white
                            : CupertinoColors.activeBlue,
                        backgroundColor:
                        selectedVehicleFilter == null
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        onPressed: () {
                          setState(() {
                            selectedVehicleFilter = null;
                          });
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
                  itemCount: datesToShow.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, dateIndex) {
                    String date = datesToShow[dateIndex];
                    // List<dynamic> dayTrips = triplogs[date] ?? [];
                    List<dynamic> originalTrips = triplogs[date] ?? [];
                    List<dynamic> dayTrips = selectedVehicleFilter == null
                        ? originalTrips
                        : originalTrips.where((trip) => trip['vehicle'] == selectedVehicleFilter).toList();

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
                                  final trip = Map<String, dynamic>.from(
                                      dayTrips[tripIndex]);

                                  return ExpandableTripSummaryCard(
                                    from: trip['from'] ?? "~",
                                    to: trip['to'] ?? "~",
                                    departureTime: trip['depart'] ?? "~",
                                    arrivalTime: trip['arrive'] ?? "~",
                                    distance:
                                    trip['distance']?.toString() ?? "~",
                                    expense: trip['travel_cost']
                                        ?.toString() ??
                                        "~",
                                    riding: trip['to'] == "~",
                                    assetImage: trip['vehicle'] ==
                                        "2-Wheeler"
                                        ? "Assets/bg_icon.png"
                                        : "Assets/bg_icon2.png",
                                    startLat: trip["start"]['latitude'],
                                    startLng: trip['start']['longitude'],
                                    endLat: trip['end']['latitude'],
                                    endLng: trip['end']['longitude'],
                                    routeData: trip['route'],
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
