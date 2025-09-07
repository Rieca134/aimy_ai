import 'package:aimy_ai/homepage/pages/sidepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum MessageType { text, file }

class ChatMessage {
  final String text;
  final Sender sender;
  final MessageType type;
  final String? filePath;

  ChatMessage({
    required this.text,
    required this.sender,
    this.type = MessageType.text,
    this.filePath,
  });
}

// Enum to differentiate between message senders
enum Sender { user, aimmy }

class AimmyChatbotScreen extends StatefulWidget {
  @override
  _AimmyChatbotScreenState createState() => _AimmyChatbotScreenState();
}

class _AimmyChatbotScreenState extends State<AimmyChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAimmyTyping = false;
  PlatformFile? _selectedFile; // Stores the selected file object
  final ValueNotifier<String?> _selectedFileName = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _selectedFileName.dispose();
    super.dispose();
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null) {
      _handleApiError('Error: No file selected for upload.');
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null || token.isEmpty) {
        _handleApiError('Error: No authentication token found. Please log in again.');
        return null;
      }

      final uri = Uri.parse("https://aimyai.inlakssolutions.com/aimy/documents/");
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({'Authorization': 'Bearer $token'});

      final fileName = _selectedFile!.name;
      final mimeType = fileName.endsWith('.pdf')
          ? MediaType('application', 'pdf')
          : MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');

      if (kIsWeb) {
        if (_selectedFile!.bytes == null) {
          _handleApiError('Error: File bytes are null on web.');
          return null;
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _selectedFile!.bytes!,
            filename: fileName,
            contentType: mimeType,
          ),
        );
      } else {
        if (_selectedFile!.path == null) {
          _handleApiError('Error: File path is null on mobile.');
          return null;
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _selectedFile!.path!,
            filename: fileName,
            contentType: mimeType,
          ),
        );
      }
      
      request.fields['title'] = fileName;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return responseBody['document']['id'].toString();
      } else {
        final errorBody = jsonDecode(response.body);
        _handleApiError('Error: File upload failed. Status: ${response.statusCode}. Reason: ${errorBody['message'] ?? 'Unknown error'}.');
        return null;
      }
    } catch (e) {
      _handleApiError('Error: Failed to upload file. Please check your network.');
      return null;
    }
  }

void _sendMessage({String? text}) async {
  if ((text == null || text.trim().isEmpty) && _selectedFile == null) {
    return;
  }

  String? documentId;
    
  if (_selectedFile != null) {
    String? uploadedDocumentId = await _uploadFile();
    if (uploadedDocumentId != null) {
      documentId = uploadedDocumentId;
      // Add a brief delay to give the API time to process the document
      // Adjust the duration as needed based on your API's performance
      await Future.delayed(Duration(seconds: 5)); 
    }
  }

  setState(() {
    if (_selectedFile != null) {
      _messages.add(
        ChatMessage(
          text: 'File uploaded: ${_selectedFileName.value!}',
          sender: Sender.user,
          type: MessageType.file,
          filePath: _selectedFile!.path,
        ),
      );
    }
    _messages.add(ChatMessage(text: text ?? '', sender: Sender.user));
    _textController.clear();
    _isAimmyTyping = true;
  });
  _scrollToBottom();
    
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      _handleApiError('Error: No authentication token found. Please log in again.');
      return;
    }

    final uri = Uri.parse("https://aimyai.inlakssolutions.com/aimy/chat/ask/");
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    
    // Create a dynamic body based on whether a document was uploaded
    Map<String, dynamic> bodyData = {
      'question': text ?? '',
      'session_id': '1',
      'max_results': '5',
      'temperature': '0.7',
    };
    
    if (documentId != null) {
      bodyData['document_id'] = int.parse(documentId);
    }

    final body = jsonEncode(bodyData);

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final aimmyResponse =
          responseBody['data']?['answer'] ??
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
      final errorBody = jsonDecode(response.body);
      _handleApiError(
          'Error: Could not get a response. Status: ${response.statusCode}. Reason: ${errorBody['message'] ?? 'Unknown error'}.');
    }
  } catch (e) {
    _handleApiError('Error: Failed to connect to chatbot. Please check your network.');
  }
  _scrollToBottom();

  _removeSelectedFile();
}

  void _handleApiError(String message) {
    setState(() {
      _isAimmyTyping = false;
      _messages.add(ChatMessage(
        text: message,
        sender: Sender.aimmy,
      ));
    });
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null) {
      _selectedFile = result.files.first;
      _selectedFileName.value = _selectedFile!.name;
      _textController.clear();
    }
  }

  void _removeSelectedFile() {
    setState(() {
      _selectedFile = null;
      _selectedFileName.value = null;
      _textController.clear();
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
        title: const Text('Aimmy'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
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
                          itemCount: _messages.length + (_isAimmyTyping ? 1 : 0),
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

//... other methods and code

Widget _buildInputField() {
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF8B0000),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: IconButton(
          icon: const Icon(Icons.attach_file, color: Colors.white),
          onPressed: _pickFile,
        ),
      ),
      const SizedBox(width: 8.0),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: _selectedFileName,
              builder: (context, fileName, child) {
                if (fileName != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getFileIcon(fileName), color: Colors.black54),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Text(
                              fileName,
                              style: TextStyle(fontSize: 14.0, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          GestureDetector(
                            onTap: _removeSelectedFile,
                            child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SizedBox.shrink(); // Hide the widget when no file is selected
              },
            ),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: _selectedFile != null ? 'Add a question for the file...' : 'Ask me anything',
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
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.text,
              onSubmitted: (text) => _sendMessage(text: text),
            ),
          ],
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
          onPressed: () => _sendMessage(text: _textController.text),
        ),
      ),
    ],
  );
}

//... other methods and code

  bool _isImageFile(String fileName) {
    final lowerCaseName = fileName.toLowerCase();
    return lowerCaseName.endsWith('.png') ||
        lowerCaseName.endsWith('.jpg') ||
        lowerCaseName.endsWith('.jpeg');
  }

  IconData _getFileIcon(String fileName) {
    final lowerCaseName = fileName.toLowerCase();
    if (lowerCaseName.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (lowerCaseName.endsWith('.docx')) {
      return Icons.description;
    } else if (_isImageFile(fileName)) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bool isUser = message.sender == Sender.user;
    final Color bubbleColor = isUser ? const Color(0xFFFCE4EC) : Colors.grey[100]!;
    final Color textColor = isUser ? Colors.black87 : Colors.black87;
    final BorderRadius borderRadius = BorderRadius.circular(15.0);

    IconData fileIcon = Icons.insert_drive_file;
    if (message.type == MessageType.file && message.filePath != null) {
      if (message.filePath!.toLowerCase().endsWith('.pdf')) {
        fileIcon = Icons.picture_as_pdf;
      } else if (message.filePath!.toLowerCase().endsWith('.docx')) {
        fileIcon = Icons.description;
      }
    }

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
            if (message.type == MessageType.file && isUser)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(fileIcon, color: Colors.black54),
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      message.text,
                      style: TextStyle(color: textColor, fontSize: 16.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else
              Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 16.0),
              ),
          ],
        ),
      ),
    );
  }

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