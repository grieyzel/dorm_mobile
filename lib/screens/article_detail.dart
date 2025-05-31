import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/components/text_styles.dart';
import 'package:scribblr/utils/colors.dart';
import '../main.dart';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';
import 'package:scribblr/utils/constant.dart';

class ArticleDetail extends StatefulWidget {
  final ArticleModel articleData;

  ArticleDetail({required this.articleData});

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  int likeCount = 0;
  TextEditingController commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  String currentUserId = "1"; // Change this to actual logged-in user ID
  bool isLoadingTranslation = false;
  String selectedLanguage = "en"; // Default language
  Map<String, String> translations = {};

  @override
  void initState() {
    super.initState();
    fetchComments();
    getUserId();
  }

  Future<void> getUserId() async {
    String? userData = getStringAsync("user_data", defaultValue: "");
    if (userData.isNotEmpty) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        currentUserId = user["id"].toString();
      });
    }
  }

  Future<void> fetchComments() async {
    final String apiUrl =
        '${BaseUrl}/api/events/${widget.articleData.id}/comments';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          comments =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print("Failed to load comments");
      }
    } catch (error) {
      print("Error fetching comments: $error");
    }
  }

  Future<String?> translateText(String text, String targetLanguage) async {
    final String url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse[0][0][0];
      } else {
        print('❌ Translation failed: ${response.body}');
        return text;
      }
    } catch (e) {
      print('❌ Network error: $e');
      return text;
    }
  }

  Future<void> _translateAll() async {
    setState(() {
      isLoadingTranslation = true;
    });

    translations["title"] = await translateText(
            widget.articleData.title.validate(), selectedLanguage) ??
        widget.articleData.title.validate();
    translations["description"] = await translateText(
            widget.articleData.description.validate() ?? "No content available",
            selectedLanguage) ??
        widget.articleData.description.validate();

    for (var comment in comments) {
      String commentText = comment["comment"] ?? "No comment";
      String commentId = comment["id"].toString();
      translations[commentId] =
          await translateText(commentText, selectedLanguage) ?? commentText;
    }

    setState(() {
      isLoadingTranslation = false;
    });
  }

  Future<void> deleteComment(int commentId) async {
    final String apiUrl = '${BaseUrl}/api/events/comments/$commentId';

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        fetchComments(); // Refresh comments after deletion
      } else {
        print(response.body);
        print("Failed to delete comment");
      }
    } catch (error) {
      print("Error deleting comment: $error");
    }
  }

  Future<void> addComment() async {
    if (commentController.text.trim().isEmpty) return;

    final String apiUrl =
        '${BaseUrl}/api/events/${widget.articleData.id}/comments';
    final Map<String, String> commentData = {
      "comment": commentController.text.trim(),
      "created_by": currentUserId
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(commentData),
      );

      if (response.statusCode == 201) {
        commentController.clear();
        fetchComments(); // Refresh comments after posting
      } else {
        debugPrint("Error adding comment: ${response.body}");
      }
    } catch (error) {
      debugPrint("Error adding comment: $error");
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Language"),
          content: SingleChildScrollView(
            child: Column(
              children: languages.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  onTap: () {
                    setState(() {
                      selectedLanguage = entry.value;
                    });
                    _translateAll();
                    Navigator.pop(context);
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
    return Observer(builder: (context) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Article Details"),
            backgroundColor: scribblrPrimaryColor,
            actions: [
              IconButton(
                icon: Icon(Icons.language, color: Colors.white),
                onPressed: _showLanguageDialog,
              ),
            ],
          ),
          body: isLoadingTranslation
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        widget.articleData.imageAsset.validate(),
                        fit: BoxFit.cover,
                        height: context.height() * 0.4,
                        width: context.width(),
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/images/placeholder.jpg",
                            fit: BoxFit.cover,
                            height: context.height() * 0.4,
                            width: context.width(),
                          );
                        },
                      ),
                      10.height,
                      Text(
                        translations["title"] ??
                            widget.articleData.title.validate(),
                        style: primarytextStyle(
                            color: appStore.isDarkMode
                                ? Colors.white
                                : Colors.black),
                      ).paddingSymmetric(horizontal: 16),
                      10.height,
                      Divider(color: dividerDarkColor, thickness: 0.3)
                          .paddingSymmetric(horizontal: 16),
                      10.height,

                      // **Event Poster Information**
                      Row(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(
                                    widget.articleData.authorImage.validate()),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ).paddingSymmetric(horizontal: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.articleData.authorName.validate(),
                                  style: boldTextStyle()),
                              Text(widget.articleData.authorUserName.validate(),
                                  style: secondarytextStyle()),
                            ],
                          ),
                        ],
                      ),
                      Divider(color: dividerDarkColor, thickness: 0.3)
                          .paddingSymmetric(horizontal: 16),
                      10.height,
                      Text(widget.articleData.time.validate(),
                              style: timetextStyle())
                          .paddingOnly(left: 16),
                      10.height,
                      Text(
                        translations["description"] ??
                            widget.articleData.description?.validate() ??
                            "No content available",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            color: appStore.isDarkMode
                                ? Colors.white
                                : Colors.black),
                      ).paddingSymmetric(horizontal: 16),
                      10.height,
                      Divider(color: dividerDarkColor, thickness: 0.3)
                          .paddingSymmetric(horizontal: 16),
                      10.height,

                      // **Comments Section**
                      Text('Comments',
                              style: primarytextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.black))
                          .paddingSymmetric(horizontal: 16),
                      10.height,

                      // **Comment Input Field**
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: scribblrPrimaryColor),
                            onPressed: addComment,
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 8),
                      10.height,

                      // **Display Comments**
                      ...comments.map((comment) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage: comment["avatar_file_path"] !=
                                        null
                                    ? NetworkImage(
                                        '$BaseUrl${comment["avatar_file_path"]}')
                                    : null,
                                backgroundColor:
                                    scribblrPrimaryColor.withOpacity(0.2),
                                radius: 20,
                                child: comment["avatar_file_path"] == null
                                    ? Text(
                                        (comment["firstname"] ?? "U")
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: boldTextStyle(
                                            size: 18,
                                            color: scribblrPrimaryColor),
                                      )
                                    : null,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment["firstname"] ?? "Unknown User",
                                      style: boldTextStyle(),
                                    ),
                                    Text(
                                      translations[comment["id"].toString()] ??
                                          comment[
                                              "comment"], // Correct translation mapping
                                      style: primarytextStyle(),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      formatTime(comment["created_at"]),
                                      style: secondarytextStyle(size: 10),
                                    ),
                                  ],
                                ),
                              ),
                              if (comment["created_by"].toString() ==
                                  currentUserId)
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteComment(comment["id"]),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      40.height,
                    ],
                  ),
                ));
    });
  }

  String formatTime(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp).toLocal();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute}";
  }
}
