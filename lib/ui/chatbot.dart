import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  final String apiUrl = 'https://povertylens.my.id';

  @override
  void initState() {
    super.initState();
    sendWelcomeMessage();
  }

  List<Map<String, String>> addWelcomeMessage(
      List<Map<String, String>> messages) {
    messages.add({
      'sender': 'bot',
      'text': 'Selamat datang di PovertyLens! Ada yang bisa kami bantu?',
    });
    return messages;
  }

  void sendWelcomeMessage() {
    setState(() {
      messages = addWelcomeMessage(messages);
    });
  }

  void sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isNotEmpty) {
      setState(() {
        messages.add({'sender': 'user', 'text': userInput});
      });

      _controller.clear();

      try {
        final response = await http.get(
          Uri.parse(
              '$apiUrl/send_message?msg=${Uri.encodeComponent(userInput)}'),
        );

        if (response.statusCode == 200) {
          final botResponse =
              response.body; // Backend mengembalikan response sebagai string
          setState(() {
            messages.add({'sender': 'bot', 'text': botResponse});
          });
        } else {
          setState(() {
            messages.add({
              'sender': 'bot',
              'text': 'Error: Unable to reach the server.'
            });
          });
        }
      } catch (e) {
        setState(() {
          messages.add({
            'sender': 'bot',
            'text': 'Error: Network issue. Please try again.'
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          backgroundColor: const Color.fromARGB(255, 22, 163, 74),
          title: const Text(
            'PovertyBot',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.white
                          : Color.fromARGB(255, 141, 255, 183),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(255, 141, 255, 183),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 0)),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: TextStyle(
                          color: isUser ? Colors.black : Colors.black),
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
                        borderSide: BorderSide(color: Color.fromARGB(255, 141, 255, 183),)
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 141, 255, 183),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 72,
          )
        ],
      ),
    );
  }
}
