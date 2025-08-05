import 'package:flutter/material.dart';

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
  final List<ChatMessage> _messages = []; // Start with an empty list
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return; // Don't send empty messages

    setState(() {
      _messages.add(ChatMessage(text: text, sender: Sender.user));
    });
    _textController.clear();
    _scrollToBottom();

    // Simulate Aimmy's response after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Got it! I\'ll respond to: "$text". How else can I help?',
          sender: Sender.aimmy,
        ));
      });
      _scrollToBottom();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        title: const Text(
          'Aimmy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                    // Conditional content based on whether there are messages
                    if (_messages.isEmpty)
                      // *** MODIFIED THIS SECTION ***
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
                          crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center content
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
                            const SizedBox(height: 20.0), // Space between text and input field
                            SizedBox( // Input field for initial state, centered with question
                              width: MediaQuery.of(context).size.width * 0.85, // Same width as when chat active
                              child: _buildInputField(), // Re-use the input field widget
                            ),
                          ],
                        ),
                      )
                    else
                      // Chat messages list when active
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
                      ),
                    // If messages are present, show the input field below the chat.
                    // If messages are empty, the input field is already included in the centered Column above.
                    if (_messages.isNotEmpty)
                      Column( // Wrap the input field in a column to align it consistently
                        children: [
                          const SizedBox(height: 16.0), // Space between chat and input field
                          Align( // Still align to center for general chat state
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

  // --- Helper Widgets ---

  // Extracted the input field creation into a reusable widget
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
}