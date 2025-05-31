import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scribblr/utils/constant.dart';
import 'package:scribblr/utils/colors.dart';

class ExploreAsanScreen extends StatefulWidget {
  @override
  _ExploreAsanScreenState createState() => _ExploreAsanScreenState();
}

class _ExploreAsanScreenState extends State<ExploreAsanScreen> {
  String selectedLanguage = 'en';
  bool isLoading = false;
  String translatedAsan = '';
  String translatedSunmoon = '';

  final String exploringAsan = '''Asan, South Korea
Asan, located in South Chungcheong Province of South Korea, is a city rich in history and cultural heritage. It has deep historical roots, dating back to the Three Kingdoms period, with significant archaeological sites and ancient landmarks. Historically, Asan was known for its natural hot springs, particularly the Onyang Hot Springs, which have been used for therapeutic purposes for centuries.

Asan also holds a key place in Korean history due to its association with Admiral Yi Sun-sin, the legendary naval commander during the Joseon Dynasty, who is honored at the Hyeonchungsa Shrine. This shrine is a testament to the city's role in preserving Korea’s historical memory and national pride.

Culturally, Asan is a blend of modernity and tradition. The city celebrates its local heritage through annual festivals, such as the Asan Oyster Festival, showcasing the region's seafood culture. The city also embraces contemporary development, offering modern shopping malls, entertainment options, and cafes, while still maintaining a deep connection to its historical roots and natural beauty.

Asan is known for its balance between relaxation and activity, with scenic views, hiking opportunities, and local cultural sites that make it a popular destination for both locals and visitors. The city's natural surroundings, including its picturesque parks, mountains, and tidal flats, further contribute to its significance as a place of tranquility and exploration.

Key Attractions and Landmarks
1. Onyang Hot Springs: The oldest hot spring in Korea, operating for about 600 years. It's known for healing properties and its high temperature of 57℃.
Address: Oncheon-dong, Asan-si, Chungcheongnam-do

2. Hyeonchungsa Shrine: The shrine of Admiral Yi Sun-sin, containing historical artifacts and his home.
Address: 126, Hyeonchungsa-gil, Asan-si, Chungcheongnam-do

3. Gongseri Catholic Church: Built in 1894, this was the first Catholic Church in the province.
Address: 10, Gongseriseongdang-gil, Inju-myeon, Asan-si, Chungcheongnam-do

4. Asan Gingko Tree Road: A scenic tree-lined road known for golden leaves in autumn.
Address: 259-2 Baekam-ri, Yeomchi-eup, Asan-si, Chungcheongnam-do''';

  final String aboutSunmoon = '''About Sun Moon University
Sun Moon University celebrated its 50th anniversary in 2022. The university continues to grow under the founding principles of Love Heaven, Love Humankind, and Love your Country.

With around 10,000 students and 500 faculty members across 8 colleges, 38 departments, and 3 graduate schools, Sun Moon is a major academic institution. The Asan campus provides cutting-edge facilities, including modern classrooms and spacious dormitories.

The university is deeply engaged in global education, with 154 partner universities in 45 countries, and over 1,600 international students from 78 countries. A unique global vice-president system operates in 45 countries, and over 500 students are sent abroad each year for exchange programs.

With strong industry-university collaboration and support from the FFWPU Foundation, Sun Moon University is a leader in education, employment outcomes, and peace-oriented research and development.

Virtual Tour: https://www.sunmoon.ac.kr/360vr/''';

  Future<String?> translateText(String text, String targetLanguage) async {
    final String url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse[0].map((e) => e[0]).join();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> translateBothSections(String lang) async {
    setState(() => isLoading = true);
    final results = await Future.wait([
      translateText(exploringAsan, lang),
      translateText(aboutSunmoon, lang),
    ]);

    setState(() {
      translatedAsan = results[0] ?? exploringAsan;
      translatedSunmoon = results[1] ?? aboutSunmoon;
      isLoading = false;
      selectedLanguage = lang;
    });
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
                    translateBothSections(entry.value);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget buildCard(String title, String body, {IconData? icon}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Row(
                children: [
                  Icon(icon, color: scribblrPrimaryColor),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scribblrPrimaryColor),
                  ),
                ],
              )
            else
              Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scribblrPrimaryColor),
              ),
            SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asanText = translatedAsan.isNotEmpty ? translatedAsan : exploringAsan;
    final sunmoonText =
        translatedSunmoon.isNotEmpty ? translatedSunmoon : aboutSunmoon;

    return Scaffold(
      appBar: AppBar(
        title: Text("Exploring Asan"),
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
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  buildCard("Exploring Asan", asanText, icon: Icons.map),
                  buildCard("About Sun Moon University", sunmoonText,
                      icon: Icons.school),
                  GestureDetector(
                    onTap: () => launchUrl(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "🎥 Visit Sun Moon VR Tour",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  void launchUrl() {
    // In production, use `url_launcher` to open link
    print("Open https://www.sunmoon.ac.kr/360vr/");
  }
}
