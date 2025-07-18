import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({"role": "user", "message": message});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? url = prefs.getString('url');

      if (url == null) {
        Fluttertoast.showToast(msg: "API URL not configured.");
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.post(
        Uri.parse('$url/chatbot_response'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _messages.add({"role": "bot", "message": data['response']});
        });
      } else {
        setState(() {
          _messages.add({
            "role": "bot",
            "message": "Error: ${response.statusCode}\n${response.body}"
          });
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add({
          "role": "bot",
          "message": "Connection error: ${e.toString()}"
        });
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<TextSpan> _parseMessage(String text) {
    final List<TextSpan> spans = [];
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');
    final bulletPattern = RegExp(r'^\s*[-•*]\s', multiLine: true);
    int currentIndex = 0;

    // Handle bold formatting
    for (final match in boldPattern.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      String remainingText = text.substring(currentIndex);

      // Simple bullet point detection
      if (bulletPattern.hasMatch(remainingText)) {
        spans.add(TextSpan(
          text: remainingText,
          style: TextStyle(height: 1.5),
        ));
      } else {
        spans.add(TextSpan(text: remainingText));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI ASSISTANT', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/newhome.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _messages.length) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final message = _messages[index];
                  final isUser = message['role'] == "user";
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.blue.withOpacity(0.8)
                              : Colors.grey[200]?.withOpacity(0.9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isUser ? 12 : 0),
                            topRight: Radius.circular(isUser ? 0 : 12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: SelectableText.rich(
                          TextSpan(children: _parseMessage(message['message'] ?? '')),
                          style: TextStyle(
                            fontSize: 16,
                            color: isUser ? Colors.white : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.black.withOpacity(0.7),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your fitness question...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (text) {
                          if (text.isNotEmpty) sendMessage(text);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          sendMessage(_controller.text);
                        }
                      },
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