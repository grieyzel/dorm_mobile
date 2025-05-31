import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:scribblr/utils/constant.dart';
import 'dart:convert';

import '../main.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import 'package:scribblr/screens/dashboard/dashboard.dart';

class CreateBulletinScreen extends StatefulWidget {
  const CreateBulletinScreen({super.key});

  @override
  State<CreateBulletinScreen> createState() => _CreateBulletinScreenState();
}

class _CreateBulletinScreenState extends State<CreateBulletinScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  TextEditingController descriptionController = TextEditingController();
  String? userId; // Stores logged-in user ID
  String selectedLanguage = "en";
  Map<String, String> translations = {};

  @override
  void initState() {
    super.initState();

    _loadUserData();
    getUserId(); // Fetch the user ID
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newLanguage = prefs.getString('language') ?? "en";
    if (newLanguage != selectedLanguage) {
      setState(() {
        selectedLanguage = newLanguage;
      });
      _translateAll();
    }
  }

  Future<void> _translateAll() async {
    List<String> texts = [
      "Create Bulletin",
      "Add Image (Optional)",
      "Write your post here...",
      "Add post",
    ];

    String textToTranslate = texts.join(" || ");
    String? translatedText =
        await translateText(textToTranslate, selectedLanguage);

    if (translatedText != null) {
      List<String> translatedParts = translatedText.split(" || ");
      for (int i = 0; i < texts.length; i++) {
        translations[texts[i]] =
            translatedParts.length > i ? translatedParts[i] : texts[i];
      }
    }
  }

  Future<String?> translateText(String text, String targetLanguage) async {
    final String url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse[0].map((e) => e[0]).join("");
      } else {
        return text;
      }
    } catch (e) {
      return text;
    }
  }

  /// **Fetch the logged-in user ID**
  Future<void> getUserId() async {
    String? userData = getStringAsync("user_data", defaultValue: "");
    if (userData.isNotEmpty) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        userId = user["id"].toString(); // Store user ID
      });
    }
  }

  /// **Pick Image from Gallery**
  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  /// **Save Bulletin to API**
  Future<void> _saveBulletin() async {
    if (descriptionController.text.isEmpty) {
      toast("Please write something");
      return;
    }
    if (userId == null) {
      toast("User not found. Please log in again.");
      return;
    }

    var request = http.MultipartRequest(
      "POST",
      Uri.parse('$BaseUrl/api/bulletins'),
    );

    request.fields['created_by'] = userId!;
    request.fields['description'] = descriptionController.text;

    // Add photo only if selected
    if (_image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('photo', _image!.path));
    }

    debugPrint("📌 Sending Request: ${request.fields}");

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      debugPrint("📌 Final Request URL: ${response.request?.url}");
      debugPrint("✅ Response Status: ${response.statusCode}");
      debugPrint("✅ Response Body: $responseBody");

      if (response.statusCode == 201) {
        toast("Post created successfully");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        debugPrint("❌ Server Error: ${response.statusCode}");
        debugPrint("❌ Full Response Body: $responseBody");
        toast("Failed to create bulletin");
      }
    } catch (error) {
      debugPrint("❌ Error: $error");
      toast("Something went wrong. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('${translations["Room"] ?? "Create Bulletin"}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImageStack(),
            15.height,
            buildDescriptionTextField(),
            20.height,
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// **UI - Image Picker**
  Stack buildImageStack() {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            image: _image == null
                ? null
                : DecorationImage(
                    image: FileImage(File(_image!.path)), fit: BoxFit.cover),
            color: borderColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: _image == null
              ? GestureDetector(
                  onTap: getImage,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: textSecondaryColor),
                        Text(
                            '${translations["Add Image (Optional)"] ?? "Add Image (Optional)"}',
                            style: secondaryTextStyle())
                      ]),
                )
              : null,
        ),
        if (_image != null)
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  color: scribblrPrimaryColor, shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(Icons.edit, size: 15, color: Colors.white),
                onPressed: getImage,
              ),
            ),
          ),
      ],
    );
  }

  /// **UI - Bulletin Description**
  TextField buildDescriptionTextField() {
    return TextField(
      controller: descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText:
            '${translations["Write your post here..."] ?? "Write your post here..."}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: borderColor,
      ),
    );
  }

  /// **UI - Submit Button**
  SizedBox buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveBulletin,
        style: ElevatedButton.styleFrom(
          backgroundColor: scribblrPrimaryColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "${translations["Add post"] ?? "Add post"}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
