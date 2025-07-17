import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:latlong2/latlong.dart';

class TripSummaryCard extends StatelessWidget {
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String distance;
  final String expense;
  final bool riding;
  final String assetImage;
  final SlidableActionCallback onSlideFunction;

  const TripSummaryCard({
    super.key,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.distance,
    required this.expense,
    required this.riding,
    required this.assetImage,
    required this.onSlideFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border(
          bottom: BorderSide(
            color: riding ? CupertinoColors.activeOrange : Colors.white,
            width: 1.5,
          ),
        ),
        color: CupertinoColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Slidable(
        endActionPane:  ActionPane(
            motion: BehindMotion(),
            extentRatio: 0.35,
            children: [
              SlidableAction(
                onPressed: onSlideFunction,
                backgroundColor: CupertinoColors.destructiveRed,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                icon: Icons.delete_forever_rounded,
              ),

            ]
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              bottom: BorderSide(
                color: riding ? CupertinoColors.activeOrange : Colors.white,
                width: 1.5,
              ),
            ),
            color: CupertinoColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                offset: const Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      assetImage,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: 120,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// From ➝ To
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              from,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(
                            !riding
                                ? Icons.arrow_forward
                                : Icons.more_horiz_rounded,
                            size: 20,
                            color: !riding ? Colors.green : CupertinoColors.activeOrange,
                          ),
                          Expanded(
                            child: Text(
                              to,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      /// Time Range
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Depart: $departureTime',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Arrive: $arrivalTime',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.navigation_rounded, size: 18, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                "$distance km",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.currency_rupee, size: 18, color: Colors.green),
                              const SizedBox(width: 2),
                              Text(
                                expense,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class ExpandableTripSummaryCard extends StatelessWidget {
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String distance;
  final String expense;
  final bool riding;
  final String assetImage;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final List<dynamic> routeData;
  final SlidableActionCallback onSlideFunction;

  ExpandableTripSummaryCard({
    super.key,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.distance,
    required this.expense,
    required this.riding,
    required this.assetImage,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.routeData,
    required this.onSlideFunction
  });

  @override
  Widget build(BuildContext context) {

    List<LatLng> polylinePoints = routeData.map((point) {
        return LatLng(point['latitude'], point['longitude']);
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border(
          bottom: BorderSide(
            color: riding ? CupertinoColors.activeOrange : Colors.white,
            width: 1.5,
          ),
        ),
        color: CupertinoColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Slidable(
        endActionPane:  ActionPane(
            motion: BehindMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: onSlideFunction,
                backgroundColor: CupertinoColors.destructiveRed,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                icon: Icons.delete_forever_rounded,
              ),

            ]
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              bottom: BorderSide(
                color: riding ? CupertinoColors.activeOrange : Colors.white,
                width: 1.5,
              ),
            ),
            color: CupertinoColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                offset: const Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background image
                Positioned(
                  right: -15,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      assetImage,
                      fit: BoxFit.cover,
                      height: 120,
                      width: 120,
                    ),
                  ),
                ),
                // Content
                ExpansionTile(
                  backgroundColor: CupertinoColors.white,
                  showTrailingIcon: false,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12,), shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero,),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          from,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(
                        !riding ? Icons.arrow_forward : Icons.more_horiz_rounded,
                        size: 20,
                        color: !riding ? Colors.green : CupertinoColors.activeOrange,
                      ),
                      Expanded(
                        child: Text(
                          to,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.navigation_rounded, size: 18, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              "$distance km",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.currency_rupee, size: 18, color: Colors.green),
                            const SizedBox(width: 2),
                            Text(
                              expense,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Depart: $departureTime',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Arrive: $arrivalTime',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 200,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(startLat, startLng),
                                initialZoom: 15,
                              ),
                              children: [
                                TileLayer(
/*
                                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
*/
                                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                  subdomains: ['a', 'b', 'c', 'd'],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(startLat, startLng),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.location_on, color: CupertinoColors.systemGreen),
                                    ),
                                    Marker(
                                      point: LatLng(endLat, endLng),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.flag, color: CupertinoColors.systemRed),
                                    ),
                                  ],
                                ),
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: polylinePoints,
                                      color: CupertinoColors.activeBlue,
                                      strokeWidth: 3.2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

