import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:trip_tracker_app/Models/TriplogModel.dart';
import 'package:trip_tracker_app/Utils/CommonFunctions.dart';

import '../Models/UserModel.dart';

class HistoryViewModel extends ChangeNotifier{
  UserModel? _user;

  UserModel? get user => _user;

  bool isLoading = false;

  final TextEditingController singleDate = TextEditingController();
  final TextEditingController toDate = TextEditingController();
  final TextEditingController fromDate = TextEditingController();


  bool isSingleDateMode = true;
  List<String> customSelectedDates = [];
  String selectedDate = "";
  bool showSummary = false;

  double _totalExpenditure = 0.0;
  double _totalDistance = 0.0;

  double get totalExpenditure => _totalExpenditure;
  double get totalDistance => _totalDistance;
  String? selectedVehicleFilter;

  bool isDeletingTriplog= false;

  Future<void> getUserData() async {
    isLoading = true;
    notifyListeners();

    final rawData = await CommonFunctions().getLoggedInUserInfo();
    _user = UserModel.fromMap(rawData);
    calculateTotalDistanceAndExpenditure();

    customSelectedDates = [];
    notifyListeners();

    isLoading = false;
    notifyListeners();
  }

  void toggleDateMode(bool singleMode) {
    isSingleDateMode = singleMode;

    if (isSingleDateMode) {
      fromDate.clear();
      toDate.clear();
    } else {
      singleDate.clear();
    }
    notifyListeners();
  }

  List<String> getSelectedDates() {
    if (isSingleDateMode && singleDate.text.isNotEmpty) {
      final picked = DateFormat('dd-MM-yyyy').parseStrict(singleDate.text);
      return [DateFormat('dd-MM-yyyy').format(picked)];
    } else if (fromDate.text.isNotEmpty && toDate.text.isNotEmpty) {
      final start = DateFormat('dd-MM-yyyy').parseStrict(fromDate.text);
      final end = DateFormat('dd-MM-yyyy').parseStrict(toDate.text);

      if (start.isAfter(end)) {
        throw Exception("Start date is after end date");
      }

      return List.generate(
        end.difference(start).inDays + 1,
            (i) => DateFormat('dd-MM-yyyy').format(start.add(Duration(days: i))),
      );
    } else {
      throw Exception("Invalid date selection");
    }
  }

  void updateSelectedDates(List<String> dates) {
    customSelectedDates = dates;
    selectedDate = dates.length == 1 ? dates.first : "${dates.first} to ${dates.last}";
    showSummary = true;
    notifyListeners();
  }

  void resetSelection() {
    singleDate.clear();
    fromDate.clear();
    toDate.clear();
    customSelectedDates.clear();
    selectedDate = '';
    showSummary = false;
    notifyListeners();
  }

  List<String> get datesToShow => customSelectedDates.isNotEmpty
      ? customSelectedDates
      : List.generate(5, (i) {
    return DateFormat('dd-MM-yyyy')
        .format(DateTime.now().subtract(Duration(days: i)));
  });

  bool get noLogsAvailable {
    final triplogs = Map<String, dynamic>.from(_user?.triplogs ?? {});
    return datesToShow.every((date) =>
    triplogs[date] == null || (triplogs[date] as List).isEmpty);
  }

  Map<DateTime, int> get dataForHeatMap {
    final Map<DateTime, int> result = {};
    final triplogs = Map<String, dynamic>.from(user?.triplogs ?? {});
    triplogs.forEach((dateStr, entries) {
      if (entries != null && entries.isNotEmpty) {
        final parts = dateStr.split('-');
        final date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        result[date] = 1;
      }
    });
    return result;
  }

  void calculateTotalDistanceAndExpenditure() {
    double totalExpenditure = 0.0;
    double totalDistance = 0.0;

    for (String date in datesToShow) {
      List<TriplogModel> originalTrips = _user?.triplogs[date] ?? [];

      List<TriplogModel> dayTrips = selectedVehicleFilter == null
          ? originalTrips
          : originalTrips
          .where((trip) => trip.vehicle == selectedVehicleFilter)
          .toList();

      for (var trip in dayTrips) {
        final expenditure = double.tryParse(trip.travelCost.toString());
        final distance = double.tryParse(trip.distance.toString());

        if (expenditure != null && distance != null) {
          totalExpenditure += expenditure;
          totalDistance += distance;
        }
      }
    }

    _totalExpenditure = totalExpenditure;
    _totalDistance = totalDistance;
    notifyListeners();

    print("TOTAL:EXP = $_totalExpenditure");
    print("TOTAL:DIST = $_totalDistance");
  }

  List<Map<String, dynamic>> getFlatTripList() {
    List<Map<String, dynamic>> allTrips = [];

    for (String date in datesToShow) {
      // List<dynamic> dayTrips = triplogs[date] ?? [];
      // List<dynamic> dayTrips = triplogs[date] ?? [];
      List<TriplogModel> originalTrips = _user?.triplogs[date] ?? [];
      List<TriplogModel> dayTrips = selectedVehicleFilter == null
          ? originalTrips
          : originalTrips.where((trip) => trip.vehicle == selectedVehicleFilter).toList();

      for (var tripRaw in dayTrips) {
        final trip = tripRaw.toMap();

        allTrips.add({
          'Date': date,
          'From': trip['from'] ?? '~',
          'To': trip['to'] ?? '~',
          'Departure': trip['depart'] ?? '~',
          'Arrival': trip['arrive'] ?? '~',
          'Distance (km)': double.parse(trip['distance']!.toString()) ?? '~',
          'Expenditure (₹)':
          double.parse(trip['travelCost']!.toString()) ?? '0.0',
          'Vehicle': trip['vehicle'] ?? '~',
        });
      }
    }
    return allTrips;
  }

  Future<void> deleteTripLog(int index, String date, BuildContext context) async {
    isDeletingTriplog = true;
    notifyListeners();

    try{
      await CommonFunctions().deleteTripLog(index, date);
      getUserData();
    }catch(e){
      print("Error Deleting Trip ($e)");
    } finally {
      isDeletingTriplog = false;
      notifyListeners();
      Navigator.pop(context);
    }
  }


}