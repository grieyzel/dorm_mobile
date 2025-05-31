import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:scribblr/utils/colors.dart';
import 'package:scribblr/utils/constant.dart';

class LaundryScreen extends StatefulWidget {
  @override
  _LaundryScreenState createState() => _LaundryScreenState();
}

class _LaundryScreenState extends State<LaundryScreen> {
  String selectedLanguage = "en";
  bool isLoading = false;
  Map<String, String> translations = {};

  Future<String?> translateText(String text, String targetLanguage) async {
    final String url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse[0][0][0];
      } else {
        return text;
      }
    } catch (e) {
      return text;
    }
  }

  Future<void> _translateAll([String? language]) async {
    if (language != null) {
      setState(() {
        selectedLanguage = language;
        isLoading = true;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }

    List<String> texts = [
      "Laundry Cafe",
      "How to Use the Laundry Room with the Meta Club App",
      "Download and Open the Meta Club App: Ensure the app is installed on your phone and log in with your account.",
      "Add Funds: Top up your account through bank transfer or by visiting a convenience store.",
      "Navigate to Laundry: From the home screen, tap on the Laundry option.",
      "Choose a Laundry Room: Select the laundry room closest to you or the one you’re using from the available options.",
      "Connect to the Equipment: Tap on the machine you want to use (washer or dryer), and sync your phone with the equipment via the app.",
      "Start Laundry: Once connected, simply tap Start to begin your laundry cycle.",
      "Monitor Progress: You can check the status of your laundry directly in the app.",
      "Note: The washing machine automatically adds laundry detergent, so no need to bring your own!",
      "App Link"
    ];

    for (String text in texts) {
      String? translated = await translateText(text, selectedLanguage);
      translations[text] = translated ?? text;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _translateAll();
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
                    _translateAll(entry.value);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _openURL(String url) async {
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Launrdy Cafe"),
        backgroundColor: scribblrPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: selectLanguage, // Open language selection dialog
            tooltip: "Change Language",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildSectionTitle(translations[
                        "How to Use the Laundry Room with the Meta Club App"] ??
                    "How to Use the Laundry Room with the Meta Club App"),
                _buildInfoItem(
                    "1. ",
                    translations[
                            "Download and Open the Meta Club App: Ensure the app is installed on your phone and log in with your account."] ??
                        "Download and Open the Meta Club App: Ensure the app is installed on your phone and log in with your account."),
                _buildInfoItem(
                    "2. ",
                    translations[
                            "Add Funds: Top up your account through bank transfer or by visiting a convenience store."] ??
                        "Add Funds: Top up your account through bank transfer or by visiting a convenience store."),
                _buildInfoItem(
                    "3. ",
                    translations[
                            "Navigate to Laundry: From the home screen, tap on the Laundry option."] ??
                        "Navigate to Laundry: From the home screen, tap on the Laundry option."),
                _buildInfoItem(
                    "4. ",
                    translations[
                            "Choose a Laundry Room: Select the laundry room closest to you or the one you’re using from the available options."] ??
                        "Choose a Laundry Room: Select the laundry room closest to you or the one you’re using from the available options."),
                _buildInfoItem(
                    "5. ",
                    translations[
                            "Connect to the Equipment: Tap on the machine you want to use (washer or dryer), and sync your phone with the equipment via the app."] ??
                        "Connect to the Equipment: Tap on the machine you want to use (washer or dryer), and sync your phone with the equipment via the app."),
                _buildInfoItem(
                    "6. ",
                    translations[
                            "Start Laundry: Once connected, simply tap Start to begin your laundry cycle."] ??
                        "Start Laundry: Once connected, simply tap Start to begin your laundry cycle."),
                _buildInfoItem(
                    "7. ",
                    translations[
                            "Monitor Progress: You can check the status of your laundry directly in the app."] ??
                        "Monitor Progress: You can check the status of your laundry directly in the app."),
                _buildInfoItem(
                    "Note: ",
                    translations[
                            "Note: The washing machine automatically adds laundry detergent, so no need to bring your own!"] ??
                        "The washing machine automatically adds laundry detergent, so no need to bring your own!"),
                _buildClickableItem(
                    translations["App Link"] ?? "App Link",
                    "https://metapoint.page.link/NLtk",
                    Icons.link,
                    () => _openURL("https://metapoint.page.link/NLtk")),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(String step, String instruction) {
    return ListTile(
      title: Text("$step $instruction"),
    );
  }

  Widget _buildClickableItem(
      String title, String value, IconData icon, Function() onTap) {
    return ListTile(
      leading: Icon(icon, color: scribblrPrimaryColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: TextStyle(color: Colors.blue)),
      onTap: onTap,
    );
  }
}
