import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckSheet extends StatefulWidget {
  const CheckSheet({Key? key}) : super(key: key);

  @override
  State<CheckSheet> createState() => _CheckSheetState();
}

class _CheckSheetState extends State<CheckSheet> {
  late List<bool> _completedDays;
  late SharedPreferences _prefs;
  int _daysInMonth = DateTime.now().month == 2 ? 28 : (DateTime.now().month % 2 == 1 ? 31 : 30);

  @override
  void initState() {
    super.initState();
    _loadCompletionState();
  }

  Future<void> _loadCompletionState() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedDays = List.generate(_daysInMonth, (index) => _prefs.getBool('day_$index') ?? false);
    });
  }

  Future<void> _toggleCompletion(int index) async {
    setState(() {
      _completedDays[index] = !_completedDays[index];
    });
    await _prefs.setBool('day_$index', _completedDays[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Workout Check-Sheet",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B0000), // Dark Red
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 columns for days of the week
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _daysInMonth,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _toggleCompletion(index),
              child: Container(
                decoration: BoxDecoration(
                  color: _completedDays[index] ? Colors.green : Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
