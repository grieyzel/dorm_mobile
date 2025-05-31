import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:scribblr/screens/settings_screen/docu_add.dart';

import 'package:scribblr/utils/constant.dart';

class DocumentListScreen extends StatefulWidget {
  @override
  _DocumentListScreenState createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  List<dynamic> documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      final response = await http.get(Uri.parse('$BaseUrl/api/documents'));

      if (response.statusCode == 200) {
        setState(() {
          documents = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception("❌ Failed to load documents.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error: $e");
    }
  }

  Future<void> downloadDocument(String filePath) async {
    String downloadUrl = "$BaseUrl/storage/$filePath";
    await launch(downloadUrl);
  }

  void navigateToAddDocument() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddDocumentScreen()),
    );

    // ✅ Refresh document list after returning from AddDocumentScreen
    if (result == true) {
      fetchDocuments();
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('$BaseUrl/api/documents/$id'));

      if (response.statusCode == 200) {
        setState(() {
          documents.removeWhere((document) => document["id"] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Document deleted successfully")),
        );
      } else {
        throw Exception("❌ Failed to delete document.");
      }
    } catch (e) {
      debugPrint("❌ Error deleting document: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Document"),
          content: Text("Are you sure you want to delete this document?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteDocument(id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text("Yes, Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document List"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : documents.isEmpty
                ? Center(child: Text("No documents available"))
                : ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      var document = documents[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.insert_drive_file, size: 40),
                          title: Text(
                            document["title"],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              Text(document["description"] ?? "No description"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.download, color: Colors.blue),
                                onPressed: () =>
                                    downloadDocument(document["file_path"]),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => confirmDelete(document["id"]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddDocument,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        tooltip: "Add Document",
      ),
    );
  }
}
