import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:scribblr/screens/announcement/announcement_list.dart';
import 'dart:convert';
import '../../utils/constant.dart';
import '../../utils/colors.dart';
import '../../components/article_widget.dart';
import '../../models/article_model.dart';
import '../../screens/events/event_list.dart';
import '../../screens/bus/bus_list.dart';
import '../../screens/kitchen/kitchen_usage.dart';
import '../../screens/translation.dart';
import '../../main.dart';
import 'package:scribblr/screens/settings_screen/dorm_rules.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({Key? key}) : super(key: key); // Accept key

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  String userRole = "";
  List<ArticleResponse> eventArticles = [];
  List<Map<String, dynamic>> bulletins = [];
  bool isLoading = true;
  bool hasError = false;
  bool isBulletinLoading = true;
  bool bulletinHasError = false;
  String? userId;
  String selectedLanguage = 'en';
  Map<String, String> translations = {};
  Map<String, String> text = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _translateAll();
    getUserRole();
    fetchEvents();
    fetchBulletins();
    getUserId();
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

  Future<void> getUserId() async {
    String? userData = getStringAsync("user_data", defaultValue: "");

    if (userData.isNotEmpty) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        userId = user["id"].toString(); // Store user ID
        debugPrint("WOOOOOOWW ${userId}");
      });
    }
  }

  /// **Fetch User Role**
  Future<void> getUserRole() async {
    String? userData = getStringAsync("user_data", defaultValue: "");
    if (userData.isNotEmpty) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        userRole = user["role"] ?? "";
      });
    }
  }

  /// **Delete Bulletin**
  Future<void> deleteBulletin(String bulletinId) async {
    try {
      final response =
          await http.delete(Uri.parse('$BaseUrl/api/bulletins/$bulletinId'));

      debugPrint("'$BaseUrl/api/bulletins/$bulletinId'");

      if (response.statusCode == 200) {
        toast("Bulletin deleted successfully");
        fetchBulletins(); // Refresh bulletins after deletion
      } else {
        debugPrint("Error: ${response.body}");
        toast("Failed to delete bulletin");
      }
    } catch (e) {
      debugPrint("Error: ${e}");
      toast("Error deleting bulletin");
    }
  }

  Future<void> fetchBulletins() async {
    if (!mounted) return;

    setState(() {
      isBulletinLoading = true;
      bulletinHasError = false;
    });

    try {
      final response = await http.get(Uri.parse('$BaseUrl/api/bulletins'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        List<Map<String, dynamic>> fetchedBulletins = data.map((bulletin) {
          return {
            "id": bulletin["id"] ?? "Unknown",
            "user_name": bulletin["user_name"] ?? "Unknown",
            "user_avatar": bulletin["user_avatar"] != null
                ? '$BaseUrl${bulletin["user_avatar"]}'
                : null,
            "description": bulletin["description"] ?? "No Description",
            "image": bulletin["photo_path"] != null
                ? '$BaseUrl${bulletin["photo_path"]}'
                : null,
            "created_by": bulletin["created_by"],
            "created_at": bulletin["created_at"] ?? "Unknown Date",
          };
        }).toList();

        setState(() {
          bulletins = fetchedBulletins;
          isBulletinLoading = false;
        });

        _translateBulletins(fetchedBulletins);
      } else {
        setState(() {
          bulletinHasError = true;
          isBulletinLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        bulletinHasError = true;
        isBulletinLoading = false;
      });
    }
  }

  /// **Translate all bulletin descriptions in one request**
  Future<void> _translateBulletins(
      List<Map<String, dynamic>> fetchedBulletins) async {
    if (fetchedBulletins.isEmpty) return;

    setState(() {
      isBulletinLoading = true;
    });

    // Collect all non-null descriptions for translation
    List<String> texts = fetchedBulletins
        .map((b) => b["description"] as String?)
        .where((desc) => desc != null && desc.isNotEmpty)
        .cast<String>()
        .toList();

    if (texts.isEmpty) {
      setState(() {
        isBulletinLoading = false;
      });
      return;
    }

    // Join texts for single translation request
    String textToTranslate = texts.join(" || ");
    String? translatedText =
        await translateText(textToTranslate, selectedLanguage);

    if (translatedText != null) {
      List<String> translatedParts = translatedText.split(" || ");

      setState(() {
        for (int i = 0; i < texts.length; i++) {
          translations[texts[i]] =
              translatedParts.length > i ? translatedParts[i] : texts[i];
        }
        isBulletinLoading = false;
      });
    } else {
      setState(() {
        isBulletinLoading = false;
      });
    }
  }

  /// **Fetch Events from API**
  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse('$BaseUrl/api/events'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isEmpty) {
          setState(() {
            eventArticles = [];
            isLoading = false;
          });
          return;
        }

        // Extract titles for translation
        List<String> titles = data
            .map((event) => event["title"] as String?)
            .where((title) => title != null && title.isNotEmpty)
            .cast<String>()
            .toList();

        // If no titles need translation, update `eventArticles` immediately
        if (titles.isEmpty) {
          setState(() {
            eventArticles = [
              ArticleResponse(
                title: translations["Announcements"] ?? "Announcements",
                articleList: data.map((event) {
                  return ArticleModel(
                    id: event["id"],
                    title: event["title"] ?? "Untitled Event",
                    description: event["description"] ?? "No Description",
                    imageAsset: event["photo_path"] != null
                        ? '$BaseUrl${event["photo_path"]}'
                        : "assets/images/placeholder.jpg",
                    authorName: "Admin",
                    authorImage: "assets/default_user.png",
                    time: "Just now",
                  );
                }).toList(),
              )
            ];
            isLoading = false;
          });
          return;
        }

        // **Translate titles in one request**
        String textToTranslate = titles.join(" || ");
        String? translatedText =
            await translateText(textToTranslate, selectedLanguage);

        if (translatedText != null) {
          List<String> translatedParts = translatedText.split(" || ");

          // **Create new eventArticles with translated titles**
          List<ArticleResponse> translatedEvents = [
            ArticleResponse(
              title: translations["Announcements"] ?? "Announcements",
              articleList: data.map((event) {
                int index = titles.indexOf(event["title"]);
                return ArticleModel(
                  id: event["id"],
                  title: index != -1
                      ? translatedParts[index]
                      : event["title"] ?? "Untitled Event",
                  description: event["description"] ?? "No Description",
                  imageAsset: event["photo_path"] != null
                      ? '$BaseUrl${event["photo_path"]}'
                      : "assets/images/placeholder.jpg",
                  authorName: "Admin",
                  authorImage: "assets/default_user.png",
                  time: "Just now",
                );
              }).toList(),
            )
          ];

          setState(() {
            eventArticles = translatedEvents;
            isLoading = false;
          });
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
    if (!mounted) return; // Prevent setState if widget is disposed

    setState(() {
      isLoading = true;
    });

    List<String> texts = [
      "Know more about our Campus!",
      "Read More",
      "Announcements",
      "Bus",
      "Kitchen",
      "Events",
      "Translate",
      "Bulletin Board",
      "Failed to load events. Try again later.",
      "No events available.",
      "Failed to load bulletins. Try again later.",
      "No bulletins available.",
    ];

    for (var bulletin in bulletins) {
      if (bulletin["description"] != null &&
          bulletin["description"]!.isNotEmpty) {
        texts.add(bulletin["description"]!);
      }
    }

    for (var event in eventArticles) {
      for (var article in event.articleList ?? []) {
        if (article.description?.isNotEmpty ?? false) {
          texts.add(article.description!);
        }
      }
    }

    String textToTranslate = texts.join(" || ");
    String? translatedText =
        await translateText(textToTranslate, selectedLanguage);

    if (!mounted) return; // Prevent setState if widget is disposed

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

  Widget buildBulletinCard(Map<String, dynamic> bulletin) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **User Info Section**
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: bulletin["user_avatar"] != null
                      ? NetworkImage(bulletin["user_avatar"])
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  radius: 22,
                  child: bulletin["user_avatar"] == null
                      ? Text(
                          bulletin["user_name"][0].toUpperCase(),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bulletin["user_name"], style: boldTextStyle(size: 16)),
                    Text(
                      formatTime(bulletin["created_at"]),
                      style: secondaryTextStyle(size: 12),
                    ),
                  ],
                ),

                // **Delete Button (If User Owns the Bulletin)**
                if (bulletin["created_by"] == userId) Spacer(),
                if (bulletin["created_by"] == userId)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteBulletin(bulletin["id"].toString()),
                  ),
              ],
            ),

            SizedBox(height: 10),

            // **Bulletin Description (Translated)**
            Text(
              translations[bulletin["description"]] ?? bulletin["description"],
              style: primaryTextStyle(size: 14),
            ),

            SizedBox(height: 10),

            // **Bulletin Image (If Available)**
            if (bulletin["image"] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(bulletin["image"], fit: BoxFit.cover),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 145,
                  width: context.width() - 32,
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.height,
                      Text(
                        translations['Know more about our Campus!'] ??
                            'Know more about our Campus!',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      15.height,
                      ElevatedButton(
                        onPressed: () {
                          DormRulesScreen().launch(context);
                        },
                        child: Text(translations['Read More'] ?? 'Read more'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            15.height,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildShortcutButton(
                      icon: Ionicons.megaphone_sharp,
                      label: translations["Announcements"] ?? "Announcement",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EventListScreen()));
                      }),
                  buildShortcutButton(
                      icon: Ionicons.bus_sharp,
                      label: translations["Bus"] ?? "Bus",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BusStationListScreen()));
                      }),
                  buildShortcutButton(
                      icon: Ionicons.restaurant_sharp,
                      label: translations["Kitchen"] ?? "Kitchen",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => KitchenUsageScreen()));
                      }),
                  if (userRole != "S")
                    buildShortcutButton(
                        icon: Ionicons.calendar_sharp,
                        label: translations["Events"] ?? "Events",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AnnouncementListScreen()));
                        }),
                  buildShortcutButton(
                      icon: Ionicons.text_sharp,
                      label: translations["Translate"] ?? "Translate",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TranslationScreen()));
                      }),
                ],
              ),
            ),

            15.height,

            // **Event Articles Section**
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (hasError)
              Center(child: Text("Failed to load events. Try again later."))
            else if (eventArticles.isNotEmpty)
              ...eventArticles
                  .map((e) => ArticleWidget(articleResponseData: e))
                  .toList()
            else
              Center(child: Text("No events available.")),

            15.height,

            // **Bulletins Section (Facebook Feed Style)**
            Text(translations["Bulletin Board"] ?? "Bulletin Board",
                    style: boldTextStyle(size: 18, color: Colors.black))
                .paddingSymmetric(horizontal: 16),
            10.height,

            if (isBulletinLoading)
              Center(child: CircularProgressIndicator())
            else if (bulletinHasError)
              Center(child: Text("Failed to load bulletins. Try again later."))
            else if (bulletins.isNotEmpty)
              ...bulletins.map((b) => buildBulletinCard(b)).toList()
            else
              Center(child: Text("No new posts.")),
          ],
        ),
      );
    });
  }

  /// **Format Time Function**
  String formatTime(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp).toLocal();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute}";
  }

  Widget buildShortcutButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 24, color: Colors.black),
            ),
            5.height,
            Text(label, style: secondaryTextStyle(size: 14)),
          ],
        ),
      ),
    );
  }
}
