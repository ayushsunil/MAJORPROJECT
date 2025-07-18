import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login.dart'; // Ensure this import points to your login page

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  String? _selectedGender;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  String? _validateInput(String? value, String fieldType) {
    if (value == null || value.isEmpty) {
      return "Please enter $fieldType";
    }
    // Ensure no input starts with a whitespace
    if (value.trimLeft() != value) {
      return "$fieldType cannot start with a whitespace";
    }
    switch (fieldType) {
      case "First Name":
      case "Last Name":
        if (!RegExp(r'^[a-zA-Z]+( [a-zA-Z]+)*$').hasMatch(value)) {
          return "$fieldType should contain only alphabets and a single space between names";
        }
        break;
      case "Phone Number":
        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
          return "Enter a valid 10-digit Indian phone number";
        }
        break;
      case "Email":
        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
          return "Enter a valid email address";
        }
        break;
      case "Height":
        if (value.contains(" ")) {
          return "$fieldType cannot contain spaces";
        }
        double? height = double.tryParse(value);
        if (height == null || height < 50 || height > 250) {
          return "Enter a realistic height in cm (50-250)";
        }
        break;
      case "Weight":
        if (value.contains(" ")) {
          return "$fieldType cannot contain spaces";
        }
        double? weight = double.tryParse(value);
        if (weight == null || weight < 20 || weight > 300) {
          return "Enter a realistic weight in kg (20-300)";
        }
        break;
      case "Age":
        if (value.contains(" ")) {
          return "$fieldType cannot contain spaces";
        }
        int? age = int.tryParse(value);
        if (age == null || age < 10 || age > 100) {
          return "Enter a valid age (10-100)";
        }
        break;
      case "Username":
        if (value.contains(" ")) {
          return "$fieldType cannot contain spaces";
        }
        if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value)) {
          return "Username can only contain letters, numbers, underscores, or dots";
        }
        if (value.length < 4) {
          return "Username must be at least 4 characters";
        }
        break;
      case "Password":
        if (value.contains(" ")) {
          return "$fieldType cannot contain spaces";
        }
        if (value.length < 8 || !RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(value)) {
          return "Password must be at least 8 characters and include letters and numbers";
        }
        break;
    }
    return null;
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.black54,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => _validateInput(value, label),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: "Gender",
          labelStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.black54,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        dropdownColor: Colors.black54,
        style: TextStyle(color: Colors.white),
        items: ["Male", "Female", "Other"].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select a gender";
          }
          return null;
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if the photo is null
      if (_imageFile == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Photo Required"),
              content: Text("Please upload a photo to proceed."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return; // Exit the function if the photo is not uploaded
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("url") ?? "";
      String url = "$ip/registrationcode"; // Replace with your backend endpoint

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add text fields
      request.fields['fname'] = fnameController.text;
      request.fields['lname'] = lnameController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['email'] = emailController.text;
      request.fields['height'] = heightController.text;
      request.fields['age'] = ageController.text;
      request.fields['weight'] = weightController.text;
      request.fields['username'] = usernameController.text;
      request.fields['password'] = passwordController.text;
      request.fields['gender'] = _selectedGender ?? ""; // Add gender field

      // Add image file
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', _imageFile!.path),
        );
      }

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var jsonData = json.decode(responseData);

          if (jsonData['status'] == "ok") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Registration successful!")),
            );
            // Debugging: Print to console to ensure this block is executed
            print("Registration successful, navigating to Login page...");

            // Navigate to the login page after successful registration
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => login()), // Ensure Login is the correct class name
                  (Route<dynamic> route) => false, // This removes all routes below the new one
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(" ${jsonData['message']}")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to connect to the server")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "JOIN IN,                                                    ITS TIME TO HUSTLE!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        backgroundColor: Colors.grey[800],
                        child: _imageFile == null ? Icon(Icons.camera_alt, color: Colors.white) : null,
                      ),
                      TextButton(
                        onPressed: _pickImage,
                        child: Text("Upload Photo", style: TextStyle(color: Colors.grey)),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(fnameController, "First Name"),
                            _buildTextField(lnameController, "Last Name"),
                            _buildTextField(phoneController, "Phone Number"),
                            _buildTextField(emailController, "Email"),
                            _buildTextField(heightController, "Height"),
                            _buildTextField(weightController, "Weight"),
                            _buildTextField(ageController, "Age"),
                            _buildGenderDropdown(), // Gender dropdown
                            _buildTextField(usernameController, "Username"),
                            _buildTextField(passwordController, "Password", obscureText: true),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _submitForm,
                              child: Text("Submit", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}