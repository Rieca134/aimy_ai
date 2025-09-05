import 'package:aimy_ai/authentication/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Required for jsonEncode

// You can add a HomeScreen import here if you want to navigate there on success,
// but for a signup page, it's more common to navigate back to the login screen.
// import 'package:aimy_ai/homepage/pages/homescreen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for all the required text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _indexNumberController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _yearOfStudyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variable to show loading indicator
  bool _isLoading = false;
  // State variable to store and show error messages
  String? _errorMessage;

  // The sign-up function that connects to the backend
  Future<void> _signUp() async {
    // Basic validation to check if any field is empty
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _studentIdController.text.isEmpty ||
        _indexNumberController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _yearOfStudyController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all the fields.';
      });
      return;
    }

    // Set loading state to true and clear any previous error messages
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Replace this with your actual backend API endpoint for sign-up/registration
    const String apiUrl = 'https://aimyai.inlakssolutions.com/auth/signup/';

try {
  final int? departmentId = int.tryParse(_departmentController.text);
  final int? year = int.tryParse(_yearOfStudyController.text);

  // Validate department and year before sending request
  if (departmentId == null) {
    setState(() {
      _errorMessage = 'Please enter a valid department ID (numeric).';
    });
    return;
  }

  if (year == null || (year != 100 && year != 200 && year != 300 && year != 400)) {
    setState(() {
      _errorMessage = 'Please enter a valid year of study (e.g., 100, 200, 300, or 400).';
    });
    return;
  }

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'student_id': _studentIdController.text.trim(),
      'index_number': _indexNumberController.text.trim(),
      'department': departmentId,
      'year_of_study': year,
      'password': _passwordController.text.trim(),
    }),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    print('Sign up successful!');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up successful! Please log in.')),
      );
      Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const LoginPage()),
);
    }
  } else {
    print('Sign up failed: ${response.statusCode}');
    print('Response body: ${response.body}');
    final Map<String, dynamic> errorBody = jsonDecode(response.body);
    setState(() {
      _errorMessage = errorBody['errorMsg'] ?? 'Sign up failed. Please try again.';
    });
  }
} catch (e) {
  print('Error during sign up: $e');
  setState(() {
    _errorMessage = 'An error occurred. Please try again.';
  });
} finally {
  setState(() {
    _isLoading = false;
  });
}

  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed to free up memory
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _indexNumberController.dispose();
    _departmentController.dispose();
    _yearOfStudyController.dispose();
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
                'Create an Account',
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

              // First Name and Last Name in a Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hint: 'Enter your first name',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Enter your last name',
                    ),
                  ),
                ],
              ),

              // Email input field
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),

              // Student ID and Index Number in a Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _studentIdController,
                      label: 'Student ID',
                      hint: 'Enter your student ID',
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _indexNumberController,
                      label: 'Index Number',
                      hint: 'Enter your index number',
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              
              // Department and Year of Study in a Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _departmentController,
                      label: 'Department',
                      hint: 'Enter your department',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _yearOfStudyController,
                      label: 'Year of Study',
                      hint: 'Enter your year of study',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              // Password input field
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a password',
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),

              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
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
                          'Sign Up',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // "Already have an account?" text with "Sign in" link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const LoginPage()),
);
                    },
                    child: const Text(
                      "Sign In",
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

  // A helper function to build a text field with a label
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
