import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:boost/ChangePassword.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String name = "";
  String age = "";
  String email = "";
  String phone_no = "";
  String height = "";
  String weight = "";
  String gender = "";
  String photo = "";

  @override
  void initState() {
    super.initState();
    viewProfile();
  }

  Future<void> viewProfile() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url").toString();
      String lid = pref.getString("lid").toString();

      final response = await http.post(
        Uri.parse(ip + "view_profile"),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata != null && jsondata['data'] != null && jsondata['data'].isNotEmpty) {
          setState(() {
            name = jsondata['data'][0]['name'].toString();
            age = jsondata['data'][0]['age'].toString();
            email = jsondata['data'][0]['email'].toString();
            phone_no = jsondata['data'][0]['phone_no'].toString();
            height = jsondata['data'][0]['height'].toString();
            weight = jsondata['data'][0]['weight'].toString();
            gender = jsondata['data'][0]['gender'].toString();
            photo = ip + jsondata['data'][0]['photo'].toString();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No profile data found")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load profile")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          name: name,
          age: age,
          email: email,
          phone: phone_no,
          gender: gender,
          height: height,
          weight: weight,
        ),
      ),
    );

    if (result == true) {
      viewProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 24),
            onPressed: navigateToEditProfile,
            tooltip: 'Edit Profile',
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: _buildProfileBody(),
    );
  }

  Widget _buildProfileBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildProfileHeader(),
          _buildProfileDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        image: photo.isNotEmpty
            ? DecorationImage(
          image: NetworkImage(photo),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        )
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[800],
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailCard(),
          const SizedBox(height: 24),
          _buildChangePasswordButton(),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(Icons.person_outline, "Name", name),
            const Divider(color: Colors.grey, height: 24),
            _buildDetailRow(Icons.cake_outlined, "Age", age),
            const Divider(color: Colors.grey, height: 24),
            _buildDetailRow(Icons.email_outlined, "Email", email),
            const Divider(color: Colors.grey, height: 24),
            _buildDetailRow(Icons.phone_android_outlined, "Phone", phone_no),
            const Divider(color: Colors.grey, height: 24),
            _buildDetailRow(Icons.height, "Height", "$height cm"),
            const Divider(color: Colors.grey, height: 24),
            _buildDetailRow(Icons.monitor_weight_outlined, "Weight", "$weight kg"),
            const Divider(color: Colors.grey, height: 24),
            _buildDetailRow(Icons.transgender, "Gender", gender),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : "Not provided",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserChangePassword()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo[800],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Change Password",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String name;
  final String age;
  final String email;
  final String phone;
  final String gender;
  final String height;
  final String weight;

  const ProfilePage({
    required this.name,
    required this.age,
    required this.email,
    required this.phone,
    required this.gender,
    required this.height,
    required this.weight,
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGender;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _heightController = TextEditingController(text: widget.height);
    _weightController = TextEditingController(text: widget.weight);
    _selectedGender = widget.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String lid = pref.getString("lid") ?? "";

      final response = await http.post(
        Uri.parse("$ip/update_profile"),
        body: {
          'lid': lid,
          'name': _nameController.text,
          'age': _ageController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'gender': _selectedGender ?? "",
          'height': _heightController.text,
          'weight': _weightController.text,
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update profile"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildEditForm(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Full Name", _nameController),
            const SizedBox(height: 16),
            _buildTextField("Age", _ageController, isNumeric: true),
            const SizedBox(height: 16),
            _buildTextField("Email", _emailController, isEmail: true),
            const SizedBox(height: 16),
            _buildTextField("Phone Number", _phoneController, isPhone: true),
            const SizedBox(height: 16),
            _buildGenderDropdown(),
            const SizedBox(height: 16),
            _buildTextField("Height (cm)", _heightController, isNumeric: true),
            const SizedBox(height: 16),
            _buildTextField("Weight (kg)", _weightController, isNumeric: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isEmail = false, bool isPhone = false, bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'This field is required';
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Enter a valid email address';
        }
        if (isPhone && !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
          return 'Enter a valid 10-digit phone number';
        }
        if (isNumeric) {
          double? numericValue = double.tryParse(value);
          if (numericValue == null) return 'Enter a valid number';
          if (label.contains("Age") && (numericValue < 16 || numericValue > 100)) {
            return 'Age must be between 16 and 100';
          }
          if (label.contains("Height") && (numericValue < 120 || numericValue > 200)) {
            return 'Height must be between 120 and 200 cm';
          }
          if (label.contains("Weight") && (numericValue < 30 || numericValue > 150)) {
            return 'Weight must be between 30 and 150 kg';
          }
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: "Gender",
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      dropdownColor: Colors.grey[900],
      style: const TextStyle(color: Colors.white),
      items: ["Male", "Female", "Other"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedGender = value),
      validator: (value) => value == null ? 'Please select a gender' : null,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo[800],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "SAVE PROFILE",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}