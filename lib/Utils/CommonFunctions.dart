import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../Components/AlertDialogs.dart';
import '../main.dart';
import 'StorageService.dart';

class CommonFunctions {
  Map<String, String> getDomainCollection(String emailDomain) {
    return {
      "primary": "${emailDomain}_user",
      "secondary": "${emailDomain}_teams",
      "tertiary": "${emailDomain}_generalLeave",
    };
  }

  Future<bool> doesDomainExist(String domain) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('domain')
              .where('domain_name', isEqualTo: domain)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty; // Return true if domain exists
    } catch (e) {
      print("Error checking domain existence: $e");
      return false; // Assume it doesn't exist in case of an error
    }
  }

  static void showSnackBar(
    String message, {
    Color backgroundColor = Colors.black,
  }) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 2),
    );

    // MyApp.messengerKey.currentState?.showSnackBar(snackBar);
  }

  Future<Map<String, dynamic>> getLoggedInUserInfo() async {
    Map<String, dynamic> UserData = {};
    String? collectionName = await StorageService.instance.getCollectionName();
    print("CO: $collectionName");

    String? uid = FirebaseAuth.instance.currentUser?.uid;
    print("U $uid");

    DocumentSnapshot doc =
        await FirebaseFirestore.instance
            .collection(collectionName!)
            .doc(uid)
            .get();

    if (doc.exists) {
      UserData = doc.data() as Map<String, dynamic>;
      print("$UserData :::::::");
      return UserData;
    } else {
      throw Exception("Couldn't get data");
    }
  }

  static StreamSubscription<Position>? positionStream;
  List<LatLng> routeCoordinates = [];

  void trackLocationAndUpdateFirebase(
    String tripId,
    DocumentReference userDocRef,
    String date,
  ) {
    print("Foreground Tracking STARTED");
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 7,
      ),
    ).listen((Position pos) async {
      print("Returning due to low gps accuracy!");
      if (pos.accuracy > 20) return;

      LatLng current = LatLng(pos.latitude, pos.longitude);

      if (routeCoordinates.isNotEmpty) {
        final last = routeCoordinates.last;
        double distance = Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          current.latitude,
          current.longitude,
        );

        print("Returning due to distance less than 5mtr from last co ord!");
        if (distance < 5) return;
      }

      routeCoordinates.add(current);

      final List<Map<String, dynamic>> routeList =
          routeCoordinates
              .map(
                (coord) => {
                  'latitude': coord.latitude,
                  'longitude': coord.longitude,
                },
              )
              .toList();

      DocumentSnapshot snapshot = await userDocRef.get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> todaysTrips = List.from(data['triplogs'][date] ?? []);

      for (int i = 0; i < todaysTrips.length; i++) {
        if (todaysTrips[i]['tripId'] == tripId) {
          todaysTrips[i]['route'] = routeList;
          break;
        }
      }

      await userDocRef.update({'triplogs.$date': todaysTrips});
      print("Route updated: ${current.latitude}, ${current.longitude}");
    });
  }

  deleteTripLog(int index, String date) async {
    try {
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

      final snapshot = await userDocRef.get();
      if (!snapshot.exists) {
        print("User document does not exist.");
        return;
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> triplogs = Map<String, dynamic>.from(
        data['triplogs'] ?? {},
      );
      List<dynamic> todaysTrips = List.from(triplogs[date] ?? []);

      if (index < 0 || index >= todaysTrips.length) {
        print("Invalid index: $index");
        return;
      }

      // Remove the trip at the given index
      todaysTrips.removeAt(index);

      // Update the document
      await userDocRef.update({'triplogs.$date': todaysTrips});

      print("Trip at index $index deleted for $date.");
    } catch (e) {
      print("Error deleting trip: $e");
    }
  }
}
