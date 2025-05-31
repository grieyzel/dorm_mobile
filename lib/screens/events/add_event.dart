import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/colors.dart';
import '../../utils/constant.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool _isLoading = false; // ✅ Added loading state

  // Function to pick image from gallery
  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  // Function to save event to API
  Future<void> _saveEvent() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        _image == null) {
      toast("Please fill all fields and select an image");
      return;
    }

    setState(() {
      _isLoading = true; // ✅ Start loading
    });

    var request = http.MultipartRequest(
      "POST",
      Uri.parse('$BaseUrl/api/events'),
    );
    request.fields['title'] = titleController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['status'] = 'A';
    request.files.add(await http.MultipartFile.fromPath('photo', _image!.path));

    debugPrint("📌 Sending Request: ${request.fields}");

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      debugPrint("📌 Final Request URL: ${response.request?.url}");
      debugPrint("✅ Response Status: ${response.statusCode}");
      debugPrint("✅ Response Body: $responseBody");

      if (response.statusCode == 201) {
        toast("Event created successfully");
        Navigator.pop(context);
      } else {
        debugPrint("❌ Server Error: ${response.statusCode}");
        toast("Failed to create event");
      }
    } catch (error) {
      debugPrint("❌ Error: $error");
      toast("Something went wrong. Please try again.");
    } finally {
      setState(() {
        _isLoading = false; // ✅ Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Announcement")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image Picker
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[300],
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(File(_image!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _image == null
                      ? GestureDetector(
                          onTap: getImage,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, color: Colors.grey[700]),
                              Text('Add Announcement Image',
                                  style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        )
                      : null,
                ),
                if (_image != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: getImage,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scribblrPrimaryColor,
                        ),
                        child: Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),

            // Event Title Input
            Text("Announcement Title",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter Announcement title...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Event Description Input
            Text("Announcement Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter Announcement description...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Submit Button with Loading Indicator
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoading ? null : _saveEvent, // ✅ Disable when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: scribblrPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Create Announcement",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
