import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trip_tracker_app/Components/AlertDialogs.dart';
import 'package:trip_tracker_app/Components/Buttons.dart';
import 'package:trip_tracker_app/Components/Cards.dart';
import 'package:trip_tracker_app/Components/Containers.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSquareButtonEnabled = true;

  void showStartTripAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleAlertDialog(
          title: "Start Trip",
          onPressed: () {
            setEnabledStatus(false);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void showEndTripAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleAlertDialog(
          title: "End trip",
          onPressed: () {
            setEnabledStatus(true);
            Navigator.pop(context);
          },
          endDialog: true,
        );
      },
    );
  }

  void setEnabledStatus(bool val) {
    setState(() {
      isSquareButtonEnabled = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: TransparentFab(expenditure: "200.0", kms: "20.0"),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22.0),
            child: Icon(
              Icons.logout_rounded,
              color: CupertinoColors.destructiveRed,
            ),
          ),
        ],
        flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double screenwidth = constraints.maxWidth;
            return Stack(
              children: [
                Positioned(
                  right: screenwidth * 0.855, // distance from the right edge
                  bottom: -5, // distance from the bottom edge
                  child: Icon(
                    Icons.circle,
                    size: 100,
                    color: Colors.blue.withOpacity(
                      0.2,
                    ), // for a subtle background effect
                  ),
                ),
              ],
            );
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good Morning!",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                "Neeraj N H",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: CupertinoColors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SquareIconButton(
                      onPressed: () {
                        showStartTripAlertDialog();
                      },
                      icon: Icons.play_arrow_rounded,
                      label: 'Start Trip',
                      isEnabled: isSquareButtonEnabled,
                      color: CupertinoColors.systemBlue,
                    ),
                    SquareIconButton(
                      onPressed: () {
                        showEndTripAlertDialog();
                      },
                      icon: Icons.stop_rounded,
                      label: 'End Trip',
                      isEnabled: !isSquareButtonEnabled,
                      color: CupertinoColors.systemRed,
                    ),
                  ],
                ),
                SizedBox(height: 50),
                SimpleContainer(
                  title: "Today's Trip Logs",
                  child: Column(
                    children: [
                      TripSummaryCard(
                        from: "Kibbcom",
                        to: "Client A",
                        departureTime: "9:00",
                        arrivalTime: "12:00",
                        distance: "20 kms",
                        expense: "200",
                        riding: false,
                      ),
                      TripSummaryCard(
                        from: "Client A",
                        to: "~",
                        departureTime: "12:30",
                        arrivalTime: "~",
                        distance: "~ kms",
                        expense: "~",
                        riding: true,
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
