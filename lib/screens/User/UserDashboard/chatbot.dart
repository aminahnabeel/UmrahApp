import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  TextEditingController controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  // 🔹 API Call Function
  Future<String> sendMessageToBot(String message) async {
    final url = Uri.parse("http://192.168.1.5:5000/api/chat");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "language": "en"
        }),
      );

      final data = jsonDecode(response.body);

      return data['response'] ?? "No response from bot";
    } catch (e) {
      return "Error: $e";
    }
  }

  // 🔹 Send Message
  void sendMessage() async {
    String userMsg = controller.text.trim();

    if (userMsg.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userMsg});
      isLoading = true;
    });

    controller.clear();

    // 🔹 Bot reply
    String botReply = await sendMessageToBot(userMsg);

    setState(() {
      isLoading = false;
      messages.add({"role": "bot", "text": botReply});
    });
  }

  // 🔹 Chat Bubble UI
  Widget buildMessage(Map<String, String> msg) {
    bool isUser = msg["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg["text"]!,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Umrah Chatbot 🤖"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 Messages List
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          // 🔹 Typing Indicator
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Bot is typing..."),
              ),
            ),

          // 🔹 Input Field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Ask something...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}