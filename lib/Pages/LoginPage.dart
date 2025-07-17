import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Components/TextFields.dart';
import '../Utils/AppColorTheme.dart';
import '../ViewModels/LoginViewModel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  void initState() {
    super.initState();
    // navigateAfterDelay();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.customGrey50,
      body:
          viewModel.isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: CupertinoColors.activeBlue,
                  backgroundColor: Colors.lightBlueAccent,
                ),
              )
              : SingleChildScrollView(
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
                        padding: const EdgeInsets.only(
                          top: 250,
                          right: 10,
                          left: 10,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Form(
                                  key: viewModel.formkey,
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: CustomInputTextField(
                                          controller: viewModel.loginUsername,
                                          label: "Email",
                                          keyboard: TextInputType.emailAddress,
                                          leadingIcon: Icon(
                                            Icons.email,
                                            color: AppColors.customBlue,
                                          ),
                                          ValidateTextField:
                                              viewModel.EmailValidation,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.03),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: CustomPasswordTextField(
                                          controller: viewModel.loginPassword,
                                          textInputAction: TextInputAction.done,
                                          label: "Password",
                                          ValidateTextfield:
                                              viewModel.PasswordValidation,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 15.0,
                                            ),
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

                                      if (viewModel.errorMessage != null) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Text(
                                            viewModel.errorMessage!,
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () {
                                                  if (viewModel.formkey.currentState!
                                                      .validate()) {
                                                    viewModel.UserLogin(context);
                                                    print("login success");
                                                  } else {
                                                      viewModel.errorMessage =
                                                          "Please fix the errors";
                                                      viewModel.notifyListeners();// Show validation error if form is not valid
                                                  }
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.customBlue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                  child: CardTitleText(
                                                    text: "Login",
                                                    fontsize: 24,
                                                    color:
                                                        AppColors.customWhite,
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
                                          Navigator.pushNamed(
                                            context,
                                            "/signup",
                                          );
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.customWhite,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: "Don't have an account? ",
                                              ),
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
                ),
              ),
    );
  }
}
