import 'package:flutter/material.dart';
import 'user_screen/user_login_page.dart'; // Import the User Login Page
import 'driver_screen/driver_login_page.dart';
import 'user_screen/register_choice_page.dart'; // Import the Driver Login Page
// Import the Register Choice Page

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Light background color
        appBar: AppBar(
          title: const Text(
            'Sawari',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 103, 58, 183), // Purple
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                'Login as:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserLoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('As User'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverLoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('As Driver'),
              ),
              const SizedBox(height: 20),
              // Text button for registration
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterChoicePage(),
                    ),
                  );
                },
                child: const Text(
                  "Don't have an account? Register now.",
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 103, 58, 183), // Matching background color
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
