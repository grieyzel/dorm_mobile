import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scribblr/utils/colors.dart';

import 'package:scribblr/screens/chat/view_profile.dart';
import '../../../utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:async';

class GroupChatMessageScreen extends StatefulWidget {
  final int chatId;
  final String groupName;

  GroupChatMessageScreen({required this.chatId, required this.groupName});

  @override
  _GroupChatMessageScreenState createState() => _GroupChatMessageScreenState();
}

class _GroupChatMessageScreenState extends State<GroupChatMessageScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  Map<String, String> translations = {}; // Store translated messages
  bool isLoading = true;
  bool isTranslating = false;
  String selectedLanguage = "en";
  String userId = "";
  Timer? _timer;
  final TextEditingController _userToAddController = TextEditingController();
  String userRole = "";
  List<Map<String, dynamic>> groupMembers = [];
  List<Map<String, dynamic>> searchResults = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchGroupMessages();
    getUserId();
  }

  Future<void> getUserId() async {
    String? userData = getStringAsync("user_data", defaultValue: "");
    if (userData.isNotEmpty) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        userId = user["id"].toString();
        userRole = user["role"] ?? "";
      });
      fetchGroupMessages();
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
      fetchGroupMessages();
    });
  }

  Future<void> addUserToGroup(
      String userIdToAdd, VoidCallback refreshDialog) async {
    final url = Uri.parse('$BaseUrl/api/group-chats/${widget.chatId}/add-user');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userIdToAdd}),
      );

      if (response.statusCode == 200) {
        toast("✅ User added to group");
        await fetchGroupMembers(); // <--- await here
        refreshDialog(); // <--- triggers dialog UI update
      } else {
        final error = jsonDecode(response.body);
        debugPrint("API Error: $error");
        toast(error['message'] ?? "Failed to add user");
      }
    } catch (e) {
      debugPrint("HTTP Exception: $e");
      toast("Connection error: $e");
    }
  }

  Future<void> removeUserFromGroup(
      String userIdToRemove, VoidCallback refreshDialog) async {
    final url =
        Uri.parse('$BaseUrl/api/group-chats/${widget.chatId}/remove-user');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userIdToRemove}),
      );

      if (response.statusCode == 200) {
        toast("❌ User removed");
        await fetchGroupMembers(); // <--- await here
        refreshDialog(); // <--- triggers dialog UI update
      } else {
        toast("Failed to remove user");
      }
    } catch (e) {
      toast("Error: $e");
    }
  }

  void showManageUsersDialog() {
    fetchGroupMembers();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Manage Group Users"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) async {
                      await searchUsersByName(value);
                      setStateDialog(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Search users...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (searchResults.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: searchResults.map((user) {
                        return ListTile(
                          title:
                              Text("${user['firstname']} ${user['lastname']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.person_add),
                            onPressed: () {
                              addUserToGroup(user['id'].toString(),
                                  () => setStateDialog(() {}));
                              _searchController.clear();
                              setStateDialog(() {
                                searchResults = [];
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  Divider(),
                  Text("Group Members",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ...groupMembers.map((member) {
                    return ListTile(
                      leading: buildUserAvatar(context, member),
                      title:
                          Text("${member['firstname']} ${member['lastname']}"),
                      trailing: member['id'].toString() != '1'
                          ? IconButton(
                              icon:
                                  Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => removeUserFromGroup(
                                  member['id'].toString(),
                                  () => setStateDialog(() {})),
                            )
                          : null,
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildUserAvatar(BuildContext context, Map<String, dynamic> user) {
    String? avatarPath = user['avatar_file_path'];
    String name = "${user['firstname'] ?? ''} ${user['lastname'] ?? ''}".trim();
    String initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    int? userId = user['id'];

    return GestureDetector(
      onTap: () {
        if (userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfileScreen(userId: userId),
            ),
          );
        }
      },
      child: avatarPath != null && avatarPath.isNotEmpty
          ? CircleAvatar(
              backgroundImage: NetworkImage('$BaseUrl$avatarPath'),
              radius: 16,
            )
          : CircleAvatar(
              radius: 16,
              backgroundColor: scribblrPrimaryColor,
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Future<void> fetchGroupMessages() async {
    final String apiUrl = '$BaseUrl/api/group_chat/${widget.chatId}/messages';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          messages = List<Map<String, dynamic>>.from(jsonResponse['messages']);
          isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }
  }

  Future<void> sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final String apiUrl = '$BaseUrl/api/messages';
    final String messageText = _textController.text.trim();

    _textController.clear();
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chat_id": widget.chatId,
          "user_id": userId,
          "message": messageText,
        }),
      );

      if (response.statusCode == 201) {
        var newMessage = jsonDecode(response.body)["data"];
        setState(() {
          messages.add(newMessage);
        });
        _scrollToBottom();
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

  Future<String?> translateText(String text, String targetLanguage) async {
    final String url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse[0][0][0];
      }
    } catch (e) {
      print('Translation error: $e');
    }
    return text;
  }

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

  Future<void> fetchGroupMembers() async {
    final url = Uri.parse('$BaseUrl/api/group-chats/${widget.chatId}/members');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          groupMembers = List<Map<String, dynamic>>.from(
              jsonDecode(response.body)['members']);
        });
      }
    } catch (e) {
      toast("Failed to fetch group members");
    }
  }

  Future<void> searchUsersByName(String query) async {
    if (query.isEmpty) return;
    final url = Uri.parse(
        '$BaseUrl/api/search-users?query=$query&chat_id=${widget.chatId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          searchResults = List<Map<String, dynamic>>.from(
              jsonDecode(response.body)['results']);
        });
      }
    } catch (e) {
      toast("Failed to search users");
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: TextStyle(color: Colors.white)),
        backgroundColor: scribblrPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.white),
            onPressed: _showLanguageDialog,
          ),
          if (userRole != "S")
            IconButton(
              icon: Icon(Icons.group_add, color: Colors.white),
              onPressed: showManageUsersDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      bool isMe = message["user_id"].toString() == userId;
                      String messageId = message["id"].toString();
                      return _buildMessage(message, isMe, messageId);
                    },
                  ),
          ),
          _buildTextField(),
        ],
      ),
    );
  }

  Widget _buildMessage(
      Map<String, dynamic> message, bool isMe, String messageId) {
    final user = message['user'];
    final avatarPath = user?['avatar_file_path'];
    final fullName =
        "${user?['firstname'] ?? ''} ${user?['lastname'] ?? ''}".trim();
    final initials = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    if (user != null && user['id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewProfileScreen(userId: user['id']),
                        ),
                      );
                    }
                  },
                  child: avatarPath != null && avatarPath.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage('$BaseUrl$avatarPath'),
                          radius: 16,
                        )
                      : CircleAvatar(
                          radius: 16,
                          backgroundColor: scribblrPrimaryColor,
                          child: Text(
                            initials,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    fullName.isNotEmpty ? fullName : "Unknown User",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ? scribblrPrimaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    translations[messageId] ?? message["message"],
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// **Builds the message input field**
  Widget _buildTextField() {
    return StatefulBuilder(
      builder: (context, setStateInput) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: scribblrPrimaryColor),
                onPressed: () {
                  sendMessage();
                  setStateInput(() {}); // Forces rebuild of only this widget
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
