import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/screens/dashboard/dashboard.dart';
import '../../main.dart';
import '../../utils/common.dart';
import '../profile_setup/profile_walkthrough.dart';
import 'forgot_password.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/screens/auth/sign_up.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                60.height,

                // App Logo
                Image.asset(
                  'assets/icon.png',
                  width: 120,
                  height: 120,
                ),
                30.height,

                // Sign In Text
                Text(
                  'Sign In',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                10.height,

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: inputDecoration(context,
                            labelText: 'Email/Username'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email/Username is required';
                          } else if (!emailValidate.hasMatch(value)) {
                            return 'Enter a valid Email/Username';
                          }
                          return null;
                        },
                      ),
                      20.height,
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(DEFAULT_RADIUS)),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureText,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                15.height,

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ForgotPasswordScreen().launch(context);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: scribblrPrimaryColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                30.height,

                // Larger Sign In Button
                SizedBox(
                  width: double.infinity, // Makes the button full-width
                  child: AppButton(
                    elevation: 0,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        DashboardScreen().launch(context);
                      }
                    },
                    color: scribblrPrimaryColor,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
                20.height,

                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        SignUpScreen().launch(context);
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                            color: scribblrPrimaryColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
