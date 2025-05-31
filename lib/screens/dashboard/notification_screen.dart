import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/text_styles.dart';
import '../../main.dart';
import 'package:scribblr/utils/constant.dart';

class NotificationSettings extends StatefulWidget {
  final VoidCallback? onGoToMessages;

  const NotificationSettings({super.key, this.onGoToMessages});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchNotifications();
  }

  Future<void> loadUserDataAndFetchNotifications() async {
    try {
      final userDataString = getStringAsync('user_data');
      final userData = jsonDecode(userDataString);
      userId = userData['id'];

      await fetchNotifications();
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchNotifications() async {
    if (userId == null) return;

    try {
      final response =
          await http.get(Uri.parse("$BaseUrl/api/notifications/$userId"));

      if (response.statusCode == 200) {
        setState(() {
          notifications = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load notifications");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: appStore.isDarkMode
                ? scaffoldDarkColor
                : context.scaffoldBackgroundColor,
            iconTheme: IconThemeData(
                color: appStore.isDarkMode ? Colors.white : Colors.black),
            title: Text(
              'Notifications',
              style: primarytextStyle(
                  color: appStore.isDarkMode ? Colors.white : Colors.black),
            ),
            backgroundColor: appStore.isDarkMode
                ? scaffoldDarkColor
                : context.scaffoldBackgroundColor,
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : notifications.isEmpty
                  ? Center(child: Text("No notifications available"))
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        var notification = notifications[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            onTap: () {
                              if (notification["title"]
                                          .toString()
                                          .toLowerCase() ==
                                      "group" &&
                                  widget.onGoToMessages != null) {
                                widget.onGoToMessages!();
                                finish(context); // Close the screen
                              }
                            },
                            child: ListTile(
                              title: Text(
                                notification["title"],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(notification["message"]),
                              trailing: Icon(
                                notification["is_read"] == 1
                                    ? Icons.check_circle
                                    : Icons.notifications,
                                color: notification["is_read"] == 1
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
