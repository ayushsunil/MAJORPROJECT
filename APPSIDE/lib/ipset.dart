import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boost/login.dart';




class ipset extends StatefulWidget {
  const ipset({super.key});

  @override
  State<ipset> createState() => _ipsetstate();
}

class _ipsetstate extends State<ipset> {
  final TextEditingController ipController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("BOOST"),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(2),
                child: TextField(

                  controller: ipController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "IP Address",
                      hintText: "Enter a valid ip address"),


                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async{
                    String ip=ipController.text.toString();
                    final sh = await SharedPreferences.getInstance();
                    sh.setString("url", "http://"+ip+":5000/");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
                  },
                  child: const Icon(Icons.key),

                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.amber, // Use a proper color value (e.g., Hex or RGB)
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}