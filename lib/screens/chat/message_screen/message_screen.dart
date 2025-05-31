import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scribblr/components/appscaffold.dart';
import 'package:scribblr/main.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/constant.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final int userID;
  final String imagePath;
  final String chatName;

  ChatScreen({
    Key? key,
    required this.userID,
    required this.imagePath,
    required this.chatName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? chatId;
  List<Map<String, dynamic>> messages = [];
  Map<String, String> translations = {}; // Store translated messages
  bool isLoading = true;
  bool isTranslating = false;
  String selectedLanguage = "en";
  String? userId;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    String? userData = getStringAsync("user_data", defaultValue: "");
    if (userData.isNotEmpty) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        userId = user["id"]?.toString() ?? "0"; // Ensuring userId is never null
      });
      fetchChat();
      _startAutoFetch();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoFetch() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchChat();
    });
  }

  Future<void> fetchChat() async {
    final String apiUrl = '$BaseUrl/api/chats';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"user_1": userId, "user_2": widget.userID, "type": "private"}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        setState(() {
          chatId = data["chat"]["id"];
          messages = List<Map<String, dynamic>>.from(data["messages"]);
          isLoading = false;
        });
        _scrollToBottom();
      } else {
        print("Failed to fetch chat data: ${response.body}");
      }
    } catch (e) {
      print("Error fetching chat: $e");
    }
  }

  Future<void> sendMessage() async {
    if (_textController.text.trim().isEmpty || chatId == null) return;

    final String apiUrl = '$BaseUrl/api/messages';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chat_id": chatId,
          "user_id": userId,
          "message": _textController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        var newMessage = jsonDecode(response.body)["data"];
        setState(() {
          messages.add(newMessage);
        });

        _textController.clear();
        _scrollToBottom();
      } else {
        print("Failed to send message: ${response.body}");
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// **Translate Text Using Google Translate API**
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

  /// **Translate All Messages**
  Future<void> _translateAll() async {
    setState(() {
      isTranslating = true;
    });

    for (var message in messages) {
      String messageText = message["message"];
      String messageId = message["id"].toString();
      translations[messageId] =
          await translateText(messageText, selectedLanguage) ?? messageText;
    }

    setState(() {
      isTranslating = false;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName, style: TextStyle(color: Colors.white)),
        backgroundColor: scribblrPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.white),
            onPressed: _showLanguageDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(
                        child: Text("No messages yet. Start a conversation!"))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var message = messages[index];
                          bool isSender =
                              message["user_id"].toString() == userId;
                          return _buildMessage(message, isSender);
                        },
                      ),
          ),
          _buildTextField(),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message, bool isSender) {
    final double screenWidth = MediaQuery.of(context).size.width;
    String messageId = message["id"].toString();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isSender ? scribblrPrimaryColor : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  translations[messageId] ?? message["message"],
                  style: primaryTextStyle(
                    color: isSender ? Colors.white : Colors.black,
                    size: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(formatTime(message["created_at"]),
                    style: secondaryTextStyle(size: 12, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(String createdAt) {
    try {
      DateTime dateTime =
          DateTime.parse(createdAt).toLocal(); // Convert to local timezone
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Unknown"; // Fallback if date is invalid
    }
  }

  Widget _buildTextField() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Type your message...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: scribblrPrimaryColor),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
