import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'StorageService.dart';

@pragma('vm:entry-point')
Future<void> BackgroundService(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();

  print("🔁 BackgroundService has started");

  service.invoke('setAsForeground');

  late final StreamSubscription<Position> backgroundStream;

  service.on('stopService').listen((event) async {
    print("⛔ Stopping background service...");
    await backgroundStream.cancel();
    service.stopSelf();
  });


  final prefs = await SharedPreferences.getInstance();
  final tripId = prefs.getString('trip_id');
  final uid = prefs.getString('uid');
  final collectionName = prefs.getString('collection');
  final date = DateFormat('dd-MM-yyyy').format(DateTime.now());

  if (tripId == null || uid == null || collectionName == null) {
    print("❌ Missing tripId, uid or collection name");
    return;
  }

  final userDocRef = FirebaseFirestore.instance.collection(collectionName).doc(uid);

  backgroundStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 7,
    ),
  ).listen((Position pos) async {
    try {
      final lat = pos.latitude;
      final lng = pos.longitude;
      print("📍 Background location: $lat, $lng");

      DocumentSnapshot snapshot = await userDocRef.get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> todaysTrips = List.from(data['triplogs'][date] ?? []);

      for (int i = 0; i < todaysTrips.length; i++) {
        if (todaysTrips[i]['tripId'] == tripId) {
          List<dynamic> currentRoute = List.from(todaysTrips[i]['route'] ?? []);
          currentRoute.add({'latitude': lat, 'longitude': lng});
          todaysTrips[i]['route'] = currentRoute;
          break;
        }
      }

      await userDocRef.update({'triplogs.$date': todaysTrips});
      print("✅ Route updated in background: $lat, $lng");
    } catch (e) {
      print("❌ Error updating background location: $e");
    }
  });
}


