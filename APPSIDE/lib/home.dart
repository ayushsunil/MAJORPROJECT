import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'Drawer.dart'; // Ensure this import is correct for your Drawer class

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _HomeState();
}

class _HomeState extends State<home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late SharedPreferences _prefs;

  final List<String> _motivationalQuotes = [
    "Strength is built in the dark, forged in sweat, and tested in fire.",
    "Pain is temporary. Strength is permanent.",
    "Your body can handle more than your mind thinks it can.",
    "Embrace the grind. Chase the results.",
    "Every rep, every set, every drop of sweat—one step closer to greatness.",
    "Lifting is not just about muscles, it's about mindset.",
    "Earn your rest. Push past your limits.",
    "Don't stop when you're tired. Stop when you're done.",
    "The journey of a thousand miles begins with a single step, but it's the consistency of each step that leads to greatness.",
    "You are not defined by your past; you are prepared by it.",
    "Strength grows in the moments when you think you can't go on but keep going anyway.",
    "The only limits that exist are the ones you place on yourself.",
    "Every small step forward is a victory over stagnation.",
    "Challenges are the universe's way of preparing you for something greater.",
    "Your potential is limitless, but only if you choose to believe it.",
    "Success is not a destination; it's a mindset you carry every day.",
    "The harder the struggle, the sweeter the triumph.",
    "You don't find courage by avoiding fear; you find it by facing it head-on.",
    "Every setback is a setup for a comeback.",
    "The best time to start was yesterday; the next best time is now.",
    "Your dreams are valid, but only action will bring them to life.",
    "The fire within you is stronger than the obstacles around you.",
    "Progress is progress, no matter how small.",
    "You are the author of your story; make it one worth reading.",
    "The only way to fail is to stop trying.",
    "Your mindset is the brush; your life is the canvas. Paint boldly.",
    "Every day is a new opportunity to rewrite your narrative.",
    "The road to success is paved with persistence, not perfection.",
    "You are stronger than you think, braver than you feel, and more capable than you realize.",
    "The only thing standing between you and your goal is the story you keep telling yourself.",
    "Greatness is not born; it's built through consistent effort.",
    "Your struggles are the foundation of your strength.",
    "The best way to predict your future is to create it.",
    "You don't have to be perfect; you just have to be persistent.",
    "Every challenge is an opportunity to grow stronger and wiser.",
    "The only way to achieve the impossible is to believe it's possible.",
    "Your actions today are the seeds of your success tomorrow.",
    "The world rewards those who dare to dream and act with courage.",
  ];

  final Map<String, String> _workoutPlans = {
    "Monday": "Chest & Tricep",
    "Tuesday": "Cardio",
    "Wednesday": "Back & Shoulders",
    "Thursday": "Abs & Core",
    "Friday": "Legs & Arms",
    "Saturday": "Stretchs & Recovery",
    "Sunday": "Rest Day"
  };

  List<bool> _workoutCompletion = [];
  String _currentQuote = "";
  bool _isWorkoutCompleted = false; // Track workout completion state
  DateTime _currentDate = DateTime.now(); // Track the current month
  int? _storedMonth; // To track the month for which we have stored data

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePreferences();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkAndResetForNewMonth();
    _loadWorkoutCompletionState();
    setState(() {
      _currentQuote = _getRandomQuote();
      _isWorkoutCompleted = _workoutCompletion[DateTime.now().day - 1];
    });
  }

  Future<void> _checkAndResetForNewMonth() async {
    final now = DateTime.now();
    final storedMonth = _prefs.getInt('current_month');

    // If no month is stored or if the stored month is different from current month
    if (storedMonth == null || storedMonth != now.month) {
      // Clear old data and store the new month
      await _prefs.setInt('current_month', now.month);
      await _prefs.setInt('current_year', now.year);

      // Initialize a new empty completion list for the new month
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      _workoutCompletion = List.filled(daysInMonth, false);

      // Save the empty list
      for (int i = 0; i < daysInMonth; i++) {
        await _prefs.setBool('day_$i', false);
      }
    }
  }

  void _loadWorkoutCompletionState() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Load completion status for each day
    _workoutCompletion = List.generate(daysInMonth, (index) {
      return _prefs.getBool('day_$index') ?? false;
    });

    setState(() {});
  }

  Future<void> _saveWorkoutCompletionState(int day, bool value) async {
    await _prefs.setBool('day_$day', value);
  }

  String _getRandomQuote() {
    return _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
  }

  String _getDayOfWeek() {
    return ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"][DateTime.now().weekday - 1];
  }

  void _markWorkoutComplete() {
    setState(() {
      _isWorkoutCompleted = true;
      _workoutCompletion[DateTime.now().day - 1] = true;
      _saveWorkoutCompletionState(DateTime.now().day - 1, true);
    });
  }

  String _getMonthName() {
    return [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ][_currentDate.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = _getDayOfWeek();
    String workoutPlan = _workoutPlans[dayOfWeek] ?? "Rest & Recovery";
    String formattedDate = "${DateTime.now().day}/${_currentDate.month}/${_currentDate.year}";
    String monthName = _getMonthName();
    int year = _currentDate.year;

    return Scaffold(
      drawer: const Drawerclass(),
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "BOOST",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Remove shadow
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Use the correct context
            },
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/newhome.jpg"), // Match background image
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/newhome.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCard(_buildMotivationCard()),
                  const SizedBox(height: 20),
                  _buildCard(_buildWorkoutCard(workoutPlan, formattedDate)),
                  const SizedBox(height: 20),
                  _buildCard(_buildCalendar(monthName, year)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildMotivationCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        _currentQuote,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWorkoutCard(String workoutPlan, String formattedDate) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Today's Workout",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "$formattedDate - $workoutPlan",
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _isWorkoutCompleted ? null : _markWorkoutComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isWorkoutCompleted ? Colors.blue : Colors.red, // Blue when completed, red otherwise
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              _isWorkoutCompleted ? "Workout Done! " : "Did You Complete Today's Workout?",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(String monthName, int year) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "$monthName $year", // Display month and year
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _workoutCompletion.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: _workoutCompletion[index] ? Colors.blue : Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}