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

      if (response.statusCode == 200) {
        setState(() {
          busStations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception("❌ Failed to load bus stations.");
      }
    } catch (e) {
      setState(() => isLoading = false);
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

      if (response.statusCode == 200) {
        setState(() {
          busStations = json.decode(response.body);
        });
      } else {
        setState(() {
          busStations = [];
        });
      }
    } catch (e) {
      debugPrint("❌ Error searching bus stations: $e");
    }
  }

  Future<void> deleteBusStation(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('$BaseUrl/api/bus-schedules/$id'));

      if (response.statusCode == 200) {
        // Successfully deleted, refresh the list
        fetchBusStations();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Bus station deleted successfully")),
        );
      } else {
        throw Exception("❌ Failed to delete bus station.");
      }
    } catch (e) {
      debugPrint("❌ Error deleting bus station: $e");
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text("Do you really want to delete this bus station?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteBusStation(id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text("Yes, Delete"),
            ),
          ],
        );
      },
    );
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
                                            confirmDelete(busStation["id"]);
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
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddBusScreen()),
          );
          if (result == true) {
            fetchBusStations(); // ✅ Refresh when coming back from AddBusScreen
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
