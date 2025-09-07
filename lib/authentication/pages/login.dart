import 'package:aimy_ai/authentication/pages/signuppage.dart';
import 'package:aimy_ai/homepage/pages/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// NOTE: You must replace this line with the correct path to your ProfileScreen.
// For example: `import 'package:aimy_ai/profile_page/profile_screen.dart';`
// Make sure this file exists and contains the ProfileScreen widget class.
// import 'package:your_app_name/profile_screen.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  // The login function that connects to the backend and saves the token
  Future<void> _login() async {
    // Basic validation to check if fields are empty
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter username, email, and password.';
      });
      return;
    }

    // Set loading state to true and clear any previous error messages
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // The backend API endpoints
    const String loginApiUrl = 'https://aimyai.inlakssolutions.com/auth/login/';
    const String profileApiUrl = 'https://aimyai.inlakssolutions.com/auth/profile/';

    try {
      final response = await http.post(
        Uri.parse(loginApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // The body of the request containing the user's credentials
        body: jsonEncode(<String, String>{
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      // Handle the response from the backend
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String? authToken = responseBody['access'] ?? responseBody['access_token'] ?? responseBody['token'];

        if (authToken != null && authToken.isNotEmpty) {
          // Get an instance of SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          // Save the token to local storage
          await prefs.setString('authToken', authToken);
          print('Token saved successfully: $authToken');
          
          String fullName = 'User';
          
          // ---- NEW CODE: Fetch profile data immediately after login ----
          final profileResponse = await http.get(
            Uri.parse(profileApiUrl),
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          );

          if (profileResponse.statusCode == 200) {
            final Map<String, dynamic> profileData = json.decode(profileResponse.body);
            
            // Get the full name
            final String firstName = profileData['first_name'] ?? '';
            final String lastName = profileData['last_name'] ?? '';
            String combinedName = '$firstName $lastName'.trim();
            if (combinedName.isNotEmpty) {
              fullName = combinedName;
            }
            
            // Get and save the profile image URL
            final String? profileImageUrl = profileData['profile_image'];
            if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
              await prefs.setString('profileImageUrl', profileImageUrl);
              print('Profile image URL saved: $profileImageUrl');
            } else {
              print('No profile image URL found in profile data.');
            }
          } else {
            print('Failed to fetch profile data: ${profileResponse.statusCode}');
          }
          // ---- END OF NEW CODE ----

          // Navigate to the HomeScreen upon successful login
          // The HomeScreen requires the fullName as a parameter.
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(fullName: fullName)),
            );
          }
        } else {
          // Handle case where token is missing from a successful response
          setState(() {
            _errorMessage = 'Login successful, but token was not received.';
          });
        }
      } else {
        // Handle failed login attempts
        print('Login failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorBody['message'] ?? 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      // Handle network or other exceptions
      print('Error during login: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      // Set loading state back to false
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F5FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                width: 200,
                height: 4,
                color: Colors.green,
              ),
              const SizedBox(height: 30),
              // Error Message display
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Username input field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Student ID',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your student ID',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              // Email input field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'KNUST Email Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password input field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.visiblePassword,
              ),

              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),

              // "Don't have an account?" text with "Sign up" link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}