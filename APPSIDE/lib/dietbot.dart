import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const DietPlanBotApp());
}

class DietPlanBotApp extends StatelessWidget {
  const DietPlanBotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black, // Pure black AppBar
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins', // Use a custom font
          ),
        ),
      ),
      home: DietPlanBotScreen(),
    );
  }
}

class DietPlanBotScreen extends StatefulWidget {
  @override
  _DietPlanBotScreenState createState() => _DietPlanBotScreenState();
}

class _DietPlanBotScreenState extends State<DietPlanBotScreen> {
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    viewmsg();
  }

  Future<void> viewmsg() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _messages.add({"role": "user", "message": prefs.getString("msg").toString()});
    });
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({"role": "user", "message": message});
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? url = prefs.getString('url');

      if (url == null) {
        Fluttertoast.showToast(msg: "API URL not configured.");
        return;
      }

      final response = await http.post(
        Uri.parse('$url/dietbot_response'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.containsKey('response')) {
          setState(() {
            _messages.add({"role": "bot", "message": data['response']});
          });
        } else {
          setState(() {
            _messages.add({
              "role": "bot",
              "message": "Unexpected response format."
            });
          });
        }
      } else {
        setState(() {
          _messages.add({
            "role": "bot",
            "message": "Error: ${response.body}"
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "bot",
          "message": "Failed to connect to server. Check your internet."
        });
      });
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['role'] == "user";
    final text = message['message'] ?? '';

    // Parse the message to identify bold words (words wrapped in **)
    final textSpans = _parseMessage(text);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.grey[900] : Colors.red[900], // Dark grey for user, dark red for bot
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'Poppins', // Use a custom font
            ),
            children: textSpans,
          ),
        ),
      ),
    );
  }

  List<TextSpan> _parseMessage(String text) {
    final List<TextSpan> textSpans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in boldRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        textSpans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      textSpans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber), // Amber for bold text
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      textSpans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return textSpans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BOOST',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black, // Pure black AppBar
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}