import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/utils/constant.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String selectedLanguage = "en";
  bool isLoading = false;
  Map<String, String> translations = {};

  Future<String?> translateText(String text, String targetLanguage) async {
    final String url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse[0][0][0];
      } else {
        return text;
      }
    } catch (e) {
      return text;
    }
  }

  Future<void> _translateAll([String? language]) async {
    if (language != null) {
      setState(() {
        selectedLanguage = language;
        isLoading = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }

    List<String> texts = [
      "Contact Information",
      "Dorm Manager",
      "Dorm Administrative Office",
      "Kakao Channel",
      "Sun Moon University Dorm Website",
      "Contact Number",
      "Dormitory Management",
      "Business Registration Number",
      "Representative",
      "Phone",
      "Email",
      "Address",
      "Fire Department",
      "Hospitals",
      "Emergency Numbers",
      "Police Stations",
      "Asan Fire Station",
      "Cheonandongnam Fire Station",
      "Cheonanseobuk Fire Station",
      "Tangjeong 119 Safety Center",
      "Cheonandongnam Fire Station",
      "Cheonanseobuk Fire Station",
      "Tangjeong 119 Safety Center",
      "Asan Chungmu Hospital",
      "Cheonan Chungmu Hospital",
      "Cheonan Medical Center",
      "Soonchunhyang University Cheonan Hospital",
      "Cheonan Chungmu Hospital",
      "Cheonan Medical Center",
      "Soonchunhyang University Cheonan Hospital",
      "Emergency (119)",
      "National Disaster & Safety Portal",
      "Asan Patrol Division",
      "Tangjeong Police Substation",
      "Cheonan Police Station",
      "Cheonan Police Station (2)"
    ];

    for (String text in texts) {
      String? translated = await translateText(text, selectedLanguage);
      translations[text] = translated ?? text;
    }

    setState(() {
      isLoading = false;
    });
  }

  void initState() {
    super.initState();
    _translateAll();
  }

  void selectLanguage() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  onTap: () {
                    Navigator.pop(context);
                    _translateAll(entry.value);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _openURL(String url) async {
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        backgroundColor: scribblrPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: selectLanguage, // Open language selection dialog
            tooltip: "Change Language",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildSectionTitle(
                    translations["Dorm Manager"] ?? "Dorm Manager"),
                _buildSubSectionTitle(
                    translations["Dorm Administrative Office"] ??
                        "Dorm Administrative Office"),
                _buildClickableItem(
                    translations["Kakao Channel"] ?? "Kakao Channel",
                    "https://pf.kakao.com/_fekTK",
                    Icons.link,
                    () => _openURL("https://pf.kakao.com/_fekTK")),
                _buildClickableItem(
                    translations["Sun Moon University Dorm Website"] ??
                        "Sun Moon University Dorm Website",
                    "https://dorm.sunmoon.ac.kr/",
                    Icons.public,
                    () => _openURL("https://dorm.sunmoon.ac.kr/")),
                _buildClickableItem(
                    translations["Contact Number"] ?? "Contact Number",
                    "041-530-8505",
                    Icons.phone,
                    () => _callNumber("0415308505")),
                _buildSubSectionTitle(translations["Dormitory Management"] ??
                    "Dormitory Management"),
                _buildInfoItem(
                    translations["Business Registration Number"] ??
                        "Business Registration Number",
                    "312-82-03075"),
                _buildInfoItem(
                    translations["Representative"] ?? "Representative",
                    "Moon Seong-Je"),
                _buildClickableItem(
                    translations["Phone"] ?? "Phone",
                    "041-530-8505",
                    Icons.phone,
                    () => _callNumber("0415308505")),
                _buildClickableItem(
                    translations["Email"] ?? "Email",
                    "smur@sunmoon.ac.kr",
                    Icons.email,
                    () => _openURL("mailto:smur@sunmoon.ac.kr")),
                _buildInfoItem(translations["Address"] ?? "Address",
                    "(31460) 70, Seonmun-ro 221beon-gil, Tangjeong-myeon, Asan-si, Chungcheongnam-do, Seonmun University Seonghwa Dormitory"),
                _buildSectionTitle(
                    translations["Fire Department"] ?? "Fire Department"),
                _buildClickableItem(
                  translations["Asan Fire Station"] ?? "Asan Fire Station",
                  "041-538-0201",
                  Icons.local_fire_department,
                  () => _callNumber("0415380201"),
                ),
                _buildClickableItem(
                  translations["Cheonandongnam Fire Station"] ??
                      "Cheonandongnam Fire Station",
                  "041-570-0201",
                  Icons.local_fire_department,
                  () => _callNumber("0415700201"),
                ),
                _buildClickableItem(
                  translations["Cheonanseobuk Fire Station"] ??
                      "Cheonanseobuk Fire Station",
                  "041-360-0200",
                  Icons.local_fire_department,
                  () => _callNumber("0413600200"),
                ),
                _buildClickableItem(
                  translations["Tangjeong 119 Safety Center"] ??
                      "Tangjeong 119 Safety Center",
                  "041-538-0442",
                  Icons.local_fire_department,
                  () => _callNumber("0415380442"),
                ),
                _buildSectionTitle(translations["Hospitals"] ?? "Hospitals"),
                _buildClickableItem(
                  translations["Asan Chungmu Hospital"] ??
                      "Asan Chungmu Hospital",
                  "Tel: 041-536-6666\nAddress: 381 Munhwa-ro, Asan-si, Chungcheongnam-do, Republic of Korea",
                  Icons.local_hospital,
                  () => _callNumber("0415366666"),
                ),
                _buildClickableItem(
                  translations["Cheonan Chungmu Hospital"] ??
                      "Cheonan Chungmu Hospital",
                  "Tel: 041-570-7555\nAddress: 8 Dagamal 3-gil, Seobuk-gu, Cheonan-si, Chungcheongnam-do, Republic of Korea",
                  Icons.local_hospital,
                  () => _callNumber("0415707555"),
                ),
                _buildClickableItem(
                  translations["Cheonan Medical Center"] ??
                      "Cheonan Medical Center",
                  "Tel: 041-570-7200\nAddress: 537 Chungjeol-ro, Dongnam-gu, Cheonan-si, Chungcheongnam-do, Republic of Korea",
                  Icons.local_hospital,
                  () => _callNumber("0415707200"),
                ),
                _buildClickableItem(
                  translations["Soonchunhyang University Cheonan Hospital"] ??
                      "Soonchunhyang University Cheonan Hospital",
                  "Tel: 041-570-2114\nAddress: 31 Suncheonhyang 6-gil, Dongnam-gu, Cheonan-si, Chungcheongnam-do, Republic of Korea",
                  Icons.local_hospital,
                  () => _callNumber("0415702114"),
                ),
                _buildSectionTitle(
                    translations["Emergency Numbers"] ?? "Emergency Numbers"),
                _buildClickableItem(
                    translations["Emergency (119)"] ?? "Emergency (119)",
                    "119",
                    Icons.warning,
                    () => _callNumber("119")),
                _buildSectionTitle(
                    translations["Police Stations"] ?? "Police Stations"),
                _buildClickableItem(
                  translations["Tangjeong Police Substation"] ??
                      "Tangjeong Police Substation",
                  "Tel: 041-538-0847\nAddress: 7, Tangjeong-ro 23beon-gil, Tangjeong-myeon, Asan-si, Chungcheongnam-do, Republic of Korea",
                  Icons.local_police,
                  () => _callNumber("0415380847"),
                ),
                _buildClickableItem(
                  translations["Cheonan Police Station (Dongnam)"] ??
                      "Cheonan Police Station (Dongnam)",
                  "Tel: 041-590-2324\nAddress: 73 Cheongsu6-ro, Dongnam-gu, Cheonan-si, Chungcheongnam-do, Republic of Korea",
                  Icons.local_police,
                  () => _callNumber("0415902324"),
                ),
                _buildClickableItem(
                  translations["Cheonan Police Station (Seobuk)"] ??
                      "Cheonan Police Station (Seobuk)",
                  "Tel: 041-536-1224\nAddress: 705 Beonyeong-ro, Seobuk-gu, Cheonan-si, Chungcheongnam-do, Republic of Korea",
                  Icons.local_police,
                  () => _callNumber("0415361224"),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  Widget _buildClickableItem(
      String title, String value, IconData icon, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: scribblrPrimaryColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: TextStyle(color: Colors.blue)),
      onTap: onTap,
    );
  }
}
