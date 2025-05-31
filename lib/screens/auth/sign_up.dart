import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/screens/auth/sign_in.dart';
import 'package:scribblr/utils/colors.dart';
import '../../utils/constant.dart';
import 'package:lottie/lottie.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController kakaoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscureText = true;
  bool isLoading = false;

  // Room selection
  String? selectedRoom;
  List<String> rooms = ['101', '102', '103', '104', '105', '106', '107', '108'];

  @override
  void initState() {
    super.initState();
    selectedRoom = rooms[0]; // Default selection
  }

  Future<void> registerUser() async {
    debugPrint("✅ Form validation passed");

    setState(() => isLoading = true);
    showLoadingDialog();

    try {
      var url = Uri.parse('$BaseUrl/api/register');
      var requestBody = {
        "firstname": firstNameController.text,
        "middlename": '',
        "lastname": lastNameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "role": "S",
        "room_id": selectedRoom,
        "kakao": kakaoController.text,
        "password": passwordController.text,
        "password_confirmation": confirmPasswordController.text,
        "privacy_settings": {"hide_phone": false, "hide_about_me": false}
      };

      debugPrint("📌 Sending Request: ${requestBody}");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      Navigator.pop(context);
      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        debugPrint("✅ Registration Successful");
        showSuccessDialog();
      } else {
        var responseData = jsonDecode(response.body);
        debugPrint("❌ Server Error: ${response.statusCode}");
        debugPrint(responseData.toString());
        showErrorDialog(
            responseData["error"] ?? "Registration failed. Try again.");
      }
    } catch (e) {
      Navigator.pop(context);
      setState(() => isLoading = false);
      debugPrint("❌ Error: $e");
      toast("An error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        // ✅ Keep a single Form here
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildAccountStep(),
            _buildProfileStep(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: AppButton(
          elevation: 0,
          onTap: () {
            if (_currentIndex == 0) {
              if (_formKey.currentState!.validate()) {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentIndex = 1);
              } else {
                debugPrint("⚠️ Form validation failed");
              }
            } else {
              registerUser();
            }
          },
          color: scribblrPrimaryColor,
          shapeBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Text(
            _currentIndex == 0 ? 'Next' : 'Sign Up',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Registration completed successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => SignInScreen()));
              },
              child: Text("Go to Sign In"),
            ),
          ],
        );
      },
    );
  }

  InputDecoration inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildAccountStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 100, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Create Your Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Please enter your account details to continue.",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 30),
          TextFormField(
            controller: emailController,
            decoration: inputDecoration("Email"),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty ? "Email is required" : null,
          ),
          15.height,
          TextFormField(
            controller: passwordController,
            decoration: inputDecoration("Password"),
            obscureText: _obscureText,
            validator: (value) => value!.isEmpty
                ? "Password is required"
                : value.length < 6
                    ? "Password must be at least 6 characters"
                    : null,
          ),
          15.height,
          TextFormField(
            controller: confirmPasswordController,
            decoration: inputDecoration("Confirm Password"),
            obscureText: _obscureText,
            validator: (value) => value != passwordController.text
                ? "Passwords do not match"
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 100, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Profile Information",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
              "Please enter your personal details to complete the registration.",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 30),
          TextFormField(
              controller: firstNameController,
              decoration: inputDecoration("First Name"),
              validator: (value) =>
                  value!.isEmpty ? "First name is required" : null),
          15.height,
          TextFormField(
              controller: lastNameController,
              decoration: inputDecoration("Last Name"),
              validator: (value) =>
                  value!.isEmpty ? "Last name is required" : null),
          15.height,
          TextFormField(
            controller: phoneController,
            decoration: inputDecoration("Phone"),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return "Phone number is required";
              if (!RegExp(r'^[0-9]+\$').hasMatch(value))
                return "Enter a valid phone number";
              return null;
            },
          ),
          15.height,
          TextFormField(
              controller: kakaoController,
              decoration: inputDecoration("Kakao ID"),
              validator: (value) =>
                  value!.isEmpty ? "Kakao ID is required" : null),
          15.height,
          DropdownButtonFormField<String>(
            decoration: inputDecoration("Dorm"),
            items: rooms
                .map((room) =>
                    DropdownMenuItem<String>(value: room, child: Text(room)))
                .toList(),
            value: selectedRoom,
            onChanged: (value) => setState(() => selectedRoom = value),
            validator: (value) => value == null ? "Select a Dorm" : null,
          ),
        ],
      ),
    );
  }
}
