import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TripSummaryCard extends StatelessWidget {
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String distance;
  final String expense;
  final bool riding;
  final String assetImage;

  const TripSummaryCard({
    super.key,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.distance,
    required this.expense,
    required this.riding,
    required this.assetImage
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
                            distance,
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
    );
  }

}
