import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/utils/constant.dart';
import 'package:path/path.dart' as p;

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({Key? key}) : super(key: key);

  @override
  _AddDocumentScreenState createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? selectedFile;
  bool isLoading = false;

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitDocument() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ All fields are required!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request =
          http.MultipartRequest("POST", Uri.parse('$BaseUrl/api/documents'));
      request.fields['title'] = titleController.text;
      request.fields['description'] = descriptionController.text;
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        selectedFile!.path,
        filename: p.basename(selectedFile!.path),
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Document uploaded successfully")),
        );

        // Navigate back with success result
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to upload document. Try again.")),
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
      appBar: AppBar(title: Text("Upload Document")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Document Title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            10.height,
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter document title...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            20.height,
            Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            10.height,
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: "Enter description...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            20.height,
            Text(
              "Select Document",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            10.height,
            buildFilePicker(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: isLoading ? null : submitDocument,
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

  Widget buildFilePicker() {
    return GestureDetector(
      onTap: pickDocument,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            selectedFile == null
                ? Text("No file selected", style: TextStyle(color: Colors.grey))
                : Expanded(
                    child: Text(
                      p.basename(selectedFile!.path),
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            Icon(Icons.attach_file, color: scribblrPrimaryColor),
          ],
        ),
      ),
    );
  }
}
