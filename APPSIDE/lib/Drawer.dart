import 'package:boost/BMI.dart';
import 'package:boost/calorie_monitor.dart';
import 'package:boost/chatbot.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart'
import 'workout.dart';
import 'dietplan.dart';
import 'manage.dart';
import 'send_feedback.dart';
import 'SendAppComplaint.dart';
import 'scanner.dart';

class Drawerclass extends StatelessWidget {
  const Drawerclass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black, // Black background for the drawer
      child: Column(
        children: <Widget>[
          // Header with background image
          Container(
            height: 180, // Adjust height as needed
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/container_bg.jpg'), // Add your image asset
                fit: BoxFit.cover, // Ensure the image covers the header
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.6), // Dark overlay for better text visibility
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "BOOST",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your Fitness Partner",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey, thickness: 0.5),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.account_circle,
                  text: "Manage Profile",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfileView()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calculate,
                  text: "B.M.I Calculation",
                  onTap: () { Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BMICalculator()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.fitness_center,
                  text: "Workout Plan",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CustomWorkoutForm()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.restaurant,
                  text: "Diet-Plan & Meal Prep",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DietPlanForm()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.monitor_weight,
                  text: "Calorie Monitor",
                  onTap: () { Navigator.push(context,
                   MaterialPageRoute(builder: (context) => CalorieMonitor()));
                     },
                ),
                _buildDrawerItem(
                  icon: Icons.qr_code_scanner,
                  text: "Food Scanner",
                  onTap: () { Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UploadImage()));},
                ),
                _buildDrawerItem(
                  icon: Icons.smart_toy,
                  text: "AI Assistant",
                  onTap: () { Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatScreen()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.report_problem,
                  text: "Complaints",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AppComplaint()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.feedback,
                  text: "Feedback",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FeedbackPage()));
                  },
                ),
                const Divider(color: Colors.grey, thickness: 0.5),
                _buildDrawerItem(
                  icon: Icons.logout,
                  text: "Logout",
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const login()),
                          (Route<dynamic> route) => false, // This removes all previous routes
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon, required String text, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Dark grey for list items
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: onTap,
        hoverColor: Colors.grey.withOpacity(0.3),
        splashColor: Colors.grey.withOpacity(0.2),
      ),
    );
  }
}