import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Components/TextFields.dart';
import '../Utils/AppColorTheme.dart';
import '../Utils/CommonFunctions.dart';
import '../Utils/StorageService.dart';
import '../ViewModels/SignupViewModel.dart';
import 'LoginPage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  Future<bool> signUpWithEmail(SignupViewModel viewModel) async {
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

    final error = await viewModel.signupWithEmail();

    Navigator.pop(context);

    if(error == null){
      Navigator.pushNamed(context, "/login");
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
      return true;
    } else {
      print(viewModel.errorMessage);
      String errorText = viewModel.errorMessage;
      CommonFunctions.showSnackBar(errorText);
      return false;
    }

    /*try {
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
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignupViewModel>(context);

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
                            key: viewModel.formKey,
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
                                    controller: viewModel.name,
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
                                    controller: viewModel.email,
                                    label: "Email",
                                    keyboard: TextInputType.emailAddress,
                                    ValidateTextField: viewModel.SignupEmailValidation,
                                    leadingIcon: Icon(
                                      Icons.email_rounded,
                                      color: AppColors.customBlue,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  CustomInputTextField(
                                    controller: viewModel.mobile,
                                    label: "Phone Number",
                                    keyboard: TextInputType.phone,
                                    leadingIcon: Icon(
                                      Icons.phone,
                                      color: AppColors.customBlue,
                                    ),
                                    ValidateTextField: viewModel.validatePhone,
                                  ),
                                  SizedBox(height: 30),
                                  CustomInputTextField(
                                    controller: viewModel.empId,
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
                                    controller: viewModel.password,
                                    label: "Password",
                                    ValidateTextfield: (password) => password!
                                        .length <
                                        6
                                        ? "Password should be at least 6 characters"
                                        : null,
                                  ),
                                  SizedBox(height: 30),
                                  CustomPasswordTextField(
                                    controller: viewModel.confirmPassword,
                                    textInputAction: TextInputAction.done,
                                    label: "Confirm Password",
                                    ValidateTextfield: viewModel.validateConfirmPassword,
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
                                                  if (viewModel.isSubmitting) return;

                                                  if (viewModel.formKey.currentState!.validate()) {
                                                      viewModel.isSubmitting = true;
                                                      viewModel.notifyListeners();

                                                    String getemail = viewModel.email.text.trim();

                                                    if (getemail.contains('@')) {
                                                      List<String> emailParts = getemail.split('@');
                                                      String emailDomain = emailParts[1];

                                                      var isDomainExist = await CommonFunctions().doesDomainExist(emailDomain);

                                                      if (isDomainExist) {
                                                        bool signUpSuccess = await signUpWithEmail(viewModel);

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

                                                      viewModel.isSubmitting = false;
                                                      viewModel.notifyListeners();
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