import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Components/TextFields.dart';
import '../PageComponents/BottomNavBar.dart';
import '../Utils/AppColorTheme.dart';
import '../Utils/CommonFunctions.dart';
import '../Utils/StorageKeys.dart';
import '../Utils/StorageService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController loginUsername = TextEditingController();
  TextEditingController loginPassword = TextEditingController();
  TextEditingController resetPasswordEmail = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  String? errorMessage;

  void initState() {
    super.initState();
    // navigateAfterDelay();
  }


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

  // Password validation function
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

  void UserLogin() async {
    String normalizedEmail = loginUsername.text.trim().toLowerCase();
    // Show loading dialog


    List<String> emailParts = normalizedEmail.split('@');
    if (emailParts.length != 2) {
      print("❌ Invalid email format.");
      return ;
    }
    String domain = emailParts[1];

    var result = CommonFunctions().getDomainCollection(domain);
    String dynamicCollection = result["primary"] ?? "";
    String dynamicTeamsCollection = result["secondary"] ?? "";
    String dynamicLeaveCollection = result["tertiary"] ?? "";
    print("dynamicLeaveCollection $dynamicLeaveCollection");



    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.lightBlue,
          ),
        );
      },
    );

    try {
      // Check if the user exists
      bool userExists = await doesUserExist(normalizedEmail,dynamicCollection);
      if (!userExists) {
        setState(() {
          errorMessage = "User does not exist. Please register or try again.";
        });
        Navigator.pop(context); // Dismiss the loading dialog
        return;
      }

      var result = await isUserEnabled(normalizedEmail,dynamicCollection);

      bool isDisabled = result["isDisabled"] ?? false;
      // bool isVerified = result["isVerified"] ?? false;

      if (isDisabled) {
        setState(() {
          errorMessage = "Your account is disabled. Please contact support.";
        });
        Navigator.pop(context); // Dismiss the loading dialog
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

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: loginPassword.text,
      );

      // Get the user's unique ID (uid)
      String uid = userCredential.user?.uid ?? '';

      _saveUserToken(uid);
      await StorageService.instance.saveCollectionName(dynamicCollection);
      await StorageService.instance.saveTeamsCollectionName(dynamicTeamsCollection);
      await StorageService.instance.saveLeaveCollectionName(dynamicLeaveCollection);
      // Handle successful login
      setState(() {
        errorMessage = null; // Clear any previous errors on successful login
      });
      // Navigator.pop(context); // Dismiss the loading dialog

      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
    } catch (error) {
      // If login fails, show an error message
      setState(() {
        errorMessage = "Login failed: Invalid username or password.";
      });
      Navigator.pop(context); // Dismiss the loading dialog
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.customGrey50,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Center(
            child: Container(
              alignment: Alignment.topCenter,
              // Background image temporarily commented out to avoid error
              /*
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Responsive.isDesktop(context)
                      ? AssetImage('assets/signup_illus.png')
                      : AssetImage('assets/loginbg.png'),
                  alignment: Alignment.topCenter,
                ),
              ),
              */
              child: Padding(
                // Padding adjusted to avoid use of missing Responsive utility
                padding: const EdgeInsets.only(top: 250, right: 10, left: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CardTitleText(
                                text: "Login",
                                fontsize: 50,
                                color: AppColors.customBlue,
                              ),
                              SizedBox(height: screenHeight * 0.05),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: CustomInputTextField(
                                  controller: loginUsername,
                                  label: "Email",
                                  keyboard: TextInputType.emailAddress,
                                  leadingIcon: Icon(Icons.email, color: AppColors.customBlue),
                                  ValidateTextField: EmailValidation,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.03),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: CustomPasswordTextField(
                                  controller: loginPassword,
                                  textInputAction: TextInputAction.done,
                                  label: "Password",
                                  ValidateTextfield: PasswordValidation,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: CardTitleText(
                                        text: "Forgot Password?",
                                        textalign: TextAlign.start,
                                        color: AppColors.customBlue,
                                        fontsize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.05),

                              if (errorMessage != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                                  ),
                                ),
                              ],

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          if (_formkey.currentState!
                                              .validate()) {
                                            UserLogin();
                                            print("login success");
                                          } else {


                                            setState(() {
                                              errorMessage =
                                              "Please fix the errors"; // Show validation error if form is not valid
                                            });
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: AppColors.customBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: CardTitleText(
                                            text: "Login",
                                            fontsize: 24,
                                            color: AppColors.customWhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.02),

                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, "/signup");
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 16, color: AppColors.customWhite),
                                    children: [
                                      const TextSpan(text: "Don't have an account? "),
                                      TextSpan(
                                        text: "Sign up",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.customBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            //   const Padding(
                            //     padding: EdgeInsets.symmetric(vertical: 6.0),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Text("------OR------", style: TextStyle(color: Colors.grey)),
                            //       ],
                            //     ),
                            //   ),
                            //
                            //   GestureDetector(
                            //     onTap: () {
                            //       Navigator.pushNamed(context, "/register");
                            //     },
                            //     child: RichText(
                            //       text: TextSpan(
                            //         style: TextStyle(fontSize: 16, color: AppColors.customWhite),
                            //         children: [
                            //           const TextSpan(text: "Do you want to register? "),
                            //           TextSpan(
                            //             text: "Register",
                            //             style: TextStyle(
                            //               fontWeight: FontWeight.bold,
                            //               color: AppColors.customBlue,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            //   SizedBox(height: screenHeight * 0.03),
                            // ],
                         ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}