import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:scribblr/components/text_styles.dart';
import 'package:scribblr/screens/auth/sign_in.dart';
import 'package:scribblr/screens/settings_screen/contact.dart';
import 'package:scribblr/screens/settings_screen/docu_list.dart';
import 'package:scribblr/screens/settings_screen/faq.dart';
import 'package:scribblr/screens/settings_screen/explore.dart';
import 'package:scribblr/screens/settings_screen/lunar.dart';
import '../main.dart';
import '../screens/settings_screen/about_us.dart';
import '../screens/settings_screen/dorm_rules.dart';

import '../utils/colors.dart';

class SettingsComponent extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final String text;
  final bool showSwitch;
  final Widget? screen;

  final void Function(BuildContext)? onTap;

  SettingsComponent({
    required this.icon,
    required this.text,
    this.color,
    this.onTap,
    this.showSwitch = false,
    this.screen,
  });

  @override
  State<SettingsComponent> createState() => _SettingsComponentState();
}

class _SettingsComponentState extends State<SettingsComponent> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return GestureDetector(
        onTap: () => widget.onTap!(context),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: skipbutton),
                  child: Icon(widget.icon, color: widget.color),
                ),
                16.width,
                Text(
                  widget.text,
                  style: secondarytextStyle(
                      color: appStore.isDarkMode ? Colors.white : Colors.black),
                ).expand(),
                if (widget.showSwitch)
                  Switch(
                    value: appStore.isDarkMode,
                    onChanged: (value) {
                      appStore.setDarkMode(value);
                    },
                  ).onTap(() {
                    if (widget.screen != null) {
                      widget.screen!.launch(context);
                    }
                  }),
              ],
            ),
            10.height,
          ],
        ),
      );
    });
  }
}

List<Widget> settingComponent(BuildContext context) => [
      SettingsComponent(
          icon: Icons.info,
          color: scribblrPrimaryColor,
          text: 'Rules and Regulations',
          onTap: (context) {
            DormRulesScreen().launch(context);
          }),
      SettingsComponent(
          icon: Icons.info_outline_rounded,
          color: scribblrPrimaryColor,
          text: 'Laundry Cafe',
          onTap: (context) {
            LaundryScreen().launch(context);
          }),
      SettingsComponent(
          icon: Icons.question_mark_rounded,
          color: scribblrPrimaryColor,
          text: 'FAQ',
          onTap: (context) {
            FAQScreen().launch(context);
          }),
      SettingsComponent(
          icon: Icons.compass_calibration_rounded,
          color: scribblrPrimaryColor,
          text: 'Exploring Asan',
          onTap: (context) {
            ExploreAsanScreen().launch(context);
          }),
      SettingsComponent(
          icon: Icons.phone,
          color: scribblrPrimaryColor,
          text: 'Contacts',
          onTap: (context) {
            ContactScreen().launch(context);
          }),
      SettingsComponent(
          icon: Icons.file_download,
          color: scribblrPrimaryColor,
          text: 'Documentation Repository',
          onTap: (context) {
            DocumentListScreen().launch(context);
          }),
      SettingsComponent(
        icon: Icons.logout_rounded,
        color: Colors.red,
        text: 'Logout',
        onTap: (context) async {
          await removeKey("user_data"); // Clears stored user data
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
            (route) => false, // Removes all previous routes
          );
        },
      ),
    ];
