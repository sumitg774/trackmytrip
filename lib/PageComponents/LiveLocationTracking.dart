import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../Utils/StorageService.dart';

class OngoingTripMapScreen extends StatefulWidget {
  const OngoingTripMapScreen({super.key});

  @override
  State<OngoingTripMapScreen> createState() => _OngoingTripMapScreenState();
}

class _OngoingTripMapScreenState extends State<OngoingTripMapScreen> {
  String? collectionName;
  String? uid;
  String? vehicle;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCollectionName();
  }

  void getCollectionName() async
  {
    uid = FirebaseAuth.instance.currentUser!.uid;
    collectionName = await StorageService.instance.getCollectionName();
    setState(() {

    });
    print(collectionName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        scrolledUnderElevation: 0,
        backgroundColor: CupertinoColors.white,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: const Text(
            "Live Tracking",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: collectionName == null ? Center(
        child: CircularProgressIndicator(
          color: CupertinoColors.activeBlue,
          backgroundColor: Colors.lightBlueAccent,
        ),
      ) :
        StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection(collectionName!).doc(uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final docSnapshot = snapshot.data!;
            final rawData = docSnapshot.data();

            if (rawData == null) {
              return const Center(child: Text("No user data found."));
            }

            final data = rawData as Map<String, dynamic>;

            final todayKey = DateFormat('dd-MM-yyyy').format(DateTime.now());

            if (data['triplogs'] == null || data['triplogs'][todayKey] == null) {
              return const Center(child: Text("No trip data available for today."));
            }

            final List<dynamic> todayTrips = data['triplogs'][todayKey];
            if (todayTrips.isEmpty || todayTrips.last['route'] == null) {
              return const Center(child: Text("No route data available for today's trip."));
            }

            final List<dynamic> route = todayTrips.last['route'];
            vehicle = todayTrips.last['vehicle'];
            final polylinePoints = route.map<LatLng>((point) {
              return LatLng(point['latitude'], point['longitude']);
            }).toList();

            final currentLocation = polylinePoints.isNotEmpty ? polylinePoints.last : null;
            final initialCenter = polylinePoints.isNotEmpty
                ? polylinePoints.first
                : const LatLng(0, 0); // fallback

            return FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation ?? initialCenter,
                initialZoom: 17,
              ),
              children: [
                TileLayer(
                  /*urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],*/

                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: ['a', 'b', 'c', 'd'],
                ),
                if (currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation,
                        width: 40,
                        height: 40,
                        child: vehicle == "2-Wheeler" ? Image.asset('Assets/bike_top_view.png',): Image.asset('Assets/car_top_view.png',),
                      ),
                    ],
                  ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      color: Colors.blueAccent,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              ],
            );
          }
      ),
    );
  }
}
