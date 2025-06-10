import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleContainer extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Widget child;

  const SimpleContainer({
    super.key,
    required this.title,
    this.backgroundColor = const Color(0xFF2979FF),
    required this.child,
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
          colors: [
            CupertinoColors.systemGrey6,
            CupertinoColors.white,
          ],
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
            colors: [
              CupertinoColors.systemGrey5,
              CupertinoColors.white,
            ],

          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // dynamic height based on content
          children: [
            Text(
              title,
              style: TextStyle(
                color: CupertinoColors.systemBlue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 5),
            child,
          ],
        ),
      ),
    );
  }
}





