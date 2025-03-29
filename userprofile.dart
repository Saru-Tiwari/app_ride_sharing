import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../create_account_page.dart'; // Import the Create Account Page
import 'edit_userprofile.dart'; // Import the Edit User Profile Page

class Userprofile extends StatefulWidget {
  final String userName; // Added userName parameter
  final String phone;
  final String email; // Added email parameter
  final String profilePicture; // Added profile picture field
  final Function onProfileUpdated; // Callback function to notify updates

  const Userprofile({
    super.key,
    required this.userName, // Required userName parameter
    required this.phone,
    required this.email, // Required email parameter
    required this.profilePicture, // Required profile picture parameter
    required this.onProfileUpdated, // Required callback
  });

  @override
  State<Userprofile> createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {
  String userPhone = '';
  String userProfilePicture = ''; // Holds the profile picture URL
  bool isLoading = true; // Loader for fetch operation

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true; // Show loader while fetching data
    });
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/users?phone=${widget.phone}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userPhone = data[0]['phone'] ?? '';
          userProfilePicture =
              'http://10.0.2.2:3000/${data[0]['profile_picture'] ?? ''}';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user details')),
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
                      backgroundImage: userProfilePicture.isNotEmpty
                          ? NetworkImage(
                              userProfilePicture) // Display profile picture
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                      child: userProfilePicture.isEmpty
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      widget.userName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Phone: $userPhone',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Email: ${widget.email}',
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
                            builder: (context) => EditUserProfile(
                              userName: widget.userName,
                              userEmail: widget.email,
                              userPhone: widget.phone,
                              profilePicture:
                                  userProfilePicture, // Pass profile picture
                              onProfileUpdated: () {
                                fetchUserData(); // Refresh profile data
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
