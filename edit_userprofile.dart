import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Importing dart:io for File

class EditUserProfile extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone;
  final String profilePicture; // Added profile picture field
  final Function onProfileUpdated; // Callback function

  const EditUserProfile({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.profilePicture, // Initialize profile picture
    required this.onProfileUpdated, // Accept the callback
  });

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  XFile? _image; // Variable to hold the selected image

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    _image = await picker.pickImage(
        source: ImageSource.gallery); // Picking image from gallery
    setState(() {}); // Update the UI
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('http://10.0.2.2:3000/users/${widget.userPhone}'),
        );
        request.headers['Content-Type'] = 'application/json';
        request.fields['name'] = _nameController.text;
        request.fields['email'] = _emailController.text;

        if (_image != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'profile_picture', _image!.path)); // Adding the image file
        }

        final response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          widget
              .onProfileUpdated(); // Call the callback to notify the parent widget
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          print('Failed to update profile: ${response.reasonPhrase}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to update profile: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage, // Allow tapping to pick an image
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(File(_image!.path))
                      : NetworkImage(widget
                          .profilePicture), // Display selected image or existing profile picture
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
