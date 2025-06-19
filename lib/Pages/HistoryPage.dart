import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:trip_tracker_app/Components/Cards.dart';
import 'package:trip_tracker_app/Components/Containers.dart';
import '../Utils/CommonFunctions.dart';
import 'dart:math';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Map<String, dynamic>? userData;
  Map<String, dynamic> triplogs = {};
  bool isLoading = true;
  String? selectedDate;
  String API_KEY = "5b3ce3597851110001cf62480796a08341e447719309540c7e083620";


  @override
  void initState() {
    super.initState();
    getUserData();
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('dd-MM-yyyy').format(picked);
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
    List<String> datesToShow =
        selectedDate != null
            ? [selectedDate!]
            : List.generate(5, (i) {
              return DateFormat(
                'dd-MM-yyyy',
              ).format(DateTime.now().subtract(Duration(days: i)));
            });
    print(" DATES TO SHOW ::: $datesToShow");

    return Scaffold(
      backgroundColor: CupertinoColors.white,
      // floatingActionButton: FloatingActionButton(onPressed: (){getRouteDistanceFromORS(
      //   startLat: 49.41461,
      //   startLng: 8.681495,
      //   endLat: 49.020318,
      //   endLng: 8.687872,
      // );}),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: CupertinoColors.white,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: _selectDate,
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.black87,
                ),
              ),
            ],
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
                                        print("jnnjnnjnjn $trip");

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
                ),
              ),
    );
  }
}
