import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:trip_tracker_app/Components/AlertDialogs.dart';
import 'package:trip_tracker_app/Components/Cards.dart';
import 'package:trip_tracker_app/Components/Containers.dart';
import '../Components/Buttons.dart';
import '../Components/TextFields.dart';
import '../Utils/AppColorTheme.dart';
import '../Utils/CommonFunctions.dart';

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
  String? selectedDate1;
  List<String> customSelectedDates=[];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  List<String> getLastFiveDates() {
    return List.generate(5, (i) {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.now().subtract(Duration(days: i)));
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
              title: "Select the date",
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
                          trialingIcon: Icon(Icons.calendar_today, color: AppColors.customBlue),
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
                          trialingIcon: Icon(Icons.calendar_today, color: AppColors.customBlue),
                          customBool: true,
                        ),
                        SizedBox(height: 30),
                        DatePickerTextField(
                          controller: toDate,
                          label: "To",
                          prefillToday: false,
                          trialingIcon: Icon(Icons.calendar_today, color: AppColors.customBlue),
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

  @override
  Widget build(BuildContext context) {
    List<String> datesToShow = customSelectedDates.isNotEmpty
        ? customSelectedDates
        : List.generate(5, (i) {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.now().subtract(Duration(days: i)));
    });

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
                onPressed: OpenSetDateDialog,
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.black87,
                ),
              )
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(
        color: CupertinoColors.activeBlue,
        backgroundColor: Colors.lightBlueAccent,
      ))
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
          
              if (dayTrips.isEmpty) return const SizedBox();
          
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
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dayTrips.length,
                          itemBuilder: (context, tripIndex) {
                            final trip =
                            Map<String, dynamic>.from(dayTrips[tripIndex]);
          
                            return TripSummaryCard(
                              from: trip['from'] ?? "~",
                              to: trip['to'] ?? "~",
                              departureTime: trip['depart'] ?? "~",
                              arrivalTime: trip['arrive'] ?? "~",
                              distance: trip['distance']?.toString() ?? "~",
                              expense: trip['travel_cost']?.toString() ?? "~",
                              riding: trip['to'] == "~",
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


