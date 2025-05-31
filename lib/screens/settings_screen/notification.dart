import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/text_styles.dart';
import '../../main.dart';
import 'package:scribblr/utils/constant.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response =
          await http.get(Uri.parse("$BaseUrl/api/notifications/1"));

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
              ? Center(
                  child:
                      CircularProgressIndicator()) // ✅ Show loading indicator
              : notifications.isEmpty
                  ? Center(
                      child: Text(
                          "No notifications available")) // ✅ Handle empty notifications
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
                        );
                      },
                    ),
        );
      },
    );
  }
}
