import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:scribblr/utils/colors.dart';
import '../../utils/constant.dart';
import 'package:scribblr/screens/students/edit_student_info.dart';

class ProfileFragment extends StatefulWidget {
  const ProfileFragment({super.key});

  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  // User Information
  int userId = 0;
  String firstName = "";
  String lastName = "";
  String email = "";
  String phone = "";
  String role = "";
  String kakao = "";
  String? avatarFilePath;
  String? coverFilePath;
  int roomId = 0;
  String selectedLanguage = "en";

  // Privacy Settings
  bool hideName = false;
  bool hidePhone = false;
  bool hideAboutMe = false;

  bool isLoading = true; // Show loading until data is fetched

  // Image Pickers
  final ImagePicker _picker = ImagePicker();
  XFile? profileImage;
  XFile? coverImage;

  // Translation Storage
  Map<String, String> translations = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loadUserData();
  }

  /// **Load user ID from SharedPreferences and Fetch Data**
  Future<void> loadUserData() async {
    String userData = await getStringAsync("user_data", defaultValue: "");

    if (userData.isNotEmpty) {
      Map<String, dynamic> user = jsonDecode(userData);
      userId = user["id"]; // Extract User ID
      await fetchUserDetails(userId); // Fetch user data from API
    }
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

  /// **Fetch user details from API**
  Future<void> fetchUserDetails(int id) async {
    try {
      var url = Uri.parse("$BaseUrl/api/users/$id");
      var response =
          await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          firstName = data["firstname"] ?? "";
          lastName = data["lastname"] ?? "";
          email = data["email"] ?? "";
          phone = data["phone"] ?? "";
          role = data["role"] ?? "";
          kakao = data["kakao"] ?? "";
          avatarFilePath = data["avatar_file_path"];
          coverFilePath = data["cover_photo"];
          roomId = data["room_id"] ?? 1;

          // Privacy Settings
          hideName = data["privacy_settings"]["hide_name"] ?? false;
          hidePhone = data["privacy_settings"]["hide_phone"] ?? false;
          hideAboutMe = data["privacy_settings"]["hide_about_me"] ?? false;

          isLoading = false; // Stop loading after fetching data
        });

        _translateAll(); // Trigger translation after fetching data
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  /// **Translate all UI text (except names & emails)**
  Future<void> _translateAll() async {
    setState(() {
      isLoading = true;
    });

    List<String> texts = [
      "Edit",
      "Personal Information",
      "Phone",
      "Room Number",
      "About Me",
      "Privacy Settings",
      "Hide Phone",
      "Hide About Me",
    ];

    if (!hideAboutMe) {
      texts.add("Hey... This is my about section.");
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

  Future<void> updatePrivacySettings(
      {bool? hidePhone, bool? hideAboutMe}) async {
    String url =
        "$BaseUrl/api/users/$userId/privacy"; // User-specific API endpoint

    Map<String, dynamic> payload = {};

    if (hidePhone != null) payload['hide_phone'] = hidePhone;
    if (hideAboutMe != null) payload['hide_about_me'] = hideAboutMe;

    if (payload.isEmpty) return; // No changes, so no request needed

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        toast("Privacy settings updated successfully!");
      } else {
        toast("Failed to update privacy settings");
        debugPrint("Error: ${response.body}");
      }
    } catch (e) {
      toast("Error updating privacy settings");
      debugPrint("Exception: $e");
    }
  }

  Future<String?> translateText(String text, String targetLanguage) async {
    final String url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse[0]
            .map((e) => e[0])
            .join(""); // Extract translated text
      } else {
        debugPrint("Translation API Error: ${response.statusCode}");
        return text; // Return original text if translation fails
      }
    } catch (e) {
      debugPrint("❌ Translation Error: $e");
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  buildCoverProfileSection(),
                  60.height,
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileHeader(),
                        20.height,
                        buildDivider(),
                        15.height,
                        buildPersonalInfoSection(),
                        15.height,
                        buildDivider(),
                        15.height,
                        buildAboutSection(),
                        15.height,
                        buildDivider(),
                        15.height,
                        buildPrivacySettings(),
                        20.height,
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Divider buildDivider() {
    return Divider(thickness: 0.5, color: Colors.grey.shade400);
  }

  /// **Profile Header**
  Row buildProfileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(hideName ? "Hidden" : firstName,
                    style: boldTextStyle(size: 20)),
                5.width,
                Text(hideName ? "" : lastName, style: boldTextStyle(size: 20)),
              ],
            ),
            5.height,
            Text("@$kakao", style: secondaryTextStyle()),
            5.height,
            if (!hidePhone)
              Row(children: [
                Icon(Icons.phone, size: 16),
                5.width,
                Text(phone, style: secondaryTextStyle())
              ]),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide(color: scribblrPrimaryColor)),
          onPressed: () {
            EditStudentInfoScreen().launch(context);
          },
          child: Row(children: [
            Icon(Icons.edit, size: 14, color: scribblrPrimaryColor),
            5.width,
            Text(translations["Edit"] ?? "Edit",
                style: TextStyle(color: scribblrPrimaryColor))
          ]),
        ),
      ],
    );
  }

  /// **Personal Information**
  Column buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translations["Personal Information"] ?? "Personal Information",
            style: boldTextStyle(size: 18)),
        10.height,
        if (!hidePhone) buildInfoRow(translations["Phone"] ?? "Phone", phone),
        10.height,
        buildInfoRow(
            translations["Room Number"] ?? "Room Number", roomId.toString()),
      ],
    );
  }

  Widget buildInfoRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: primaryTextStyle()),
        Spacer(),
        Text(value, style: secondaryTextStyle()),
      ],
    );
  }

  Widget buildCoverProfileSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: coverImage != null
                    ? FileImage(File(coverImage!.path))
                    : (coverFilePath != null
                            ? NetworkImage('$BaseUrl$coverFilePath')
                            : AssetImage('assets/default_cover.jpg'))
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: GestureDetector(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 46,
                backgroundImage: profileImage != null
                    ? FileImage(File(profileImage!.path))
                    : (avatarFilePath != null
                            ? NetworkImage('$BaseUrl$avatarFilePath')
                            : AssetImage('assets/default_user.png'))
                        as ImageProvider,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// **About Me Section**
  Column buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translations["About Me"] ?? "About Me",
            style: boldTextStyle(size: 18)),
        10.height,
        if (!hideAboutMe)
          Text(
              translations["Hey... This is my about section."] ??
                  "Hey... This is my about section.",
              style: secondaryTextStyle(),
              textAlign: TextAlign.justify),
      ],
    );
  }

  /// **Privacy Settings**
  Column buildPrivacySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translations["Privacy Settings"] ?? "Privacy Settings",
            style: boldTextStyle(size: 18)),
        10.height,
        buildSwitchRow(
          translations["Hide Phone"] ?? "Hide Phone",
          hidePhone,
          (value) {
            setState(() {
              hidePhone = value;
            });
            updatePrivacySettings(hidePhone: value);
          },
        ),
        buildSwitchRow(
          translations["Hide About Me"] ?? "Hide About Me",
          hideAboutMe,
          (value) {
            setState(() {
              hideAboutMe = value;
            });
            updatePrivacySettings(hideAboutMe: value);
          },
        ),
      ],
    );
  }

  Widget buildSwitchRow(
      String label, bool currentValue, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: primaryTextStyle()),
        Switch(
          value: currentValue,
          activeColor: scribblrPrimaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
