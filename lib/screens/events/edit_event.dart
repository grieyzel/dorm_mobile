import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/colors.dart';
import '../../utils/constant.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  EditEventScreen({required this.eventData});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String _selectedStatus = "Active"; // Default status

  @override
  void initState() {
    super.initState();
    titleController.text = widget.eventData["title"] ?? "";
    descriptionController.text = widget.eventData["description"] ?? '';
    _selectedStatus = widget.eventData["status"] ?? "Active";
  }

  // Function to pick an image from the gallery
  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  // Function to update the event
  Future<void> _updateEvent() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      toast("Please fill all fields");
      return;
    }

    var request = http.MultipartRequest(
      "POST",
      Uri.parse('$BaseUrl/api/events/${widget.eventData["id"]}'),
    );

    request.fields['title'] = titleController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['status'] = _selectedStatus;

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

      if (response.statusCode == 200) {
        toast("Event updated successfully");
        Navigator.pop(
            context, true); // Return 'true' to indicate update success
      } else {
        debugPrint("❌ Server Error: ${response.statusCode}");
        debugPrint("❌ Full Response Body: $responseBody");
        toast("Failed to update event");
      }
    } catch (error) {
      debugPrint("❌ Error: $error");
      toast("Something went wrong. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Announcement")),
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
                    image: (_image != null
                        ? DecorationImage(
                            image: FileImage(File(_image!.path)),
                            fit: BoxFit.cover,
                          )
                        : widget.eventData["image"] != null
                            ? DecorationImage(
                                image: NetworkImage(widget.eventData["image"]),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: _image == null && widget.eventData["image"] == null
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
                if (_image != null || widget.eventData["image"] != null)
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
                hintText: "Enter event title...",
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

            SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scribblrPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Save Changes",
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
