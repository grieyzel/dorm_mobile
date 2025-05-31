import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scribblr/screens/create_article.dart';
import 'package:scribblr/screens/students/student_list.dart';
import 'package:scribblr/screens/dashboard/notification_screen.dart';
import 'package:scribblr/screens/dashboard/settings_screen.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/utils/images.dart';

import 'package:scribblr/screens/chat/chat_screen.dart';

import '../../components/text_styles.dart';
import '../../main.dart';
import '../fragments/home_fragment.dart';
import '../fragments/profile_fragment.dart';
import '../../../utils/constant.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentPageIndex = 0;
  String selectedLanguage = "en";

  List<String> title = [
    'Home',
    'Students',
    'Create Announcement/Event',
    'Messages',
    'Profile'
  ];
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('language') ?? "en";

    setState(() {
      selectedLanguage = savedLanguage;
      screens = [
        HomeFragment(key: UniqueKey()),
        StudentListScreen(key: UniqueKey()),
        CreateBulletinScreen(key: UniqueKey()),
        Message(),
        ProfileFragment(key: UniqueKey()),
      ];
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
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString('language', entry.value);

                    setState(() {
                      selectedLanguage = entry.value;
                      screens = [
                        HomeFragment(key: UniqueKey()),
                        StudentListScreen(
                            key: UniqueKey()), // Refresh StudentListScreen
                        CreateBulletinScreen(),
                        Message(),
                        ProfileFragment(key: UniqueKey()),
                      ];
                    });

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
          surfaceTintColor: appStore.isDarkMode
              ? scaffoldDarkColor
              : context.scaffoldBackgroundColor,
          backgroundColor: appStore.isDarkMode
              ? scaffoldDarkColor
              : context.scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            title[currentPageIndex],
            style: primarytextStyle(
                color: appStore.isDarkMode
                    ? scaffoldLightColor
                    : scaffoldDarkColor),
          ),
          leading: Image.asset(app_icon),
          actions: [
            SvgPicture.asset(notification_icon,
                    color: appStore.isDarkMode
                        ? scaffoldLightColor
                        : scaffoldDarkColor,
                    width: 30,
                    height: 30)
                .onTap(() {
              NotificationSettings(
                onGoToMessages: () {
                  setState(() {
                    currentPageIndex = 3; // Navigate to Message screen
                  });
                },
              ).launch(context);
            }),
            16.width,
            SvgPicture.asset(settings_icon,
                    color: appStore.isDarkMode
                        ? scaffoldLightColor
                        : scaffoldDarkColor,
                    width: 30,
                    height: 30)
                .onTap(() {
              SettingsScreen().launch(context);
            }),
            IconButton(
              icon: Icon(Icons.language, color: Colors.black),
              onPressed: _showLanguageDialog,
            ),
          ],
        ),
        body: screens[currentPageIndex],
        bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentPageIndex,
              onTap: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              unselectedItemColor:
                  appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor,
              selectedItemColor: scribblrPrimaryColor,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              iconSize: 24,
              backgroundColor: Colors.white,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Ionicons.home_outline,
                    color: appStore.isDarkMode
                        ? scaffoldLightColor
                        : scaffoldDarkColor,
                  ),
                  activeIcon: Icon(Ionicons.home, color: scribblrPrimaryColor),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Ionicons.compass_outline,
                    color: appStore.isDarkMode
                        ? scaffoldLightColor
                        : scaffoldDarkColor,
                  ),
                  activeIcon: Icon(Ionicons.people_circle_sharp,
                      color: scribblrPrimaryColor),
                  label: 'Students',
                ),
                BottomNavigationBarItem(
                  icon: Container(),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Ionicons.chatbox_outline,
                    color: appStore.isDarkMode
                        ? scaffoldLightColor
                        : scaffoldDarkColor,
                  ),
                  activeIcon:
                      Icon(Ionicons.chatbox, color: scribblrPrimaryColor),
                  label: 'Message',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Ionicons.person_outline,
                    color: appStore.isDarkMode
                        ? scaffoldLightColor
                        : scaffoldDarkColor,
                  ),
                  activeIcon:
                      Icon(Ionicons.person, color: scribblrPrimaryColor),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Transform.translate(
          offset: Offset(0, 25),
          child: FloatingActionButton(
            onPressed: () {
              CreateBulletinScreen();
            },
            backgroundColor: scribblrPrimaryColor,
            child: Icon(
              Ionicons.add,
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    });
  }
}
