import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalorieMonitor extends StatefulWidget {
  const CalorieMonitor({super.key});

  @override
  State<CalorieMonitor> createState() => _CalorieMonitorState();
}

class _CalorieMonitorState extends State<CalorieMonitor> {
  int _caloriesConsumed = 0;
  int _caloriesBurned = 0;
  int _calorieGoal = 2000;
  final TextEditingController _goalController = TextEditingController();
  final List<TextEditingController> _mealControllers = List.generate(4, (index) => TextEditingController());
  final TextEditingController _snackController = TextEditingController();
  final TextEditingController _workoutController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalorieData();
  }

  Future<void> _loadCalorieData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _caloriesConsumed = prefs.getInt('caloriesConsumed') ?? 0;
      _caloriesBurned = prefs.getInt('caloriesBurned') ?? 0;
      _calorieGoal = prefs.getInt('calorieGoal') ?? 2000;
      _goalController.text = _calorieGoal.toString();
      _isLoading = false;
    });
  }

  Future<void> _updateCalorieData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('caloriesConsumed', _caloriesConsumed);
    await prefs.setInt('caloriesBurned', _caloriesBurned);
    await prefs.setInt('calorieGoal', _calorieGoal);
  }

  void _calculateCalories() {
    if (!_validateInput(_goalController.text, 1000, 4000)) {
      _showError("Daily Calorie Goal must be between 1000 and 4000.");
      return;
    }

    for (var controller in _mealControllers) {
      if (controller.text.isNotEmpty && !_validateInput(controller.text, 50, 2000)) {
        _showError("Each meal must be between 50 and 2000 calories.");
        return;
      }
    }

    if (_snackController.text.isNotEmpty && !_validateInput(_snackController.text, 0, 1000)) {
      _showError("Snacks must be between 0 and 1000 calories.");
      return;
    }

    if (_workoutController.text.isNotEmpty && !_validateInput(_workoutController.text, 0, 4000)) {
      _showError("Calories Burned must be between 0 and 4000.");
      return;
    }

    int totalMealCalories = _mealControllers.fold(0, (sum, controller) => sum + (int.tryParse(controller.text) ?? 0));
    int snackCalories = int.tryParse(_snackController.text) ?? 0;
    int workoutCalories = int.tryParse(_workoutController.text) ?? 0;

    setState(() {
      _caloriesConsumed = totalMealCalories + snackCalories;
      _caloriesBurned = workoutCalories;
      _calorieGoal = int.tryParse(_goalController.text) ?? _calorieGoal;
    });
    _updateCalorieData();
  }

  bool _validateInput(String input, int min, int max) {
    if (input.isEmpty) return false;
    int? value = int.tryParse(input);
    return value != null && value >= min && value <= max;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _resetData() {
    setState(() {
      _caloriesConsumed = 0;
      _caloriesBurned = 0;
      _calorieGoal = 2000;
      _goalController.text = _calorieGoal.toString();
      for (var controller in _mealControllers) {
        controller.clear();
      }
      _snackController.clear();
      _workoutController.clear();
    });
    _updateCalorieData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    int netCalories = _caloriesConsumed - _caloriesBurned;
    bool isGoalAchieved = netCalories <= _calorieGoal;
    double progressValue = (_caloriesConsumed / _calorieGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CALORIE MONITOR",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/newhome.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetData,
            tooltip: 'Reset Data',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/newhome.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Input Section
                  _buildCard(
                    Column(
                      children: [
                        TextField(
                          controller: _goalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Daily Calorie Goal",
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[200]!),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        ..._mealControllers.asMap().entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: TextField(
                              controller: entry.value,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Meal ${entry.key + 1} Calories",
                                labelStyle: TextStyle(color: Colors.grey[300]),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey[400]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue[200]!),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }),
                        TextField(
                          controller: _snackController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Snacks Calories",
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[200]!),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _workoutController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Calories Burned",
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue[200]!),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _calculateCalories,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("CALCULATE", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Summary Section
                  _buildCard(
                    Column(
                      children: [
                        Text(
                          "CALORIE SUMMARY",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 15),
                        LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isGoalAchieved ? Colors.green : Colors.red,
                          ),
                          minHeight: 10,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${(progressValue * 100).toStringAsFixed(0)}% of goal",
                          style: TextStyle(color: Colors.grey[300], fontSize: 14),
                        ),
                        SizedBox(height: 20),
                        _buildSummaryRow(Icons.fastfood, "Consumed", "$_caloriesConsumed kcal", Colors.blue[200]!),
                        _buildSummaryRow(Icons.directions_run, "Burned", "$_caloriesBurned kcal", Colors.red[200]!),
                        _buildSummaryRow(Icons.trending_up, "Net", "$netCalories kcal",
                            isGoalAchieved ? Colors.green[200]! : Colors.red[200]!),
                        SizedBox(height: 10),
                        Text(
                          isGoalAchieved ? "GOAL ACHIEVED!" : "GOAL EXCEEDED!",
                          style: TextStyle(
                            color: isGoalAchieved ? Colors.green : Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}