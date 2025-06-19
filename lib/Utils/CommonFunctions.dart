import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../main.dart';
import 'StorageService.dart';

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

  Future<Map<String, dynamic>> getLoggedInUserInfo() async {
    Map<String, dynamic> UserData = {};
    String? collectionName = await StorageService.instance.getCollectionName();
    print("CO: $collectionName");

    String? uid = FirebaseAuth.instance.currentUser?.uid;
    print("U $uid");

    DocumentSnapshot doc = await FirebaseFirestore.instance
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

}