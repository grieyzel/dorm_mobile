import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/utils/colors.dart';
import '../../utils/constant.dart';

import 'package:scribblr/screens/announcement/add_announcement.dart';
import 'package:scribblr/screens/announcement/edit_announcement.dart';

class AnnouncementListScreen extends StatefulWidget {
  @override
  _AnnouncementListScreenState createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> announcements = [];
  List<Map<String, dynamic>> filteredAnnouncements = [];
  bool isLoading = true;
  bool hasError = false;
  String userRole = ""; // Store user role

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchAnnouncements();
  }

  Future<void> fetchUserData() async {
    try {
      String userData = await getStringAsync("user_data", defaultValue: "");

      if (userData.isNotEmpty) {
        Map<String, dynamic> user = jsonDecode(userData);
        setState(() {
          userRole = user["role"]; // Assign user role
        });
      }
    } catch (e) {
      print("Failed to fetch user data: $e");
    }
  }

  Future<void> fetchAnnouncements() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse('$BaseUrl/api/announcement'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          announcements = data.map((announcement) {
            return {
              "id": announcement["id"],
              "title": announcement["title"],
              "description": announcement["description"],
              "image":
                  '$BaseUrl${announcement["photo_path"]}', // Full image URL
            };
          }).toList();

          filteredAnnouncements = announcements;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void filterAnnouncements(String query) {
    setState(() {
      filteredAnnouncements = announcements
          .where((announcement) => announcement["title"]!
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteAnnouncement(int announcementId) async {
    try {
      final response = await http.delete(
        Uri.parse('$BaseUrl/api/announcement/$announcementId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          announcements.removeWhere(
              (announcement) => announcement["id"] == announcementId);
          filteredAnnouncements =
              List.from(announcements); // Refresh filtered list
        });
        toast("Announcement deleted successfully");
      } else {
        toast("Failed to delete announcement");
      }
    } catch (e) {
      toast("Error deleting announcement: $e");
    }
  }

  void showDeleteConfirmationDialog(int announcementId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                deleteAnnouncement(announcementId); // Proceed with deletion
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Events"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 10.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterAnnouncements,
                  decoration: InputDecoration(
                    hintText: "Search Events...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              // Announcement List View
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : hasError
                        ? Center(
                            child: Text("Failed to load Events. Try again."))
                        : filteredAnnouncements.isEmpty
                            ? Center(child: Text("No Events found."))
                            : ListView.builder(
                                padding: EdgeInsets.only(bottom: 16.0),
                                itemCount: filteredAnnouncements.length,
                                itemBuilder: (context, index) {
                                  var announcement =
                                      filteredAnnouncements[index];

                                  return GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditAnnouncementScreen(
                                            announcementData: announcement,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        fetchAnnouncements(); // Refresh after edit
                                      }
                                    },
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Announcement Image
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                announcement["image"]!,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),

                                            // Announcement Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    announcement["title"] ?? "",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 6),
                                                  Text(
                                                    announcement[
                                                            "description"] ??
                                                        "",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Delete Button (Only if Admin)
                                            if (userRole != "S")
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    showDeleteConfirmationDialog(
                                                        announcement["id"]),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button for Adding New Announcements
      floatingActionButton: userRole == "S"
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateAnnouncementScreen()),
                );

                if (result == true) {
                  fetchAnnouncements(); // ✅ Refresh the list when returning
                }
              },
              backgroundColor: scribblrPrimaryColor,
              child: Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
