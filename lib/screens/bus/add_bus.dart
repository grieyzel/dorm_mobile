import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/utils/constant.dart';
import 'package:path/path.dart' as p;

class AddBusScreen extends StatefulWidget {
  const AddBusScreen({Key? key}) : super(key: key);

  @override
  _AddBusScreenState createState() => _AddBusScreenState();
}

class _AddBusScreenState extends State<AddBusScreen> {
  final TextEditingController nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _weekdayImage;
  XFile? _weekendImage;
  bool isLoading = false;

  Future<void> getWeekdayImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      setState(() {
        _weekdayImage = image;
      });
    }
  }

  Future<void> getWeekendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      setState(() {
        _weekendImage = image;
      });
    }
  }

  Future<void> submitBusSchedule() async {
    if (nameController.text.isEmpty ||
        _weekdayImage == null ||
        _weekendImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Please fill all fields and upload images.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
          "POST", Uri.parse('$BaseUrl/api/bus-schedules'));
      request.fields['name'] = nameController.text;
      request.files.add(await http.MultipartFile.fromPath(
        'weekday_schedule',
        _weekdayImage!.path,
        filename: p.basename(
            _weekdayImage!.path), // ✅ FIXED: Prevents context conflict
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'weekend_schedule',
        _weekendImage!.path,
        filename: p.basename(
            _weekendImage!.path), // ✅ FIXED: Prevents context conflict
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Bus schedule added successfully")),
        );

        // ✅ Safe navigation back
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to add bus schedule. Try again.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bus Schedule Upload")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bus Schedule Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            10.height,
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter schedule name...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            30.height,
            Text(
              "Weekday Bus Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            15.height,
            buildImageStack(_weekdayImage, getWeekdayImage),
            30.height,
            Text(
              "Weekend Bus Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            15.height,
            buildImageStack(_weekendImage, getWeekendImage),
            30.height,
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: isLoading ? null : submitBusSchedule,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            backgroundColor: scribblrPrimaryColor,
          ),
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text("Submit",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget buildImageStack(XFile? image, VoidCallback getImageFunction) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            image: image == null
                ? null
                : DecorationImage(
                    image: FileImage(File(image.path)),
                    fit: BoxFit.cover,
                  ),
            color: image == null ? Colors.grey[300] : null,
            borderRadius: BorderRadius.circular(15),
          ),
          child: image == null
              ? GestureDetector(
                  onTap: getImageFunction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, color: Colors.grey),
                      8.height,
                      Text(
                        'Upload Image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        if (image != null)
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: scribblrPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.edit, size: 15, color: Colors.white),
                onPressed: getImageFunction,
              ),
            ),
          ),
      ],
    );
  }
}
