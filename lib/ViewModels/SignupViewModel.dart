import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../Utils/CommonFunctions.dart';
import '../Utils/StorageService.dart';


class SignupViewModel extends ChangeNotifier{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  GlobalKey<FormState> get formKey => _formKey;

  // Controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController empId = TextEditingController();

  bool isSubmitting = false;
  late bool isDisabled = false;
  String errorMessage = '';

  String? SignupEmailValidation(String? email) {
    // Updated Regex for stricter validation
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

  String? validatePhone(String? mobile) {
    RegExp phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (mobile == null || mobile.isEmpty || mobile.length != 10) {
      return 'Phone number should be 10 digits';
    } else if (!phoneRegex.hasMatch(mobile)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != password.text) {
      return 'Password and Confirm password should match';
    }
    return null;
  }

  Future<void> addUserToFirestore(String uid) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      String emailText = email.text.trim();

      if (!emailText.contains('@')) {
        print("Invalid email: '@' missing");
        return;
      }

      List<String> emailParts = emailText.split('@');
      if (emailParts.length != 2) {
        print("Invalid email format");
        return;
      }

      String emailDomain = emailParts[1];
      var result = CommonFunctions().getDomainCollection(emailDomain);

      String dynamicCollection = result["primary"] ?? "";
      String dynamicTeamsCollection = result["secondary"] ?? "";
      String dynamicLeaveCollection = result["tertiary"] ?? "";

      // Save dynamic collection names
      await StorageService.instance.saveCollectionName(dynamicCollection);
      await StorageService.instance
          .saveTeamsCollectionName(dynamicTeamsCollection);
      await StorageService.instance
          .saveLeaveCollectionName(dynamicLeaveCollection);

      // 🟢 Create empty leaveDates doc if it doesn't exist
      DocumentReference leaveDocRef =
      firestore.collection(dynamicLeaveCollection).doc('leaveDates');
      DocumentSnapshot leaveDoc = await leaveDocRef.get();
      if (!leaveDoc.exists) {
        await leaveDocRef.set({'dates': []});
        print("📁 Created empty leaveDates doc in $dynamicLeaveCollection");
      }

      // 🔄 Fetch general leave dates
      List<String> generalLeaveDates = [];
      QuerySnapshot generalLeaveSnapshot =
      await firestore.collection(dynamicLeaveCollection).get();
      for (var doc in generalLeaveSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('dates')) {
          List<dynamic> datesArray = data['dates'];
          for (var item in datesArray) {
            if (item is Map<String, dynamic> && item.containsKey('date')) {
              generalLeaveDates.add(item['date']);
            }
          }
        }
      }

      // Convert to upcomingPlans
      // List<UpcomingPlan> upcomingPlans = generalLeaveDates.map((date) {
      //   return UpcomingPlan(
      //     date: date,
      //     status: 'General Leave',
      //     lastUpdatedDateTime: DateTime.now().toIso8601String(),
      //   );
      // }).toList();

      // Prepare userData
      Map<String, dynamic> userData = {
        'name': name.text.isNotEmpty ? name.text : "Unknown",
        'email': email.text.toLowerCase(),
        'emp_id': empId.text.isNotEmpty ? empId.text : "Unknown",
        'phone': mobile.text.isNotEmpty ? mobile.text : "Unknown",
        // 'avtar': avtar,
        'emp_role': "Software Engineer",
        'is_trip_started':false,
        // 'fcm_token': fcm_token,
        // 'upcoming': upcomingPlans.map((e) => e.toMap()).toList(),
        'team': "Internal",
        'teams': ["Internal"],
        // 'joiningDate': DateFormat('MM/dd/yyyy').format(DateTime.now()),
        // 'dob': dateofbirth.text.isNotEmpty ? dateofbirth.text : "Unknown",
        'isDisabled': isDisabled,
        // 'isApproved': false,
      };

      // 🔍 Confirm domain registered
      QuerySnapshot domainQuery = await firestore
          .collection("domain")
          .where("domain_name", isEqualTo: emailDomain)
          .get();

      if (domainQuery.docs.isEmpty) {
        print("Domain does not exist ❌");
        return;
      }

      // 📝 Add user
      await firestore.collection(dynamicCollection).doc(uid).set(userData);
      print("✅ User added to $dynamicCollection");

      // 👥 Ensure teams collection exists
      QuerySnapshot teamQuery =
      await firestore.collection(dynamicTeamsCollection).get();
      if (teamQuery.docs.isEmpty) {
        await firestore.collection(dynamicTeamsCollection).add({
          'team_name': ["Internal", "External"],
          'role_name': ["Team Lead", "Software Engineer", "Director"],
          'Task': ["Development"],
        });
        print("📂 Teams collection created");
      } else {
        print("👥 Teams collection already exists");
      }

      // ✅ Success feedback
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Sign up successfully')),
      // );
    } catch (e) {
      print("❌ Error while adding user: $e");
    }
  }

  Future<String?> signupWithEmail() async {

    try{
      // Firebase Auth signup
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      String uid = userCredential.user!.uid;

      // Add user to Firestore
      await addUserToFirestore(uid);

      return null;

    }on FirebaseAuthException catch (e) {// dismiss progress dialog if error

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered. Please log in.';
        notifyListeners();
      } else {
        errorMessage = 'Something went wrong. Please try again.';
        notifyListeners();

      }
      return errorMessage;
    } catch (e) {
      print("Unexpected error: $e");
      errorMessage = "An Unexpected error occurred.";
      notifyListeners();
      return 'An unexpected error occurred.';
    }

  }


}