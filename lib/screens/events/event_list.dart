import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/screens/events/add_event.dart';
import 'package:scribblr/screens/events/edit_event.dart';
import '../../utils/constant.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  bool isLoading = true;
  bool hasError = false;
  String userRole = "";
  String selectedLanguage = "en";
  Map<String, String> translations = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _loadUserLanguage();
    fetchEvents();
  }

  Future<void> _loadUserLanguage() async {
    String? newLanguage = getStringAsync("language", defaultValue: "en");
    if (newLanguage != selectedLanguage) {
      setState(() {
        selectedLanguage = newLanguage;
      });
      _translateAll();
      fetchEvents();
    }
  }

  Future<void> fetchUserData() async {
    try {
      String userData = await getStringAsync("user_data", defaultValue: "");

      if (userData.isNotEmpty) {
        Map<String, dynamic> user = jsonDecode(userData);
        String role = user["role"];
        setState(() {
          userRole = role;
        });
      }
    } catch (e) {
      print("Failed to fetch user data: $e");
    }
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse('$BaseUrl/api/events'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          events = data.map((event) {
            return {
              "id": event["id"],
              "title": event["title"],
              "description": event["description"],
              "image": '$BaseUrl${event["photo_path"]}',
              "creatorImage": "assets/default_user.png",
              "creatorName": "Administrator"
            };
          }).toList();

          filteredEvents = events;
          isLoading = false;
        });

        _translateAll();
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

  Future<void> _translateAll() async {
    setState(() {
      isLoading = true;
    });

    List<String> texts = [
      "Search announcement...",
      "Failed to load events. Try again.",
      "No events found.",
      "Confirm Delete",
      "Are you sure you want to delete this event?",
      "Cancel",
      "Delete",
    ];

    for (var event in events) {
      if (event["description"] != null && event["description"].isNotEmpty) {
        texts.add(event["description"]);
      }
      if (event["title"] != null && event["title"].isNotEmpty) {
        texts.add(event["title"]);
      }
    }

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

    setState(() {
      isLoading = false;
    });
  }

  void showDeleteConfirmationDialog(int eventId) {
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
                deleteEvent(eventId); // Proceed with deletion
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteEvent(int eventId) async {
    final response =
        await http.delete(Uri.parse('$BaseUrl/api/events/$eventId'));

    if (response.statusCode == 200) {
      setState(() {
        events.removeWhere((event) => event["id"] == eventId);
        filteredEvents = List.from(events); // Update the filtered list
      });
      toast("Event deleted successfully");
    } else {
      toast("Failed to delete event. Try again.");
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

  void filterEvents(String query) {
    setState(() {
      filteredEvents = events
          .where((event) =>
              event["title"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Announcement"),
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
                  onChanged: filterEvents,
                  decoration: InputDecoration(
                    hintText: translations["Search announcement..."] ??
                        "Search announcement...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              // Event List View
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : hasError
                        ? Center(
                            child: Text(translations[
                                    "Failed to load events. Try again."] ??
                                "Failed to load events. Try again."))
                        : filteredEvents.isEmpty
                            ? Center(
                                child: Text(translations["No events found."] ??
                                    "No events found."))
                            : ListView.builder(
                                padding: EdgeInsets.only(
                                    bottom: 16.0), // Prevent bottom overflow
                                itemCount: filteredEvents.length,
                                itemBuilder: (context, index) {
                                  var event = filteredEvents[index];

                                  return GestureDetector(
                                    onTap: () {
                                      if (userRole != "S") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditEventScreen(
                                                eventData: event),
                                          ),
                                        ).then((updated) {
                                          if (updated == true) {
                                            fetchEvents(); // Refresh the list after editing
                                          }
                                        });
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
                                            // Event Image
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                event["image"]!,
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

                                            // Event Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Event Title
                                                  Text(
                                                    translations[
                                                            event["title"]] ??
                                                        event["title"],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 6),

                                                  // Event Description
                                                  Text(
                                                    translations[event[
                                                            "description"]] ??
                                                        event["description"],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 8),

                                                  // Event Creator and Remove Button
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundImage:
                                                                AssetImage(
                                                              event["creatorImage"] ??
                                                                  "",
                                                            ),
                                                            radius: 14,
                                                          ),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            event["creatorName"] ??
                                                                "Administrator",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (userRole != "S")
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.red),
                                                          onPressed: () {
                                                            showDeleteConfirmationDialog(
                                                                event["id"]);
                                                          },
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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

      // Hide Add Button if User is Admin
      floatingActionButton: userRole == "S"
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateEventScreen()),
                );
              },
              backgroundColor: scribblrPrimaryColor,
              child: Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}
