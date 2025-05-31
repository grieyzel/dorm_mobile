import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/utils/constant.dart';

class DormRulesScreen extends StatefulWidget {
  @override
  _DormRulesScreenState createState() => _DormRulesScreenState();
}

class _DormRulesScreenState extends State<DormRulesScreen> {
  String selectedLanguage = "en";
  Map<String, String> translatedRules = {};
  bool isTranslating = false;
  List<String> translatedSectionTitles = [];

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

  Future<void> translateAllRules(String languageCode) async {
    setState(() {
      isTranslating = true;
    });

    Map<String, String> updatedRules = {};
    List<String> newSectionTitles = [];

    List<MapEntry<String, String>> entries = dormRules.entries.toList();
    List<String> originalSectionTitles =
        entries.where((e) => _isSectionTitle(e.key)).map((e) => e.key).toList();

    int currentSectionStart = 0;

    while (currentSectionStart < entries.length) {
      int nextSectionStart = currentSectionStart + 1;

      while (nextSectionStart < entries.length &&
          !_isSectionTitle(entries[nextSectionStart].key)) {
        nextSectionStart++;
      }

      List<MapEntry<String, String>> sectionEntries =
          entries.sublist(currentSectionStart, nextSectionStart);

      List<String> keyValuePairs =
          sectionEntries.map((e) => "${e.key}@@${e.value}").toList();

      String? translated =
          await translateText(keyValuePairs.join(" || "), languageCode);

      if (translated != null) {
        List<String> translatedPairs = translated.split(" || ");
        for (int i = 0;
            i < translatedPairs.length && i < sectionEntries.length;
            i++) {
          final parts = translatedPairs[i].split("@@");
          if (parts.length == 2) {
            String translatedKey = parts[0].trim();
            String translatedValue = parts[1].trim();
            updatedRules[translatedKey] = translatedValue;

            if (_isSectionTitle(sectionEntries[i].key)) {
              newSectionTitles.add(translatedKey);
            }
          }
        }
      }

      currentSectionStart = nextSectionStart;
    }

    setState(() {
      translatedRules = updatedRules;
      translatedSectionTitles = newSectionTitles;
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
                    translateAllRules(entry.value);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  final Map<String, String> dormRules = {
    // Section 1
    "1. General Rules":
        "Guidelines for dormitory residents covering entry, curfew, inspections, and checkouts.",

    "Entry and Exit":
        "All individuals must use facial ID recognition to enter and exit the gates. To ensure smooth access, please register your facial data and personal information at the Administrative Office located on the 4th floor between Dormitories 103 and 104 before the semester begins.\n"
            "An NFC ID card may be available upon request, but it will only be issued based on specific circumstances.",

    "Curfew":
        "The curfew time has been changed from 11 PM to 12 AM. Doors will close at 12 AM and reopen at 5 AM. If you find yourself locked out, please call the contact number posted at the entrance for assistance.",

    "Room Inspections":
        "Regular inspections will be conducted according to a predetermined schedule for each building. These inspections will assess the cleanliness and organization of rooms. Ensure that both the bathroom and balcony are well-maintained and in proper order at all times.",

    "Weekday Checkouts":
        "Weekday outings must be approved by the dormitory manager at least one day in advance and reported upon your return. The process may vary depending on your building, so please confirm the specific procedure with your respective dorm manager.",

    "Withdrawal":
        "To withdraw from the dormitory, submit a completed application form after consulting with the dorm manager at least three days prior. Please note that dormitory fees are non-refundable.",

    // Section 2
    "2. Utilization of Facilities":
        "Rules for using dormitory amenities, ensuring responsible and respectful usage.",

    "Door Passcodes":
        "Ensure you are familiar with both the automatic and manual operation of your room door. Regularly update your password for security. The dormitory is not responsible for any lost or stolen items.",

    "Noise":
        "Please avoid using your phone, speaking loudly, or operating devices with high volumes late at night (after 24:00), as it may disturb others and disrupt their sleep. Be considerate of those around you.",

    "Bathroom Use":
        "Please clean up after yourself to ensure the bathroom is ready for the next user. Flush the toilet and verify that it is clean. Wipe any water off the mirror after use. Dispose of trash properly, and be responsible when using the power outlets in the bathroom.",

    "Trash Segregation":
        "Please ensure proper waste segregation by using the designated bins in your dormitory. Follow the guidelines responsibly to maintain cleanliness and order.",

    "Refrigerators":
        "Please use the refrigerators responsibly. Dorm managers reserve the right to discard any rotten, expired, or prohibited items. Storing kimchi or foods with strong odors is not allowed and will be disposed of if found. Ensure that you provide a designated box for your perishable items, clearly labeled with your name and room number.",

    "Common Areas":
        "Please do not leave any items outside your room door; all belongings left in this area will be confiscated. Additionally, refrain from leaving personal items in communal spaces.",

    "Dorm Property":
        "Hanging items with nails on the walls is prohibited. Likewise, sticking anything that may damage the wallpaper is not allowed.",

    "Delivery":
        "Important mail can be collected from the Dorm Administration office by presenting your ID. General packages can be retrieved from the designated delivery area (located below Dorm 104, Smile Box). The dormitory is not responsible for lost mail or packages. For any issues, please contact the delivery drivers directly.",

    "Computer Room":
        "The communal computers are available for everyone’s use. Please refrain from bringing food or beverages into the room. Use the computers responsibly. Downloading or accessing illegal websites is strictly prohibited and may result in legal consequences.",

    "Dining Room":
        "Access is permitted only during dormitory operating hours (5 AM - 12 AM). Please clean up after yourself. Exercise caution when using the microwave; limit usage to 2-minute and 30-second intervals to prevent fire hazards. Ensure that the air conditioning is turned off after use if no one is in the room.",

    "Study Room":
        "The study room is accessible 24 hours a day. Please do not leave your belongings to reserve a spot; take your items with you when you leave. Dorm managers may remove unattended items, which can be retrieved from the office. Remember to turn off the lights, air conditioning, and heater when not in use. If you use the TV, please be mindful of the volume to avoid disturbing others.",

    "Seminar Room":
        "If you wish to use the seminar room, please notify the dorm office at least three days in advance to obtain approval.",

    "Before Leaving the Room":
        "Before leaving the room, please unplug all power outlets and ensure that the lights, air conditioning, and boiler are turned off.",

    // Section 3
    "3. Precautions":
        "Important safety guidelines and fire response procedures.",
    "a. Initial Fire Response Tips":
        "✓ Notify individuals inside by ringing the bell or shouting.\n"
            "✓ Provide details when calling emergency services: building, room, situation.\n"
            "✓ Report to Fire Dept: Address (OO Building), Nearby Landmarks, Type of Fire.\n"
            "✓ Turn off electricity and gas if safe.\n"
            "✓ Use fire extinguishers or hydrants if manageable.\n"
            "✓ Inform firefighters of layout, injuries, or hazardous materials.\n"
            "✓ If fire spreads, close door and evacuate immediately.",

    "b. Fire Evacuation Instructions":
        "- Evacuate and alert others immediately.\n"
            "- Close emergency doors to delay fire/smoke.\n"
            "- Use wet towels or cloth to shield from burns.\n"
            "- Use stairs, crouch low, take short breaths.\n"
            "- Don’t open hot doors; seek alternate route.\n"
            "- Never use elevators during a fire.\n"
            "- If trapped, go to rooftop and signal for rescue.\n"
            "- Block smoke with wet items and lie low.\n"
            "- Spray water on flammables to delay fire.",

    "c. How to Use a Fire Extinguisher":
        "1. Grab and approach the fire calmly.\n"
            "2. Pull the safety pin.\n"
            "3. Aim nozzle at base of flames.\n"
            "4. Squeeze handle and sweep side to side.",

    "d. Fire Extinguisher Maintenance Tips": "- Store in visible, dry areas.\n"
        "- Avoid direct sunlight and moisture.\n"
        "- Inspect monthly, shake to avoid clumping.\n"
        "- Ensure pressure gauge is in green.\n"
        "- Keep accessible where hazards exist.",

    "e. First Aid for Burns": "1. Cool area with water or saline.\n"
        "2. Do not peel stuck clothing—cut around it.\n"
        "3. Cover burn with sterile gauze.\n"
        "4. Keep the person warm to avoid shock.",

    "f. Specific First Aid Methods": "- If clothing is on fire: stop, drop, roll.\n"
        "- Soak burns until heat subsides.\n"
        ">> 1st & 2nd Degree: Don’t pop blisters; disinfect, apply ointment.\n"
        ">> 3rd Degree: Protect from infection and shock. Use clean saline cloth. Do not tear burnt clothes.",

    "ii. Common Areas (Precautions)":
        "Avoid leaving laundry racks or luggage in hallways.",
    "iii. Personal Belongings":
        "Respect others’ items. Turn in lost items to dorm office.",

    // Section 4
    "4. Prohibited Activities":
        "Engaging in prohibited activities may result in immediate removal from the premises.",
    "i. Violence": "Any abusive or violent behavior is unacceptable.",
    "ii. Theft": "Stealing or possession of stolen items is prohibited.",
    "iii. Alcohol and Drugs":
        "Consumption of alcohol or possession of illegal substances is forbidden.",
    "iv. Hazardous Items":
        "Bringing electric heaters or flammable substances into the dormitory is prohibited.",
    "v. Cooking":
        "Cooking in rooms and using rice cookers is prohibited due to fire hazards.",
    "vi. Gambling": "Any form of gambling is strictly prohibited.",
    "vii. Smoking": "Smoking indoors is not allowed.",
    "viii. Restricted Areas":
        "Unauthorized entry into gender-restricted areas is not allowed.",
    "ix. Property Damage":
        "Unauthorized movement or damage to dormitory property is prohibited.",
    "x. Unauthorized Materials":
        "Attaching promotional materials, distributing handouts, or hanging posters without permission is not allowed.",
    "xi. Disobedience":
        "Failure to comply with dorm supervisors or instructors is prohibited.",

    // Section 5
    "5. Reward and Punishment":
        "Rewards and consequences for following or violating dormitory rules.",
    "i. Clean Room Reward":
        "The cleanest room will receive special coupons as a cleanliness incentive.",
    "ii. Demerit Points":
        "Rule violations result in demerits. Accumulated points may lead to expulsion or disqualification from future application.",
    "iii. Serious Violations":
        "Serious cases may lead to legal action including court proceedings or deportation, depending on severity.",
  };

  bool _isSectionTitle(String title) {
    if (translatedRules.isNotEmpty) {
      return translatedSectionTitles.contains(title);
    } else {
      return RegExp(r'^\d+\.\s').hasMatch(title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rules = translatedRules.isNotEmpty ? translatedRules : dormRules;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dorm Rules & Regulations"),
        backgroundColor: scribblrPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: selectLanguage,
            tooltip: "Change Language",
          ),
        ],
      ),
      body: isTranslating
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rules.entries.map((entry) {
                  if (_isSectionTitle(entry.key)) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: scribblrPrimaryColor,
                        ),
                      ),
                    );
                  } else {
                    return _buildRuleItem(
                      title: entry.key,
                      content: entry.value,
                    );
                  }
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildRuleItem({required String title, required String content}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(content,
                style: TextStyle(fontSize: 16, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
