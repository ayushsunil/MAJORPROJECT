import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String name, email, phone, gender, height, weight;

  const ProfilePage({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.height,
    required this.weight,
    super.key,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController genderController;
  late TextEditingController heightController;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);

    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
    genderController = TextEditingController(text: widget.gender);
    heightController = TextEditingController(text: widget.height);
    weightController = TextEditingController(text: widget.weight);
  }

  Future<void> saveProfile() async {
    final pref = await SharedPreferences.getInstance();
    String ip = pref.getString("url") ?? "";
    String lid = pref.getString("lid") ?? "";

    String url = "$ip/update_profile";
    var response = await http.post(Uri.parse(url), body: {
      'lid': lid,
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'gender': genderController.text,
      'height': heightController.text,
      'weight': weightController.text,
    });

    if (response.statusCode == 200) {

      pref.setString("height", heightController.text);
      pref.setString("weight", weightController.text);
      Navigator.pop(context, true); // Indicate profile update success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Name", nameController),
            _buildTextField("Email", emailController),
            _buildTextField("Phone", phoneController),
            _buildTextField("Gender", genderController),
            _buildTextField("Height", heightController),
            _buildTextField("Weight", weightController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProfile,
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}