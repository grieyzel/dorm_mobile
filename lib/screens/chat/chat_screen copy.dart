import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:scribblr/screens/chat/message_screen/message_screen.dart';
import 'package:scribblr/screens/chat/message_screen/group_chat_message.dart';
import 'package:scribblr/utils/colors.dart';
import '../../../utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/constant.dart';

class Message extends StatefulWidget {
  Message({Key? key}) : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  TextEditingController searchController = TextEditingController();
  int selectedTab = 0; // 0 for Chats, 1 for Group
  String searchQuery = "";
  List<Map<String, dynamic>> privateChats = [];
  List<Map<String, dynamic>> groupChats = [];
  List<Map<String, dynamic>> pendingGroupInvites = [];
  List<Map<String, dynamic>> availableGroups = [];
  List<Map<String, dynamic>> joinRequestGroups = [];
  bool isLoading = true;
  String userId = "";
  String userRole = "";

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
        userId = user["id"].toString();
        userRole = user["role"] ?? "";
      });
      fetchUserChats();
    }
  }

  void _showAddGroupDialog() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create Group Chat"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Group Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createGroupChat(nameController.text.trim());
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }

  Future<void> _createGroupChat(String name) async {
    if (name.isEmpty) {
      toast("Group name cannot be empty");
      return;
    }

    final url = Uri.parse('$BaseUrl/api/group-chats');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "type": "group",
        }),
      );

      if (response.statusCode == 201) {
        toast("✅ Group created successfully");
        fetchUserChats(); // Refresh chat list
      } else {
        final error = jsonDecode(response.body);
        toast(error['message'] ?? "Failed to create group");
      }
    } catch (e) {
      toast("Error: $e");
    }
  }

  Future<void> fetchUserChats() async {
    final String groupChatUrl = '$BaseUrl/api/users/$userId/group-chats';
    final String privateChatUrl = '$BaseUrl/api/user-chats/$userId';

    try {
      final groupChatResponse = await http.get(Uri.parse(groupChatUrl));
      final privateChatResponse = await http.get(Uri.parse(privateChatUrl));

      debugPrint(privateChatUrl);
      debugPrint(privateChatResponse.body);

      if (groupChatResponse.statusCode == 200 &&
          privateChatResponse.statusCode == 200) {
        final groupData = json.decode(groupChatResponse.body);
        final privateData = json.decode(privateChatResponse.body);

        final List<Map<String, dynamic>> filteredPrivateChats = [];

        for (var chat in privateData['chats']) {
          final dynamic user1 = chat['user1'];
          final dynamic user2 = chat['user2'];

          Map<String, dynamic>? otherUser;

          // Determine which one is the other user
          if (user1 != null && user1['id'].toString() == userId) {
            otherUser = user2 != null ? Map<String, dynamic>.from(user2) : null;
          } else if (user2 != null && user2['id'].toString() == userId) {
            otherUser = user1 != null ? Map<String, dynamic>.from(user1) : null;
          } else {
            // Placeholder chat - assign whichever user is present
            if (user1 != null && user1['id'].toString() != userId) {
              otherUser = Map<String, dynamic>.from(user1);
            } else if (user2 != null && user2['id'].toString() != userId) {
              otherUser = Map<String, dynamic>.from(user2);
            }
          }

          // Filter out if the otherUser is null or an admin
          if (otherUser == null || otherUser['role'] == 'A') continue;

          filteredPrivateChats.add(Map<String, dynamic>.from(chat));
        }

        setState(() {
          groupChats =
              List<Map<String, dynamic>>.from(groupData['joined_groups']);
          pendingGroupInvites =
              List<Map<String, dynamic>>.from(groupData['pending_invites']);
          availableGroups =
              List<Map<String, dynamic>>.from(groupData['available_groups']);
          joinRequestGroups =
              List<Map<String, dynamic>>.from(groupData['join_requests']);
          privateChats = filteredPrivateChats;
          isLoading = false;
        });
      } else {
        toast("Failed to load chats");
      }
    } catch (e) {
      debugPrint("ERROR in fetchUserChats: $e");
      toast("Error fetching chats: $e");
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> joinGroup(int chatId) async {
    final url = Uri.parse('$BaseUrl/api/group-chats/$chatId/invite');

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": int.parse(userId),
          "status": "join",
        }),
      );

      if (res.statusCode == 200) {
        toast("✅ Successfully joined the group");
        fetchUserChats(); // Refresh the UI
      } else {
        toast("❌ Failed to join group");
      }
    } catch (e) {
      toast("Error: $e");
    }
  }

  List<Map<String, dynamic>> getFilteredChats() {
    if (searchQuery.isEmpty) return privateChats;
    return privateChats.where((chat) {
      final user1 = chat['user1'];
      final user2 = chat['user2'];

      final isUser1Current = user1['id'].toString() == userId;
      final otherUser = isUser1Current ? user2 : user1;

      final fullName =
          '${otherUser['firstname']} ${otherUser['lastname']}'.toLowerCase();

      return searchQuery.isEmpty ||
          fullName.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> deleteGroupChat(int chatId) async {
    final url = Uri.parse('$BaseUrl/api/group-chat/$chatId');
    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        toast("✅ Group chat deleted successfully");
        fetchUserChats();
      } else {
        final errorBody = jsonDecode(response.body);
        debugPrint('Delete Group Chat Error Response: ${response.body}');
        toast(errorBody['message'] ??
            "Failed to delete group chat (Server Error)");
      }
    } catch (e) {
      debugPrint('Delete Group Chat Exception: $e');
      toast("Error occurred: $e");
    }
  }

  List<Map<String, dynamic>> getFilteredGroups() {
    // if (searchQuery.isEmpty) return groupChats;
    // return groupChats
    //     .where((group) => (group['name'] ?? '')
    //         .toLowerCase()
    //         .contains(searchQuery.toLowerCase()))
    //     .toList();
    return groupChats;
  }

  Future<void> respondToGroupInvite(int chatId, String response) async {
    final url = Uri.parse('$BaseUrl/api/group-chats/$chatId/respond');

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": int.parse(userId),
          "response": response,
        }),
      );

      if (res.statusCode == 200) {
        toast("✅ You have $response the invite.");
        fetchUserChats(); // Refresh the list
      } else {
        toast("❌ Failed to respond");
      }
    } catch (e) {
      toast("Error: $e");
    }
  }

  Widget buildTabButton(
      String text, int tabIndex, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tabIndex;
        });
      },
      child: Container(
        height: screenHeight * 0.055,
        width: screenWidth * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              selectedTab == tabIndex ? scribblrPrimaryColor : Colors.grey[300],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selectedTab == tabIndex ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChatList(double screenWidth) {
    List<Map<String, dynamic>> filteredChats = getFilteredChats();
    return filteredChats.isEmpty
        ? Center(child: Text("No chats available"))
        : ListView.builder(
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              final user1 = chat['user1'];
              final user2 = chat['user2'];

              final isUser1Current = user1['id'].toString() == userId;
              final otherUser = isUser1Current ? user2 : user1;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        userID: otherUser["id"],
                        chatName:
                            "${otherUser["firstname"]} ${otherUser["middlename"] ?? ""} ${otherUser["lastname"]}"
                                .trim(),
                        imagePath: otherUser["avatar_file_path"] != null
                            ? "$BaseUrl${otherUser['avatar_file_path']}"
                            : "assets/authors/authChris.jpg",
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: buildUserAvatar(otherUser),
                  title: Text(
                    "${otherUser['firstname']} ${otherUser['lastname']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    "Unread Messages: ${chat['unread_messages']}",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                  ),
                ).paddingSymmetric(vertical: 0, horizontal: screenWidth * 0.02),
              );
            },
          );
  }

  Widget buildGroupChatList() {
    List<Map<String, dynamic>> filteredGroups = getFilteredGroups();

    // Combine into unified list
    final List<Map<String, dynamic>> combinedList = [
      if (availableGroups.isNotEmpty)
        {'type': 'header', 'label': 'Available Groups'},
      ...availableGroups.map((group) => {'type': 'available', 'data': group}),
      if (filteredGroups.isNotEmpty) {'type': 'header', 'label': 'Group Chats'},
      ...filteredGroups.map((group) => {'type': 'joined', 'data': group}),
      if (pendingGroupInvites.isNotEmpty)
        {'type': 'header', 'label': 'Pending Invitations'},
      ...pendingGroupInvites
          .map((invite) => {'type': 'pending', 'data': invite}),
      if (joinRequestGroups.isNotEmpty)
        {'type': 'header', 'label': 'Join Requests'},
      ...joinRequestGroups
          .map((invite) => {'type': 'join_request', 'data': invite}),
    ];

    return ListView.builder(
      itemCount: combinedList.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> item = combinedList[index];
        final String type = item['type'];

        if (type == 'header') {
          final String label = item['label'] as String;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        }

        if (type == 'joined') {
          final Map<String, dynamic> group =
              item['data'] as Map<String, dynamic>;
          final String groupName = group['name'] ?? 'Unnamed Group';
          final String initial =
              groupName.isNotEmpty ? groupName[0].toUpperCase() : '?';

          return ListTile(
            leading: CircleAvatar(child: Text(initial)),
            title: Text(groupName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (userRole != "S")
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Group Chat"),
                            content: Text(
                                "Are you sure you want to delete this group chat?"),
                            actions: [
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  deleteGroupChat(group['id']);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChatMessageScreen(
                    chatId: group['id'],
                    groupName: groupName,
                  ),
                ),
              );
            },
          );
        }

        if (type == 'available') {
          final Map<String, dynamic> group = item['data'];
          final String groupName = group['name'] ?? 'Unnamed Group';
          final String initial =
              groupName.isNotEmpty ? groupName[0].toUpperCase() : '?';

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text(initial)),
              title: Text(groupName),
              subtitle: Text("You are not part of this group"),
              trailing: ElevatedButton(
                onPressed: () => joinGroup(group['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scribblrPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text("Join"),
              ),
            ),
          );
        }

        if (type == 'pending') {
          final Map<String, dynamic> invite =
              item['data'] as Map<String, dynamic>;
          final Map<String, dynamic> group =
              invite['chat'] as Map<String, dynamic>;
          final String groupName = group['name'] ?? 'Pending Group';
          final String initial =
              groupName.isNotEmpty ? groupName[0].toUpperCase() : '?';

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text(initial)),
              title: Text(groupName),
              subtitle: Text("Invitation pending..."),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    tooltip: "Accept",
                    onPressed: () =>
                        respondToGroupInvite(group['id'], "accepted"),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    tooltip: "Decline",
                    onPressed: () =>
                        respondToGroupInvite(group['id'], "declined"),
                  ),
                ],
              ),
            ),
          );
        }
        if (type == 'join_request') {
          final Map<String, dynamic> invite =
              item['data'] as Map<String, dynamic>;
          final Map<String, dynamic> group =
              invite['chat'] as Map<String, dynamic>;
          final String groupName = group['name'] ?? 'Join Request';
          final String initial =
              groupName.isNotEmpty ? groupName[0].toUpperCase() : '?';

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text(initial)),
              title: Text(groupName),
              subtitle: Text("Join request sent..."),
              trailing: Icon(Icons.hourglass_top, color: Colors.orange),
            ),
          );
        }

        return SizedBox.shrink(); // fallback
      },
    );
  }

  Widget buildUserAvatar(Map<String, dynamic> user) {
    if (user['avatar_file_path'] != null &&
        user['avatar_file_path'].isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage('$BaseUrl${user['avatar_file_path']}'),
        radius: 25,
      );
    } else {
      String initials = user['firstname'][0].toUpperCase();
      return CircleAvatar(
        radius: 25,
        backgroundColor: scribblrPrimaryColor,
        child: Text(
          initials,
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search chats...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTabButton("Chats (${getFilteredChats().length})", 0,
                  screenWidth, screenHeight),
              SizedBox(width: screenWidth * 0.04),
              buildTabButton("Groups (${getFilteredGroups().length})", 1,
                  screenWidth, screenHeight),
            ],
          ).paddingAll(screenHeight * 0.02),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : selectedTab == 0
                    ? buildChatList(screenWidth)
                    : buildGroupChatList(),
          ),
        ],
      ).paddingSymmetric(horizontal: screenHeight * 0.01),
      floatingActionButton: selectedTab == 1 && userRole != "S"
          ? FloatingActionButton(
              onPressed: _showAddGroupDialog,
              backgroundColor: scribblrPrimaryColor,
              child: Icon(Icons.group_add),
            )
          : null,
    );
  }
}
