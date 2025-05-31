import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';

class KitchenUsageScreen extends StatefulWidget {
  @override
  _KitchenUsageScreenState createState() => _KitchenUsageScreenState();
}

class _KitchenUsageScreenState extends State<KitchenUsageScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _usageLogs = [];
  int? userId;
  bool _isUserAlreadyLogged = false;
  static const int maxKitchenUsers = 12;

  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    String? userDataString = getStringAsync("user_data", defaultValue: "");
    if (userDataString.isNotEmpty) {
      Map<String, dynamic> userData = jsonDecode(userDataString);
      if (userData.containsKey('id')) {
        setState(() {
          userId = userData['id'];
        });
        _fetchKitchenUsage();
      }
    }
  }

  Future<void> _fetchKitchenUsage() async {
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final url = Uri.parse('$BaseUrl/api/kitchens/by-date');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"date": formattedDate}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _usageLogs = data.map((entry) {
            return {
              "id": entry["id"],
              "user_id": entry["user_id"],
              "name":
                  "${entry['user']['firstname']} ${entry['user']['lastname']}",
            };
          }).toList();
          _isUserAlreadyLogged =
              _usageLogs.any((log) => log["user_id"] == userId);
        });
      }
    } catch (error) {
      print("Error fetching data: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addKitchenUsage() async {
    if (userId == null) return;

    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final url = Uri.parse('$BaseUrl/api/kitchens');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "date": formattedDate,
        }),
      );

      if (response.statusCode == 201) {
        toast("✅ You're now using the kitchen.");
        _fetchKitchenUsage();
      } else {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        _showErrorDialog(errorData['message']);
      }
    } catch (error) {
      print("Error adding entry: $error");
      _showErrorDialog("Something went wrong. Please try again.");
    }
  }

  Future<void> _removeKitchenUsage() async {
    final log = _usageLogs.firstWhere((log) => log['user_id'] == userId,
        orElse: () => {});
    if (log.isEmpty) return;

    final url = Uri.parse('$BaseUrl/api/kitchens/${log["id"]}');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        toast("❌ You've stopped using the kitchen.");
        _fetchKitchenUsage();
      } else {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        _showErrorDialog(errorData['message']);
      }
    } catch (error) {
      print("Error deleting entry: $error");
      _showErrorDialog("Failed to unuse. Try again.");
    }
  }

  void _showUnuseConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Stop using the kitchen?"),
        content: Text("Are you sure you want to unuse the kitchen for today?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeKitchenUsage();
            },
            child: Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Lottie.asset("assets/error.json", height: 100),
            SizedBox(height: 10),
            Text("Error", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(today);
    final totalUsersToday = _usageLogs.length;
    final isFull = totalUsersToday >= maxKitchenUsers;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kitchen Usage'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Info Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text("As of $formattedDate",
                                style: TextStyle(fontSize: 18)),
                            SizedBox(height: 8),
                            Text(
                              "$totalUsersToday of $maxKitchenUsers users are currently using the kitchen",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Action Button
                    ElevatedButton(
                      onPressed: _isUserAlreadyLogged
                          ? _showUnuseConfirmation
                          : isFull
                              ? null
                              : _addKitchenUsage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                        backgroundColor: _isUserAlreadyLogged
                            ? Colors.green
                            : isFull
                                ? Colors.grey
                                : scribblrPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _isUserAlreadyLogged
                            ? "In Use"
                            : isFull
                                ? "Full"
                                : "Use the Kitchen",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
