import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scribblr/utils/constant.dart';

import 'package:scribblr/utils/colors.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String selectedLanguage = "en";
  bool isTranslating = false;
  List<Map<String, String>> faqList = [
    {
      "question": "What are the dormitory rules and curfew hours?",
      "answer":
          "The dormitory is closed from 12:00 AM to 5:00 AM. Please plan your activities accordingly."
    },
    {
      "question": "How do I report maintenance issues?",
      "answer":
          "Log into your student account on the dormitory website to submit a maintenance request, or contact the administrative office directly for urgent concerns."
    },
    {
      "question": "How do I pay my dormitory fees, and what is included?",
      "answer":
          "Dormitory fees must be paid at the beginning of the semester during the dorm application process. Fees typically include room charges but exclude meals."
    },
    {
      "question": "How do I enter the dormitory?",
      "answer":
          "You must register your Face ID at the start of the semester. The dormitory administration will announce the Face ID registration schedule—please keep an eye out for updates."
    },
    {
      "question": "Can I request a room or roommate change?",
      "answer":
          "Room or roommate changes are generally not permitted once assignments have been made. Students are expected to remain in their assigned rooms until the end of the semester."
    },
    {
      "question": "How do I receive mail and packages?",
      "answer":
          "Use the following address format for deliveries:\nKorean Address:\n(31460) 충청남도 아산시 탕정면 선문로 221번길 70 \uc120문대학교 성화학숙 애국관 (INSERT DORM BUILDING NUMBER HERE)동\nEnglish Address:\n(31460) 70 Sunmoon University, Seonghwasuk Hall, (INSERT DORM BUILDING NUMBER HERE)-dong\nSunmoon-ro 221beon-gil, Tangjeong-myeon, Asan-si, Chungcheongnam-do, South Korea\n\nBe sure to include your dorm building number for accurate delivery."
    },
    {
      "question": "Are meals provided in the dormitory?",
      "answer":
          "Meals are not automatically provided. Students must sign up and pay for a meal plan separately at the beginning of the semester."
    },
  ];

  List<Map<String, String>> translatedFAQList = [];

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

  Future<void> translateFAQs(String languageCode) async {
    setState(() => isTranslating = true);

    List<String> chunks =
        faqList.map((faq) => "${faq['question']}@@${faq['answer']}").toList();
    String joined = chunks.join(" || ");

    String? translated = await translateText(joined, languageCode);

    if (translated != null) {
      List<String> translatedChunks = translated.split(" || ");
      translatedFAQList = translatedChunks.map((chunk) {
        List<String> parts = chunk.split("@@");
        return {
          "question": parts.length > 0 ? parts[0].trim() : "",
          "answer": parts.length > 1 ? parts[1].trim() : "",
        };
      }).toList();
    }

    setState(() {
      selectedLanguage = languageCode;
      isTranslating = false;
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
                    translateFAQs(entry.value);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs =
        translatedFAQList.isNotEmpty ? translatedFAQList : faqList;

    return Scaffold(
      appBar: AppBar(
        title: Text("FAQ"),
        backgroundColor: scribblrPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: selectLanguage, // Open language selection dialog
            tooltip: "Change Language",
          ),
        ],
      ),
      body: isTranslating
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final item = faqs[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    title: Text(
                      item['question'] ?? '',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(item['answer'] ?? '',
                            style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
