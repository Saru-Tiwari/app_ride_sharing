import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../create_account_page.dart'; // Import the Create Account Page
import 'edit_driverprofile.dart'; // Import the Edit Driver Profile Page

class Driverprofile extends StatefulWidget {
  final String phone;
  final Function onProfileUpdated; // Callback function to notify updates

  const Driverprofile({
    super.key,
    required this.phone,
    required this.onProfileUpdated,
  });

  @override
  State<Driverprofile> createState() => _DriverprofileState();
}

class _DriverprofileState extends State<Driverprofile> {
  String driverName = '';
  String driverPhone = '';
  String driverEmail = '';
  String driverProfilePicture = ''; // Holds the profile picture URL
  bool isLoading = true; // Loader for fetch operation

  @override
  void initState() {
    super.initState();
    fetchDriverData();
  }

  Future<void> fetchDriverData() async {
    setState(() {
      isLoading = true; // Show loader while fetching data
    });
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/drivers?phone=${widget.phone}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          driverName = data[0]['name'] ?? '';
          driverPhone = data[0]['phone'] ?? '';
          driverEmail = data[0]['email'] ?? '';
          driverProfilePicture =
              'http://10.0.2.2:3000/${data[0]['profile_picture'] ?? ''}';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load driver details')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loader
      });
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const CreateAccountPage()),
                );
              },
              child: const Text('Yes'),
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
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loader when fetching data
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple,
                      backgroundImage: driverProfilePicture.isNotEmpty
                          ? NetworkImage(
                              driverProfilePicture) // Display profile picture
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                      child: driverProfilePicture.isEmpty
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      ' $driverName',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Phone: $driverPhone',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Email: $driverEmail',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditDriverProfile(
                              driverName: driverName,
                              driverEmail: driverEmail,
                              driverPhone: driverPhone,
                              onProfileUpdated: () {
                                fetchDriverData(); // Refresh profile data
                                widget
                                    .onProfileUpdated(); // Notify parent widget
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _showSignOutDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
