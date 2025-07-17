import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_tracker_app/Models/TriplogModel.dart';
import 'package:trip_tracker_app/Models/UserModel.dart';
import 'package:trip_tracker_app/Utils/CommonFunctions.dart';
import 'package:uuid/uuid.dart';

import '../Utils/StorageService.dart';

class HomeViewModel extends ChangeNotifier{
  UserModel? _user;
  bool _isLoading = false;
  bool _isSquareButtonEnabled = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSquareButtonEnabled => _isSquareButtonEnabled;

  //Start trip variables
  String? selectedVehicle;
  String? selectedLocation;
  TextEditingController OtherLocation = TextEditingController();
  bool isStartTripLoading = false;
  bool isStartLocationChecked = false;

  //End trip variables
  TextEditingController DescriptionText = TextEditingController();
  TextEditingController DestinationLocation = TextEditingController();
  bool isEndTripLoading = false;
  bool get isEndTripContentFilled => DescriptionText.text.isNotEmpty && DestinationLocation.text.isNotEmpty;

  //Delete trip variables
  bool isDeletingTriplog = false;


  List<TriplogModel> get todaysTriplogs {
    String todayKey = DateFormat('dd-MM-yyyy').format(DateTime.now());
    return _user?.triplogs[todayKey] ?? [];
  }

  bool get isTripStarted => _user?.isTripStarted ?? false;

  double get totalDistance => todaysTriplogs.fold(0.0, (sum, trip) => sum + double.parse(trip.distance));
  double get totalExpenditure => todaysTriplogs.fold(0.0, (sum, trip) => sum + double.parse(trip.travelCost));

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    final rawData = await CommonFunctions().getLoggedInUserInfo();
    _user = UserModel.fromMap(rawData);
    _isSquareButtonEnabled = _user?.isTripStarted ?? false;

    print("${rawData}");

    _isLoading = false;
    notifyListeners();
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

  Future<void> signOut(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    StorageService.instance.clearAll();
    Navigator.pushNamed(context, '/login');
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
      if (permission == LocationPermission.whileInUse) {
        permission = await Geolocator.requestPermission();
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

      await FlutterBackgroundService().startService();
      print("✅ Background service start requested");
      final isRunning = await FlutterBackgroundService().isRunning();
      print("📡 Background service running? $isRunning");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('trip_id', tripId);
      await prefs.setString('uid', uid!);
      await prefs.setString('collection', collectionName!);

      // ✅ Start foreground tracking too
      CommonFunctions().trackLocationAndUpdateFirebase(
        tripId,
        userDocRef,
        date,
      );
    } catch (e) {
      print("An Error Occurred: $e");
    }
  }

  Future<void> verifyStartLocation(String? location) async {
    isStartTripLoading = true;
    notifyListeners();

    selectedLocation = location;

    if(location == "Other"){
      isStartLocationChecked = true;
    } else {
      Map<String, LatLng> locationCoordinates = {
        "Home": LatLng(12.9715987, 77.594566),
        "Kibbcom Office": LatLng(12.955343, 77.714901),
      };

      LatLng? target = locationCoordinates[location];
      if(target == null) return;

      final status = await Permission.location.request();
      if(status.isDenied){
        await Permission.location.request();
      }

      if(status.isGranted){
        Position currentLocation = await Geolocator.getCurrentPosition();
        double distance = Geolocator.distanceBetween(
            currentLocation.latitude,
            currentLocation.longitude,
            target.latitude,
            target.longitude
        );

        isStartLocationChecked = distance < 80;
      }
    }

    isStartTripLoading = false;
    notifyListeners();
  }

  Future<void> handleStartTrip(BuildContext context)async{
    isStartTripLoading = true;
    notifyListeners();

    try{
      await startTrip();
      Navigator.of(context).pop();
    } catch (e) {
      print("There was a problem starting your trip ($e)");
    } finally {
      isStartTripLoading = false;
      loadUserData();
      notifyListeners();
    }
  }

  Future<void> stopTrip() async {
    // await positionStream?.cancel();
    await CommonFunctions.positionStream?.cancel();
    print("Stream Stopped!");
    CommonFunctions.positionStream = null;

    FlutterBackgroundService().invoke("stopService");
    await Future.delayed(Duration(seconds: 1));

    print("Tracking stopped");
  }

  void listenToEndTripContentFields(){
    DestinationLocation.addListener(notifyListeners);
    DescriptionText.addListener(notifyListeners);
  }

  Future<void> endTrip(BuildContext context) async {

    try {

      isEndTripLoading = true;
      notifyListeners();

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
      List<dynamic> rawRoute = tripsForToday[indexToUpdate]['route'] ?? [];
      List<LatLng> routeList =
      rawRoute
          .map(
            (e) =>
            LatLng(e['latitude'] as double, e['longitude'] as double),
      )
          .toList();
      print('Route List: $routeList');

      print("LAT AND LONGS REQ ::: $startlatitude, $startlongitude");

      await stopTrip();
      print(
        "✅ Background & foreground tracking stopped, proceeding with end trip logic...",
      );

      double totalDistance = 0.0;

      for (int i = 0; i < routeList.length - 1; i++) {
        totalDistance += Geolocator.distanceBetween(
          routeList[i].latitude,
          routeList[i].longitude,
          routeList[i + 1].latitude,
          routeList[i + 1].longitude,
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
        'is_trip_started' : false,
      }, SetOptions(merge: true));

      // routeCoordinates.clear();
      print("route Co-ordinates updated and cleared.");
      print("Trip ended and Firebase updated successfully.");
    } catch (e) {
      print("An error occurred: $e");
    } finally {
      isEndTripLoading = false;
      loadUserData();
      notifyListeners();
      Navigator.pop(context);
    }
  }

  Future<void> deleteTripLog(int index, BuildContext context) async {
    isDeletingTriplog = true;
    notifyListeners();

    try{
      String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      await CommonFunctions().deleteTripLog(index, today);
      loadUserData();
    }catch(e){
      print("Error Deleting Trip ($e)");
    } finally {
      isDeletingTriplog = false;
      notifyListeners();
      Navigator.pop(context);
    }
  }

}