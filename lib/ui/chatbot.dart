import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String apiUrl = 'https://sound-prompt-crawdad.ngrok-free.app/send_message';

  @override
  void initState() {
    super.initState();
    _sendWelcomeMessage();
  }

  void _sendWelcomeMessage() {
    setState(() {
      _messages.add({
        'sender': 'bot',
        'text': 'Selamat datang di PovertyLens! Ada yang bisa kami bantu?',
      });
    });
  }

  void sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isNotEmpty) {
      setState(() {
        _messages.add({'sender': 'user', 'text': userInput});
      });

      _controller.clear();

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'message': userInput}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final botResponse = responseData['response'] ?? 'Error: Empty response from bot';

          setState(() {
            _messages.add({'sender': 'bot', 'text': botResponse});
          });
        } else {
          setState(() {
            _messages.add({'sender': 'bot', 'text': 'Error: Unable to reach the server.'});
          });
        }
      } catch (e) {
        setState(() {
          _messages.add({'sender': 'bot', 'text': 'Error: Network issue. Please try again.'});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(),
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          )),
          backgroundColor: const Color.fromARGB(255, 208, 232, 197),
          title: const Text(
            'PovertyBot',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, 
              ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
          SizedBox(height: 64,)
        ],
      ),
    );
  }
}
