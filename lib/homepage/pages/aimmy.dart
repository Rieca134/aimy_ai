import 'package:aimy_ai/homepage/pages/sidepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // Import this to encode/decode JSON
import 'package:shared_preferences/shared_preferences.dart';

// Enum to differentiate between message senders
enum Sender { user, aimmy }

// Simple data model for a chat message
class ChatMessage {
  final String text;
  final Sender sender;

  ChatMessage({required this.text, required this.sender});
}

class AimmyChatbotScreen extends StatefulWidget {
  @override
  _AimmyChatbotScreenState createState() => _AimmyChatbotScreenState();
}

class _AimmyChatbotScreenState extends State<AimmyChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAimmyTyping = false; // New state variable for the typing indicator

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

 // --- MODIFIED _sendMessage FUNCTION WITH AUTH TOKEN ---
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add the user's message to the list
    setState(() {
      _messages.add(ChatMessage(text: text, sender: Sender.user));
      _textController.clear();
      _isAimmyTyping = true;
    });
    _scrollToBottom();

    try {
      const String chatEndpoint = "https://aimyai.inlakssolutions.com/aimy/chat/ask/";

      // 2. Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null || token.isEmpty) {
        setState(() {
          _isAimmyTyping = false;
          _messages.add(ChatMessage(
            text: 'Error: No authentication token found. Please log in again.',
            sender: Sender.aimmy,
          ));
        });
        return;
      }

      final body = {
        'question': text,
        'session_id': 1,
        'document_id': 0,
        'max_results': 5,
        'temperature': 0.7,
      };

      print("➡️ Sending request: $body with token: $token");

      final response = await http.post(
        Uri.parse(chatEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 🔑 Add auth header here
        },
        body: jsonEncode(body),
      );

      print("⬅️ Status: ${response.statusCode}");
      print("⬅️ Body: ${response.body}");

if (response.statusCode == 200) {
  final responseBody = jsonDecode(response.body);

  // Extract from the nested structure
  final aimmyResponse =
      responseBody['data']?['answer'] ?? // ✅ answer is inside data
      responseBody['response'] ??
      responseBody['answer'] ??
      responseBody['message'] ??
      'Error: Unexpected API response.';

  setState(() {
    _isAimmyTyping = false;
    _messages.add(ChatMessage(
      text: aimmyResponse.toString(),
      sender: Sender.aimmy,
    ));
  });
      } else {
        setState(() {
          _isAimmyTyping = false;
          _messages.add(ChatMessage(
            text: 'Error: Could not get a response. Status: ${response.statusCode}',
            sender: Sender.aimmy,
          ));
        });
      }
    } catch (e) {
      setState(() {
        _isAimmyTyping = false;
        _messages.add(ChatMessage(
          text: 'Error: Failed to connect to Aimmy. Please check your network.',
          sender: Sender.aimmy,
        ));
      });
    }
    _scrollToBottom();
  }


  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // --- MODIFIED build METHOD to include the typing indicator ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000),
           appBar: AppBar(
        title: const Text('Aimmy'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          // NEW: Add the Builder to open the endDrawer
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      // NEW: Use the reusable SidePage widget
      endDrawer: const SidePage(initialIndex: 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_messages.isEmpty)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'What can I help you with?',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: _buildInputField(),
                            ),
                          ],
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length + (_isAimmyTyping ? 1 : 0), // Add 1 for the typing indicator
                          itemBuilder: (context, index) {
                            if (index == _messages.length && _isAimmyTyping) {
                              return _buildTypingIndicator();
                            }
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
                      ),
                    if (_messages.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 16.0),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: _buildInputField(),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets (Unchanged) ---
  Widget _buildInputField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Ask me anything',
              hintStyle: TextStyle(color: Colors.grey[500]),
              fillColor: Colors.grey[50],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF8B0000), width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            ),
            maxLines: null,
            keyboardType: TextInputType.text,
            onSubmitted: _sendMessage,
          ),
        ),
        const SizedBox(width: 8.0),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8B0000),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () => _sendMessage(_textController.text),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // ... (This widget remains the same as your original code) ...
    final bool isUser = message.sender == Sender.user;
    final Color bubbleColor = isUser ? const Color(0xFFFCE4EC) : Colors.grey[100]!;
    final Color textColor = isUser ? Colors.black87 : Colors.black87;
    final BorderRadius borderRadius = BorderRadius.circular(15.0);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius.copyWith(
            topLeft: isUser ? borderRadius.topLeft : Radius.zero,
            bottomRight: isUser ? Radius.zero : borderRadius.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'AIMMY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW FEATURE: Typing Indicator Widget ---
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[100]!,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Text('Aimmy is typing...', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
      ),
    );
  }
}