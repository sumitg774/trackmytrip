import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'TextFields.dart';

class SimpleContainer extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Widget child;
  final bool wantTitle;

  const SimpleContainer({
    super.key,
    required this.title,
    this.backgroundColor = const Color(0xFF2979FF),
    required this.child,
    this.wantTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Outer container solid light grey (optional)
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CupertinoColors.systemGrey6, CupertinoColors.white],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // Gradient background from backgroundColor (top) to white (bottom)
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CupertinoColors.systemGrey5, CupertinoColors.white],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // dynamic height based on content
          children: [
            wantTitle
                ? Text(
                  title,
                  style: TextStyle(
                    color: CupertinoColors.systemBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                )
                : SizedBox(),
            const SizedBox(height: 5),
            child,
          ],
        ),
      ),
    );
  }
}

class QuickLocationContainer extends StatelessWidget {
  String locationName;
  double latitude;
  double longitude;
  void Function() onPressed;
  void Function() onPressed2;

  QuickLocationContainer({
    super.key,
    required this.locationName,
    this.onPressed = _emptyFunction,
    this.onPressed2 = _emptyFunction,
    this.latitude = 0,
    this.longitude = 0,
  });

  static void _emptyFunction() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$locationName co-ordinates",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: StyleText("Latitude", latitude.toString())),
                    SizedBox(width: 5),
                    Expanded(
                      child: StyleText("Longitude", longitude.toString()),
                    ),
                    SizedBox(width: 5),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: CupertinoColors.activeBlue,
                        ),
                        onPressed: onPressed,
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: CupertinoColors.destructiveRed,
                        ),
                        onPressed: onPressed2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 120,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude, longitude),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latitude, longitude),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: CupertinoColors.systemGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddQuickLocationContainer extends StatelessWidget {
  TextEditingController nameController;
  TextEditingController latController;
  TextEditingController longController;
  String name;
  double lat;
  double long;
  bool editing;

  AddQuickLocationContainer({
    super.key,
    required this.nameController,
    required this.latController,
    required this.longController,
    this.name = "E.g. Kibbcom",
    this.lat = 90,
    this.long = 90,
    this.editing = false
  });

  @override
  Widget build(BuildContext context) {
    if(editing){
      nameController.text = name;
      latController.text = lat.toString();
      longController.text = long.toString();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Location Name:",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: CupertinoColors.black,
          ),
        ),
        SizedBox(height: 8),
        CustomTextField2(hintText: name, controller: nameController),
        SizedBox(height: 12),
        Text(
          "Co-ordinates:",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: CupertinoColors.black,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField2(
                hintText: lat.toString(),
                controller: latController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: CustomTextField2(
                hintText: long.toString(),
                controller: longController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            SizedBox(width: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 1, color: Colors.grey.shade300),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.my_location,
                  color: CupertinoColors.activeBlue,
                ),
                onPressed: () async {
                  Position position = await Geolocator.getCurrentPosition();
                  latController.text = position.latitude.toString();
                  longController.text = position.longitude.toString();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget StyleText(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: CupertinoColors.systemGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(subtitle, style: TextStyle(fontSize: 14)),
    ],
  );
}


