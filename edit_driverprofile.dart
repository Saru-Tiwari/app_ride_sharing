import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Importing image_picker
import 'dart:io'; // Importing dart:io for File

class EditDriverProfile extends StatefulWidget {
  final String driverName;
  final String driverEmail;
  final String driverPhone;
  final Function onProfileUpdated; // Callback function

  const EditDriverProfile({
    super.key,
    required this.driverName,
    required this.driverEmail,
    required this.driverPhone,
    required this.onProfileUpdated, // Accept the callback
  });

  @override
  State<EditDriverProfile> createState() => _EditDriverProfileState();
}

class _EditDriverProfileState extends State<EditDriverProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  XFile? _image; // Variable to hold the selected image

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driverName);
    _emailController = TextEditingController(text: widget.driverEmail);
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
          Uri.parse('http://10.0.2.2:3000/drivers/${widget.driverPhone}'),
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
          // Call the callback to notify the parent widget
          widget.onProfileUpdated();
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

  Future<void> _fetchDriverDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/drivers/${widget.driverPhone}'),
      );

      if (response.statusCode == 200) {
        final driverData = json.decode(response.body);
        // Update the UI with the new driver data
        setState(() {
          _nameController.text = driverData['name'];
          _emailController.text = driverData['email'];
          // Update other fields as necessary
        });
      } else {
        print('Failed to fetch driver details: ${response.body}');
      }
    } catch (e) {
      print('Error fetching driver details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Driver Profile'),
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
                      : null, // Display selected image
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
