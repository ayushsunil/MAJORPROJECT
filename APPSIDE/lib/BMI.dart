import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BMICalculator extends StatefulWidget {
  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  String? activityLevel;
  double? bmi;
  String? bmiCategory;
  double? calorieRequirement;

  final List<String> activityLevels = ["Sedentary", "Moderate", "Active"];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      heightController.text = prefs.getString("height") ?? "";
      weightController.text = prefs.getString("weight") ?? "";
      genderController.text = prefs.getString("gender") ?? "";
    });
    _calculateBMI();
    _calculateCalorieRequirement();
  }

  void _calculateBMI() {
    final height = double.tryParse(heightController.text) ?? 0;
    final weight = double.tryParse(weightController.text) ?? 0;
    if (height > 0 && weight > 0) {
      final heightM = height / 100;
      bmi = weight / (heightM * heightM);
      if (bmi! < 18.5) {
        bmiCategory = "Underweight";
      } else if (bmi! < 24.9) {
        bmiCategory = "Normal";
      } else if (bmi! < 29.9) {
        bmiCategory = "Overweight";
      } else {
        bmiCategory = "Obese";
      }
    }
  }

  void _calculateCalorieRequirement() {
    final weight = double.tryParse(weightController.text) ?? 0;
    final height = double.tryParse(heightController.text) ?? 0;
    final gender = genderController.text.toLowerCase();

    if (weight > 0 && height > 0 && gender.isNotEmpty) {
      final bmr = gender == "male"
          ? 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * 25)
          : 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * 25);
      calorieRequirement = bmr * _getActivityMultiplier();
    }
  }

  double _getActivityMultiplier() {
    switch (activityLevel) {
      case "Moderate":
        return 1.55;
      case "Active":
        return 1.725;
      default:
        return 1.2;
    }
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            enabled: false,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.grey[900],
      value: activityLevel,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[900],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      items: activityLevels
          .map((level) =>
          DropdownMenuItem(value: level, child: Text(level)))
          .toList(),
      onChanged: (value) {
        setState(() => activityLevel = value);
        _calculateCalorieRequirement();
      },
    );
  }

  Widget _resultBox({required String title, required String value, String? subtitle, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[900],
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("BMI Calculator", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Your Info"),
              _buildInputField("Height (cm)", heightController),
              const SizedBox(height: 12),
              _buildInputField("Weight (kg)", weightController),
              const SizedBox(height: 12),
              _buildInputField("Gender", genderController),
              const SizedBox(height: 18),
              _sectionTitle("Activity Level"),
              _buildDropdown(),
              if (bmi != null)
                _resultBox(
                  title: "BMI",
                  value: bmi!.toStringAsFixed(1),
                  subtitle: bmiCategory,
                  color: _bmiColor(),
                ),
              if (calorieRequirement != null)
                _resultBox(
                  title: "Daily Calorie Need",
                  value: "${calorieRequirement!.toStringAsFixed(0)} kcal",
                  subtitle: "Activity: ${activityLevel ?? 'Sedentary'}",
                  color: Colors.indigo[900],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _bmiColor() {
    if (bmi == null) return Colors.grey[900]!;
    if (bmi! < 18.5) return Colors.blueGrey[800]!;
    if (bmi! < 24.9) return Colors.green[800]!;
    if (bmi! < 29.9) return Colors.orange[800]!;
    return Colors.red[800]!;
  }
}
