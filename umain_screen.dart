import 'package:flutter/material.dart';
import 'package:ride_sharing_app/driver_screen/dmap_page.dart';
import 'umap_page.dart';
import 'userprofile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _MainPageState();
}

class _MainPageState extends State<UserMainPage> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    uHomeScreen(),
    ActivityScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

class uHomeScreen extends StatelessWidget {
  const uHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 60,
            color: Colors.deepPurple,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'SAWARI',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose a Ride',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const uMapPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(50),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Icon(
                    Icons.directions_bike,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const Text(
                  'Bike',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(50),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const Text(
                  'Car',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.bookmark,
        size: 100,
        color: Colors.deepPurple,
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No user data found'));
        } else {
          return Userprofile(
            userName: snapshot.data!['name'] ?? '',
            phone: snapshot.data!['phone'] ?? '',
            email: snapshot.data!['email'] ?? '',
            profilePicture:
                snapshot.data!['profile_picture'] ?? '', // Pass profile picture
            onProfileUpdated: () {
              // Logic to refresh or update the profile if needed
            },
          );
        }
      },
    );
  }

  Future<Map<String, String>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('userPhone') ?? '';
    print('Retrieved phone number from shared preferences: $phone');

    if (phone.isEmpty) {
      throw Exception('Phone number is missing in SharedPreferences.');
    }

    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/users?phone=$phone'));
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isEmpty) {
          throw Exception('No user data found for the provided phone number.');
        }
        return {
          'name': data[0]['name'] ?? '',
          'phone': data[0]['phone'] ?? '',
          'email': data[0]['email'] ?? '',
          'profile_picture':
              data[0]['profile_picture'] ?? '', // Include profile picture
        };
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }
}
