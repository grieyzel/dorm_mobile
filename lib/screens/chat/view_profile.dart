import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:scribblr/utils/colors.dart';
import '../../utils/constant.dart';

class ViewProfileScreen extends StatefulWidget {
  final int userId;
  const ViewProfileScreen({super.key, required this.userId});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  String firstName = "";
  String lastName = "";
  String phone = "";
  String kakao = "";
  String? avatarFilePath;
  String? coverFilePath;
  int roomId = 0;
  String aboutMe = "";
  bool hideAboutMe = false;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails(widget.userId);
  }

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
          phone = data["phone"] ?? "";
          kakao = data["kakao"] ?? "";
          avatarFilePath = data["avatar_file_path"];
          coverFilePath = data["cover_photo"];
          roomId = data["room_id"] ?? 0;
          aboutMe = data["about_me"] ?? "";
          hideAboutMe = data["privacy_settings"]["hide_about_me"] ?? false;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scribblrPrimaryColor,
        title: Text('View Profile', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Divider buildDivider() =>
      Divider(thickness: 0.5, color: Colors.grey.shade400);

  Widget buildCoverProfileSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: coverFilePath != null
                  ? NetworkImage('$BaseUrl$coverFilePath')
                  : AssetImage('assets/default_cover.jpg') as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 46,
              backgroundImage: avatarFilePath != null
                  ? NetworkImage('$BaseUrl$avatarFilePath')
                  : AssetImage('assets/default_user.png') as ImageProvider,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProfileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$firstName $lastName", style: boldTextStyle(size: 20)),
            5.height,
            Text("@$kakao", style: secondaryTextStyle()),
            5.height,
            Text(
              phone == "hidden" ? "Phone: *hidden*" : "Phone: $phone",
              style: phone == "hidden"
                  ? secondaryTextStyle().copyWith(fontStyle: FontStyle.italic)
                  : secondaryTextStyle(),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Personal Information", style: boldTextStyle(size: 18)),
        10.height,
        buildInfoRow("Room Number", roomId.toString()),
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

  Widget buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("About Me", style: boldTextStyle(size: 18)),
        10.height,
        Text(
          aboutMe == "hidden" ? "*This user's about me is hidden.*" : aboutMe,
          style: aboutMe == "hidden"
              ? secondaryTextStyle().copyWith(fontStyle: FontStyle.italic)
              : secondaryTextStyle(),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
