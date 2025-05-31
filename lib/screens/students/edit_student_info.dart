import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:scribblr/utils/colors.dart';
import '../../utils/constant.dart';

class EditStudentInfoScreen extends StatefulWidget {
  const EditStudentInfoScreen({Key? key}) : super(key: key);

  @override
  _EditStudentInfoScreenState createState() => _EditStudentInfoScreenState();
}

class _EditStudentInfoScreenState extends State<EditStudentInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController kakaoController = TextEditingController();
  final TextEditingController aboutMeController =
      TextEditingController(); // ✅ NEW "About Me" Field

  // Room dropdown related
  int? selectedRoom;
  List<int> rooms = [1, 2, 3, 4];

  // Image pickers for profile and cover photos
  final ImagePicker _picker = ImagePicker();
  XFile? profileImage;
  XFile? coverImage;
  String? profileImageUrl;
  String? coverImageUrl;

  // User ID
  int userId = 0;

  // Privacy Settings
  bool hideName = false;
  bool hidePhone = false;
  bool hideAboutMe = false;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// **Load user ID from SharedPreferences and Fetch Data**
  Future<void> loadUserData() async {
    try {
      String userData = await getStringAsync("user_data", defaultValue: "");

      if (userData.isNotEmpty) {
        Map<String, dynamic> user = jsonDecode(userData);
        int id = int.parse(user["id"].toString());

        debugPrint("✅ Loaded User ID: $id");

        setState(() {
          userId = id;
        });

        fetchUserDetails(id);
      } else {
        debugPrint("❌ User data is empty!");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading user data: $e");
    }
  }

  /// **Fetch user details from API**
  Future<void> fetchUserDetails(int id) async {
    String userData = await getStringAsync("user_data", defaultValue: "");
    try {
      var url = Uri.parse("$BaseUrl/api/users/$id");
      debugPrint("Fetching from: " + url.toString());
      var response =
          await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          firstNameController.text = data["firstname"] ?? "";
          lastNameController.text = data["lastname"] ?? "";
          phoneController.text = data["phone"] ?? "";
          kakaoController.text = data["kakao"] ?? "";
          aboutMeController.text = data["about_me"] ?? ""; // ✅ Load "About Me"
          profileImageUrl = data["avatar_file_path"];
          coverImageUrl = data["cover_photo"];

          // Handle selected room properly
          selectedRoom =
              (data["room_id"] != null && rooms.contains(data["room_id"]))
                  ? data["room_id"]
                  : null;

          isLoading = false;
        });
      } else {
        debugPrint("Error fetching user details: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  /// **Update User Data**
  Future<void> updateUserData() async {
    if (_formKey.currentState!.validate()) {
      var url = Uri.parse("$BaseUrl/api/users/$userId");

      try {
        var request = http.MultipartRequest("POST", url);

        // **Attach text fields**
        request.fields["firstname"] = firstNameController.text;
        request.fields["lastname"] = lastNameController.text;
        request.fields["phone"] = phoneController.text;
        request.fields["role"] = "admin";
        request.fields["room_id"] = selectedRoom?.toString() ?? "";
        request.fields["kakao"] = kakaoController.text;
        request.fields["about_me"] = aboutMeController.text;

        // **Attach Privacy Settings**

        // **Attach Profile Photo**
        if (profileImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'profile_photo',
            profileImage!.path,
          ));
        }

        // **Attach Cover Photo**
        if (coverImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'cover_photo',
            coverImage!.path,
          ));
        }

        // **Send Request**
        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          toast("User updated successfully!");
          finish(context);
        } else {
          debugPrint(
              "❌ Error updating user: ${response.statusCode} - $responseData");
        }
      } catch (e) {
        debugPrint("❌ Error: $e");
      }
    }
  }

  /// **Cover & Profile Image Section**
  Widget buildCoverProfileSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: pickCoverImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: coverImage != null
                    ? FileImage(File(coverImage!.path))
                    : (coverImageUrl != null
                            ? NetworkImage('$BaseUrl$coverImageUrl')
                            : const AssetImage('assets/default_cover.jpg'))
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
            onTap: pickProfileImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 46,
                backgroundImage: profileImage != null
                    ? FileImage(File(profileImage!.path))
                    : (profileImageUrl != null
                            ? NetworkImage('$BaseUrl$profileImageUrl')
                            : const AssetImage('assets/default_user.png'))
                        as ImageProvider,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Student Information")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  buildCoverProfileSection(),
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTextField(
                              "First Name", firstNameController, true),
                          buildTextField("Last Name", lastNameController, true),
                          buildTextField("Phone", phoneController, true),
                          buildTextField("Kakao ID", kakaoController, true),
                          buildTextField("About Me", aboutMeController,
                              false), // ✅ Added "About Me"
                          buildDropdown("Room", rooms, selectedRoom, (value) {
                            setState(() {
                              selectedRoom = value;
                            });
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: updateUserData,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: scribblrPrimaryColor),
          child: const Text("Save Changes",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, bool required) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        8.height,
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          validator: (value) => required && (value == null || value.isEmpty)
              ? "Please enter $label"
              : null,
        ),
        16.height,
      ],
    );
  }

  /// **Dropdown Builder**
  Widget buildDropdown(String label, List<int> items, int? selectedValue,
      Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      value: (selectedValue != null && items.contains(selectedValue))
          ? selectedValue
          : null,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: items.isNotEmpty
          ? items
              .map((value) =>
                  DropdownMenuItem(value: value, child: Text("Room $value")))
              .toList()
          : [],
      onChanged: items.isNotEmpty ? onChanged : null,
      hint: const Text("Select Room"),
      disabledHint: const Text("No rooms available"),
    );
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      profileImage = image;
    });
  }

  /// **Pick Cover Image**
  Future<void> pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      coverImage = image;
    });
  }
}
