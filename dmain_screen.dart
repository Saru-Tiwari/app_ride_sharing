import 'package:flutter/material.dart';
import 'driver_earning.dart';
import 'driverprofile.dart'; // Importing Driverprofile
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DriverPage extends StatefulWidget {
  final Function onProfileUpdated; // Callback function

  const DriverPage(
      {super.key, required this.onProfileUpdated}); // Accept the callback

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  bool isDriverOnline = true; // Tracks the driver's online status
  String driverName = ''; // Placeholder for driver name
  String driverPhone = ''; // Placeholder for driver phone
  String driverEmail = ''; // Placeholder for driver email
  String driverProfilePicture = ''; // Placeholder for driver profile picture

  Future<void> fetchDriverData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber =
          prefs.getString('phoneNumber'); // Retrieve the phone number

      if (phoneNumber != null) {
        setState(() {
          driverPhone = phoneNumber; // Update the phone number
        });
      }

      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/drivers?phone=$driverPhone'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          driverName = data[0]['name'] ?? '';
          driverPhone = data[0]['phone'] ?? '';
          driverEmail = data[0]['email'] ?? '';
          driverProfilePicture =
              data[0]['profile_picture'] ?? ''; // Fetching profile picture
        });
      } else {
        // Handle error
        print('Failed to load driver details: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load driver details')),
        );
      }
    } catch (e) {
      print('Error fetching driver data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDriverData(); // Fetch driver data on initialization
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchDriverData(); // Fetch driver data when dependencies change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Online/Offline Toggle Section
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Driver Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isDriverOnline,
                    onChanged: (value) {
                      setState(() {
                        isDriverOnline = value;
                      });
                      print(value ? 'Online' : 'Offline');
                    },
                    activeColor: Colors.deepPurple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Display Driver Information
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: driverProfilePicture.isNotEmpty
                      ? NetworkImage(
                          driverProfilePicture) // Displaying profile picture
                      : const AssetImage(
                          'assets/default_profile.png'), // Default image if none
                ),
                title: Text('Driver Name: $driverName'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: $driverPhone'),
                    Text('Email: $driverEmail'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ride Requests Section
            if (isDriverOnline)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Incoming Ride Requests',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: const Icon(Icons.directions_car,
                                  color: Colors.deepPurple),
                              title: Text('Ride Request #${index + 1}'),
                              subtitle:
                                  const Text('Pickup: City Center\nDrop: Mall'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  print('Accepted Ride Request #${index + 1}');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Accept'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Earnings Overview Section
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Earnings Today:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹1200', // Mock earnings
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.deepPurple,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EarningsPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Driverprofile(
                  phone: driverPhone,
                  onProfileUpdated: () {
                    fetchDriverData(); // Refresh driver data after update
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
