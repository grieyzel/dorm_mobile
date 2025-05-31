import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scribblr/utils/colors.dart';
import '../../utils/constant.dart';
import 'package:scribblr/screens/chat/message_screen/message_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({Key? key}) : super(key: key); // Accept key

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedLanguage = "en";
  Map<String, String> translations = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchStudents();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newLanguage = prefs.getString('language') ?? "en";
    if (newLanguage != selectedLanguage) {
      setState(() {
        selectedLanguage = newLanguage;
      });
      _translateAll();
      fetchStudents();
    }
  }

  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse('$BaseUrl/api/users/'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            students = List<Map<String, dynamic>>.from(data['data']);
            filteredStudents = students;
            isLoading = false;
          });
          _translateAll();
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
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
      "Search student...",
      "Failed to load students. Try again later.",
      "Room",
      "Kakao",
      "Phone",
      "About Me"
    ];

    for (var student in students) {
      if (student["about_me"] != null && student["about_me"].isNotEmpty) {
        texts.add(student["about_me"]);
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

  @override
  void didChangeDependencies() {
    debugPrint("WOWWWWWWWWWWW");
    super.didChangeDependencies();
    _loadUserData();
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

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStudents = students;
      });
    } else {
      setState(() {
        filteredStudents = students.where((student) {
          String fullName =
              "${student["firstname"]} ${student["middlename"] ?? ""} ${student["lastname"]}"
                  .toLowerCase();
          return fullName.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: filterSearchResults,
              decoration: InputDecoration(
                hintText:
                    translations["Search student..."] ?? "Search student...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 10),
            if (isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (hasError)
              Expanded(
                  child: Center(
                      child: Text(translations[
                              "Failed to load students. Try again later."] ??
                          "Failed to load students. Try again later.")))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    var student = filteredStudents[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                            "${student["firstname"]} ${student["middlename"] ?? ""} ${student["lastname"]}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${translations["Room"] ?? "Room"}: ${student["room_id"] ?? "N/A"}"),
                            Text(
                                "${translations["Kakao"] ?? "Kakao"}: ${student["kakao"] ?? "N/A"}"),
                            Text(
                                "${translations["Phone"] ?? "Phone"}: ${student["phone"] ?? "N/A"}"),
                            Text(
                                "${translations[student["about_me"]] ?? student["about_me"]}",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700]))
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
