import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class CommonFunctions{
  Map<String, String> getDomainCollection(String emailDomain) {
    return {
      "primary": "${emailDomain}_user",
      "secondary": "${emailDomain}_teams",
      "tertiary": "${emailDomain}_generalLeave"
    };
  }

  Future<bool> doesDomainExist(String domain) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
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


  static void showSnackBar(String message,
      {Color backgroundColor = Colors.black}) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 2),
    );

    // MyApp.messengerKey.currentState?.showSnackBar(snackBar);
  }
}