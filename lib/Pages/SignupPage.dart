import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Components/TextFields.dart';
import '../Utils/AppColorTheme.dart';
import '../Utils/CommonFunctions.dart';
import '../Utils/StorageService.dart';
import 'LoginPage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController empId = TextEditingController();
  bool isSubmitting = false;

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

  // Phone number validation
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
        // 'fcm_token': fcm_token,
        // 'upcoming': upcomingPlans.map((e) => e.toMap()).toList(),
        'team': "Internal",
        'teams': ["Internal"],
        // 'joiningDate': DateFormat('MM/dd/yyyy').format(DateTime.now()),
        // 'dob': dateofbirth.text.isNotEmpty ? dateofbirth.text : "Unknown",
        // 'isDisabled': isDisabled,
        'isApproved': false,
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
      //   SnackBar(content: Text('Sign up success - wait for admin approval')),
      // );
    } catch (e) {
      print("❌ Error while adding user: $e");
    }
  }

  Future<bool> signUpWithEmail() async {
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss on tap outside
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.lightBlue,
          ),
        );
      },
    );

    try {
      // Firebase Auth signup
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      String uid = userCredential.user!.uid;

      // Add user to Firestore
      await addUserToFirestore(uid);

      // Remove the progress dialog
      Navigator.pop(context); // this removes the loading indicator

      // Show success and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Signed up successfully, please wait for admin's approval",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          showCloseIcon: true,
          backgroundColor: Colors.green,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          // Optional: adds spacing around
        ),
      );

      Navigator.pushNamed(context, "/login");
      return true;
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // dismiss progress dialog if error

      String errorMessage = '';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered. Please log in.';
      } else {
        errorMessage = 'Something went wrong. Please try again.';
      }

      CommonFunctions.showSnackBar(errorMessage);
      return false;
    } catch (e) {
      Navigator.pop(context); // dismiss progress dialog if error
      print("Unexpected error: $e");
      CommonFunctions.showSnackBar("An unexpected error occurred.");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.customGrey50,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
              Container(
                alignment: Alignment.topCenter,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage("assets/signup_illus.png"),
                //     alignment: Alignment.topCenter,
                //   ),
                // ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 200.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                      child: Container(
                        // width: Responsive.isDesktop(context)
                        //     ? 500
                        //     : double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.customBgPrimary.withOpacity(0.9),
                              AppColors.customGrey.withOpacity(0.5),
                            ], // Adding opacity to make it look more like glass
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Form(
                            key: _formKey,
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  CardTitleText(
                                    text: "Sign Up",
                                    fontsize: 50,
                                    color: AppColors.customBlue,
                                  ),
                                  SizedBox(height: 30),
                                  CustomInputTextField(
                                    controller: name,
                                    label: "Full Name",
                                    keyboard: TextInputType.name,
                                    leadingIcon: Icon(
                                      Icons.person,
                                      color: AppColors.customBlue,
                                    ),
                                    ValidateTextField: (name) =>
                                    name!.length < 3
                                        ? "Please enter your full name"
                                        : null,
                                  ),
                                  SizedBox(height: 30),
                                  CustomInputTextField(
                                    controller: email,
                                    label: "Email",
                                    keyboard: TextInputType.emailAddress,
                                    // ValidateTextField: SignupEmailValidation,
                                    leadingIcon: Icon(
                                      Icons.email_rounded,
                                      color: AppColors.customBlue,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  CustomInputTextField(
                                    controller: mobile,
                                    label: "Phone Number",
                                    keyboard: TextInputType.phone,
                                    leadingIcon: Icon(
                                      Icons.phone,
                                      color: AppColors.customBlue,
                                    ),
                                    // ValidateTextField: validatePhone,
                                  ),
                                  SizedBox(height: 30),
                                  CustomInputTextField(
                                    controller: empId,
                                    label: "Employee ID",
                                    keyboard: TextInputType.text,
                                    leadingIcon: Icon(
                                      Icons.badge,
                                      color: AppColors.customBlue,
                                    ),
                                    ValidateTextField: (empId) => empId!.isEmpty
                                        ? "Please enter your employee ID"
                                        : null,
                                  ),
                                  SizedBox(height: 30),
                                  CustomPasswordTextField(
                                    controller: password,
                                    label: "Password",
                                    ValidateTextfield: (password) => password!
                                        .length <
                                        6
                                        ? "Password should be at least 6 characters"
                                        : null,
                                  ),
                                  SizedBox(height: 30),
                                  CustomPasswordTextField(
                                    controller: confirmPassword,
                                    textInputAction: TextInputAction.done,
                                    label: "Confirm Password",
                                    // ValidateTextfield: validateConfirmPassword,
                                  ),
                                  SizedBox(height: 60),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: Column(
                                      children: [
                                        // Sign Up Button
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  if (isSubmitting) return;

                                                  if (_formKey.currentState!.validate()) {
                                                    setState(() {
                                                      isSubmitting = true;
                                                    });

                                                    String getemail = email.text.trim();

                                                    if (getemail.contains('@')) {
                                                      List<String> emailParts = getemail.split('@');
                                                      String emailDomain = emailParts[1];

                                                      var isDomainExist = await CommonFunctions().doesDomainExist(emailDomain);

                                                      if (isDomainExist) {
                                                        bool signUpSuccess = await signUpWithEmail();

//                                                         if (signUpSuccess) {
//                                                           await fetchDirectorEmails();
//
//                                                           if (directorEmails != null && directorName != null) {
//                                                             String signupName = signUpName.text.trim();
//                                                             String companyName = await CommonFunctions().getCompanyName() as String;
//
//                                                             await sendEmail(
//                                                               name: directorName!,
//                                                               toEmail: directorEmails!,
//                                                               message: '''Hi $directorName,
//
// We wanted to let you know that a new user, $signupName, has just signed up and is currently awaiting your approval to access the platform.
// Please review their details and approve their registration at your earliest convenience.''',
//                                                               companyName: companyName,
//                                                             );
//                                                           }
//                                                         } else {
//                                                           print("❌ No director email found to send email.");
//                                                         }
                                                      } else {
                                                        CommonFunctions.showSnackBar("This domain is not registered.");
                                                      }
                                                    }

                                                    setState(() {
                                                      isSubmitting = false;
                                                    });
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.customBlue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.symmetric(vertical: 10),
                                                ),
                                                child: Text(
                                                  "Sign Up",
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.normal,
                                                    color: AppColors.customWhite,
                                                  ),
                                                ),
                                              ),

                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const LoginPage()),
                                            );

                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.customWhite,
                                              ),
                                              children: [
                                                TextSpan(
                                                    text:
                                                    "Already have an account? "),
                                                TextSpan(
                                                  text: "Log in",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.customBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}