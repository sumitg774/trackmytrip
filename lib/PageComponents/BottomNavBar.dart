import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_tracker_app/Pages/HistoryPage.dart';
import 'package:trip_tracker_app/Pages/home_page.dart';

import '../Pages/MyHomePage.dart';
import '../ViewModels/HomeViewModel.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  int selectedIndex = 0;

  void navigateBottomBar(int index){
    setState(() {
      selectedIndex = index;
    });
  }

  final List<Widget> pages = [
    MyHomePage(),
    HistoryPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: CupertinoColors.activeBlue,
        unselectedItemColor: CupertinoColors.systemGrey,
        currentIndex: selectedIndex,
        onTap: navigateBottomBar,
        backgroundColor: CupertinoColors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_motorsports_rounded),
            label: "History",
          ),
        ],
      ),
    );
  }
}
