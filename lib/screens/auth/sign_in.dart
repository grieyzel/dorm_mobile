import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/screens/dashboard/dashboard.dart';
import '../../utils/common.dart';
import '../profile_setup/profile_walkthrough.dart';
import 'forgot_password.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/screens/auth/sign_up.dart';
import 'package:lottie/lottie.dart';
import '../../utils/constant.dart';

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

  Future<void> _signIn() async {
    debugPrint("✅ Form validation passed");
    var url = Uri.parse('$BaseUrl/api/login');
    var body = jsonEncode({
      "email": emailController.text,
      "password": passwordController.text,
    });

    debugPrint("📌 Sending Request2: $body");

    try {
      var response = await http.post(
        url,
        body: body,
        headers: {"Content-Type": "application/json"},
      );

      var data = jsonDecode(response.body);
      if (data["success"] == true) {
        debugPrint("✅ Success");
        await setValue("user_data", jsonEncode(data["data"]));
        DashboardScreen().launch(context);
      } else {
        debugPrint("❌ Server Error: ${response.statusCode}");
        debugPrint(response.toString());
        _showErrorDialog(data["message"]);
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      _showErrorDialog("Something went wrong. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Lottie.asset('assets/error.json', height: 80, repeat: false),
              SizedBox(height: 10),
              Text("Error",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: scribblrPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

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
                Image.asset(
                  'assets/icon.png',
                  width: 120,
                  height: 120,
                ),
                30.height,
                Text(
                  'Sign In',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                10.height,
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
                          if (value!.isEmpty)
                            return 'Email/Username is required';
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
                        validator: (value) =>
                            value!.isEmpty ? 'Password is required' : null,
                      ),
                    ],
                  ),
                ),
                15.height,
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
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    elevation: 0,
                    onTap: _signIn,
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
