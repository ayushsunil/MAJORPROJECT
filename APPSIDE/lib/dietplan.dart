import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart'; // For rendering Markdown
import 'package:flutter/services.dart'; // For clipboard copy
import 'dietbot.dart'; // Import chatbot screen

class DietPlanForm extends StatefulWidget {
  @override
  _DietPlanFormState createState() => _DietPlanFormState();
}

class _DietPlanFormState extends State<DietPlanForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  String? activityLevel;
  String? goal;
  String? dietType;
  String? medicalCondition;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid") ?? "";
    userId = lid;

    String url = "$ip/get_user_details?lid=$lid";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          ageController.text = jsonData['age'].toString();
          heightController.text = jsonData['height'].toString();
          weightController.text = jsonData['weight'].toString();
          genderController.text = jsonData['gender'].toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch user data")),
        );
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid") ?? "";

    String url = "$ip/dietbot_response"; // Update this endpoint as needed

    Map<String, dynamic> dietData = {
      "user_id": lid,
      "activity_level": activityLevel,
      "goal": goal,
      "diet_type": dietType,
      "medical_condition": medicalCondition,
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dietData),
      );

      if (response.statusCode == 200) {
        print("Started");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Diet plan saved successfully!")),
        );
        print("=====================");
        print(response.body);
        var jsonData = json.decode(response.body);
        if (jsonData['task'].toString() == "ok") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Diet plan preferences saved successfully!"),
          ));
          print(jsonData);
          print(jsonData['response'].toString());
          prefs.setString("msg", jsonData['message'].toString());
          // Navigate to Diet Plan Bot
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DietPlanBotScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save diet plan")),
        );
      }
    } catch (e) {
      print("Error saving diet plan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error connecting to server")),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await _saveData();
      print("Diet preferences saved successfully for user: $userId");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Diet Plan Form",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                      "Diet Preferences",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Fill in your details to get a personalized diet plan.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Age", ageController, enabled: false),
              _buildTextField("Height (cm)", heightController, enabled: false),
              _buildTextField("Weight (kg)", weightController, enabled: false),
              _buildTextField("Gender", genderController, enabled: false),
              _buildDropdown("Activity Level", ["Sedentary", "Moderate", "Active"], (value) {
                setState(() => activityLevel = value);
              }),
              _buildDropdown("Goal", ["Weight Loss", "Weight Gain", "Maintain"], (value) {
                setState(() => goal = value);
              }),
              _buildDropdown("Diet Type", ["Veg", "Non-Veg", "Vegan"], (value) {
                setState(() => dietType = value);
              }),
              _buildDropdown("Medical Condition", ["None", "Diabetes", "High BP"], (value) {
                setState(() => medicalCondition = value);
              }),
              const SizedBox(height: 20),
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
                  "Save Diet Plan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
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
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
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
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class DietPlanBotScreen extends StatelessWidget {
  const DietPlanBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        title: const Text("Diet Plan", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Copy Button in AppBar
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String result = prefs.getString("msg") ?? "";
              Clipboard.setData(ClipboardData(text: result));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copied to clipboard!")),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            SharedPreferences prefs = snapshot.data as SharedPreferences;
            String result = prefs.getString("msg") ?? "No diet plan available.";

            return SingleChildScrollView(
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
                          "Your Diet Plan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Displaying results with Markdown support for bold text
                        MarkdownBody(
                          data: result,
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
            );
          }
        },
      ),
    );
  }
}