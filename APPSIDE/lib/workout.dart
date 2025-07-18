import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart'; // For rendering Markdown
import 'package:flutter/services.dart'; // For clipboard copy
import 'package:boost/workoutbot.dart'; // Import the ChatApp widget

class CustomWorkoutForm extends StatefulWidget {
  @override
  _CustomWorkoutFormState createState() => _CustomWorkoutFormState();
}

class _CustomWorkoutFormState extends State<CustomWorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController pushUpController = TextEditingController();
  final TextEditingController plankController = TextEditingController();
  final TextEditingController squatController = TextEditingController();

  String? goal, workoutDays, equipment, gender;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from backend
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid") ?? "";
    userId = lid; // Store user ID

    String url = "$ip/get_user_details?lid=$lid"; // Adjust API endpoint

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          ageController.text = jsonData['age'].toString();
          heightController.text = jsonData['height'].toString();
          weightController.text = jsonData['weight'].toString();
          genderController.text = jsonData['gender'].toString(); // Fetch gender from backend
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to fetch user data"),
        ));
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Save form data to SharedPreferences
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("age", ageController.text);
    await prefs.setString("height", heightController.text);
    await prefs.setString("weight", weightController.text);
    await prefs.setString("goal", goal ?? "");
    await prefs.setString("workoutDays", workoutDays ?? "");
    await prefs.setString("equipment", equipment ?? "");
    await prefs.setString("pushUps", pushUpController.text);
    await prefs.setString("plankTime", plankController.text);
    await prefs.setString("maxSquats", squatController.text);
    await prefs.setString("gender",  genderController.text); // Save gender
    print("User input saved!");
  }

  // Submit form and send data to backend
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await _saveData();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("url") ?? "";
      String lid = prefs.getString("lid") ?? "";
      userId = lid;
      String url = "$ip/workout_plan";

      var response = await http.post(
        Uri.parse(url),
        body: {
          'lid': lid,
          'user_id': userId,
          'goal': goal ?? "",
          'workout_days': workoutDays ?? "",
          'equipment': equipment ?? "",
          'plank_time': plankController.text,
          'can_do_squats': squatController.text,
          'max_pushups': pushUpController.text,
        },
      );

      var jsonData = json.decode(response.body);
      if (jsonData['status'].toString() == "ok") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Workout preferences saved successfully!"),
        ));
        prefs.setString("msg",  jsonData['message'].toString());
        // Redirect to ResultPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(analyzedResult: jsonData['message'].toString()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to save workout preferences."),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Custom Workout Plan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black, // Match homepage theme
        iconTheme: const IconThemeData(color: Colors.white), // White back button
      ),
      backgroundColor: Colors.black, // Dark background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header with Gradient Background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Workout Preferences",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Fill in your details to get a personalized workout plan.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Input Fields
              _buildTextField("Age", ageController, enabled: false),
              _buildTextField("Height (cm)", heightController, enabled: false),
              _buildTextField("Weight (kg)", weightController, enabled: false),
              _buildTextField("Gender", genderController, enabled: false),
              _buildDropdown("Goal", ["Build Muscle", "Lose Fat", "Endurance", "General Fitness"], (value) {
                setState(() => goal = value);
              }, validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a goal";
                }
                return null;
              }),
              _buildDropdown("Workout Days Per Week", ["4 Days", "5 Days", "6 Days"], (value) {
                setState(() => workoutDays = value);
              }, validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select workout days";
                }
                return null;
              }),
              _buildDropdown("Equipment Available", ["Bodyweight ", "Dumbbells", "Both Bodyweight and dumbells"], (value) {
                setState(() => equipment = value);
              }, validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select equipment";
                }
                return null;
              }),
              _buildTextField("Max Push-Ups", pushUpController, validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return "Enter a valid number";
                }
                return null;
              }),
              _buildTextField("Plank Hold Time (seconds)", plankController, validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return "Enter a valid number";
                }
                return null;
              }),
              _buildTextField("Max Squats", squatController, validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return "Enter a valid number";
                }
                return null;
              }),
              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Save Preferences",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[900],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged, {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[900],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dropdownColor: Colors.grey[900], // Match dropdown background
        style: const TextStyle(color: Colors.white), // White text
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(color: Colors.white)),
        )).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final String analyzedResult;

  const ResultPage({super.key, required this.analyzedResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        title: const Text("Workout Plan", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Copy Button in AppBar
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: analyzedResult));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copied to clipboard!")),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Result Card with Improved Readability
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Workout Plan",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Displaying results with Markdown support for bold text
                  MarkdownBody(
                    data: analyzedResult,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5, // Improved line spacing
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}