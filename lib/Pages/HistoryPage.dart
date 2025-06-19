import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
