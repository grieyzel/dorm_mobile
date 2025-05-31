import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scribblr/utils/colors.dart';
import 'package:ionicons/ionicons.dart';
import 'package:scribblr/screens/bus/add_bus.dart';
import 'package:scribblr/utils/constant.dart';

class BusStationListScreen extends StatefulWidget {
  @override
  _BusStationListScreenState createState() => _BusStationListScreenState();
}

class _BusStationListScreenState extends State<BusStationListScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> busStations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBusStations();
  }

  Future<void> fetchBusStations() async {
    try {
      final response = await http.get(Uri.parse('$BaseUrl/api/bus-schedules'));

      debugPrint("📌 API Response Code: ${response.statusCode}");
      debugPrint("📌 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          busStations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception(
            "❌ Failed to load bus stations. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error fetching bus stations: $e");
    }
  }

  Future<void> searchBusStations(String query) async {
    if (query.isEmpty) {
      fetchBusStations();
      return;
    }

    try {
      final response = await http
          .get(Uri.parse('$BaseUrl/api/bus-schedules/search?name=$query'));

      debugPrint("📌 Search API Response Code: ${response.statusCode}");
      debugPrint("📌 Search API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          busStations = json.decode(response.body);
        });
      } else {
        setState(() {
          busStations = [];
        });
        debugPrint("❌ No results found.");
      }
    } catch (e) {
      debugPrint("❌ Error searching bus stations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Stations"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search bus station...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          fetchBusStations();
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                searchBusStations(query);
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : busStations.isEmpty
                      ? Center(child: Text("No bus stations found"))
                      : ListView.builder(
                          itemCount: busStations.length,
                          itemBuilder: (context, index) {
                            var busStation = busStations[index];
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Ionicons.bus_outline,
                                          size: 30,
                                          color: scribblrPrimaryColor,
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            busStation["name"],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text("Weekday Schedule:"),
                                    Image.network(
                                      '$BaseUrl/storage/' +
                                          busStation["weekday_schedule"],
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Icon(Icons.broken_image, size: 100),
                                    ),
                                    SizedBox(height: 10),
                                    Text("Weekend Schedule:"),
                                    Image.network(
                                      '$BaseUrl/storage/' +
                                          busStation["weekend_schedule"],
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Icon(Icons.broken_image, size: 100),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Handle delete action
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddBusScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
