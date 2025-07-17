import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Utils/CommonFunctions.dart';
import '../Utils/StorageKeys.dart';
import '../Utils/StorageService.dart';

class LoginViewModel extends ChangeNotifier{

  final _formkey = GlobalKey<FormState>();

  GlobalKey<FormState> get formkey => _formkey;

  TextEditingController loginUsername = TextEditingController();
  TextEditingController loginPassword = TextEditingController();
  TextEditingController resetPasswordEmail = TextEditingController();

  bool isLoading = false;
  String errorMessage ='';

  String? EmailValidation(String? email) {
    if (email == null || email.isEmpty) {
      return "Email cannot be empty";
    }
    RegExp emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    // Check if the email matches the regex
    final isEmailValid = emailRegex.hasMatch(email ?? "");

    if (isEmailValid) {
      return null; // Valid email, return null (no error message)
    } else {
      return "Please enter a valid email address.";
    }
  }

  String? PasswordValidation(String? password) {
    if (password == null || password.isEmpty) {
      return "Password cannot be empty";
    }
    if (password.length <= 5) {
      return "Password too short";
    }
    return null;
  }

  Future<void> _saveUserToken(String token) async {
    await StorageService.instance.saveString(StorageKeys.userUid, token);
  }

  Future<bool> doesUserExist(String email,String dynamicCollection) async {
    try {

      final querySnapshot = await FirebaseFirestore.instance
          .collection(dynamicCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      print("🔥 Firestore error: ${e.message}");
      return false;
    } catch (e) {
      print("⚠️ Unexpected error: $e");
      return false;
    }
  }

  Future<Map<String, bool>> isUserEnabled(String email,String collectionName) async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection(collectionName).get();

      // Check for a matching email in the fetched documents
      for (var doc in querySnapshot.docs) {
        final userEmail = (doc['email'] as String).trim().toLowerCase();
        if (userEmail == email) {
          bool isDisabled = doc['isDisabled'] ?? false;
          // bool isVerified = doc['isApproved'] ?? false;

          return {
            "isDisabled": isDisabled,
            // "isVerified": isVerified, // Always true
          };
        }
      }
      // If no matching email is found, return false values
      return {
        "isDisabled": false,
        // "isVerified": false,
      };
    } catch (e) {
      print("Error checking if user is enabled: $e");
      return {
        "isDisabled": false,
        // "isVerified": false,
      };
    }
  }

  void UserLogin(context) async {
    String normalizedEmail = loginUsername.text.trim().toLowerCase();
    // Show loading dialog

    List<String> emailParts = normalizedEmail.split('@');
    if (emailParts.length != 2) {
      print("❌ Invalid email format.");
      return;
    }
    String domain = emailParts[1];

    var result = CommonFunctions().getDomainCollection(domain);
    String dynamicCollection = result["primary"] ?? "";
    String dynamicTeamsCollection = result["secondary"] ?? "";
    String dynamicLeaveCollection = result["tertiary"] ?? "";
    print("dynamicLeaveCollection $dynamicLeaveCollection");

    isLoading = true;
    notifyListeners();

    try {
      // Check if the user exists
      bool userExists = await doesUserExist(normalizedEmail, dynamicCollection);
      if (!userExists) {
          errorMessage = "User does not exist. Please register or try again.";
          isLoading = false;
          notifyListeners();
        // Navigator.pop(context); // Dismiss the loading dialog
        return;
      }

      var result = await isUserEnabled(normalizedEmail, dynamicCollection);

      bool isDisabled = result["isDisabled"] ?? false;
      // bool isVerified = result["isVerified"] ?? false;

      if (isDisabled) {
          errorMessage = "Your account is disabled. Please contact support.";
          isLoading = false;
        notifyListeners();

        // Navigator.pop(context); // Dismiss the loading dialog
        return;
      }

      // if (!isVerified) {
      //   setState(() {
      //     errorMessage =
      //     "Your account is under verification. Please contact support.";
      //   });
      //   Navigator.pop(context); // Dismiss the loading dialog
      //   return;
      // }

      // Perform the login with normalized email and password

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: normalizedEmail,
        password: loginPassword.text,
      );

      // Get the user's unique ID (uid)
      String uid = userCredential.user?.uid ?? '';

      _saveUserToken(uid);
      await StorageService.instance.saveCollectionName(dynamicCollection);
      await StorageService.instance.saveTeamsCollectionName(
        dynamicTeamsCollection,
      );
      await StorageService.instance.saveLeaveCollectionName(
        dynamicLeaveCollection,
      );
      // Handle successful login

        errorMessage = ""; // Clear any previous errors on successful login
        notifyListeners();
      // Navigator.pop(context); // Dismiss the loading dialog

      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
    } catch (error) {
      // If login fails, show an error message
        errorMessage = "Login failed: Invalid username or password.";
        isLoading = false;
      notifyListeners();
      // Navigator.pop(context); // Dismiss the loading dialog
    } finally {
      isLoading = false;
      loginUsername.clear();
      loginPassword.clear();
      notifyListeners();
    }
  }

}