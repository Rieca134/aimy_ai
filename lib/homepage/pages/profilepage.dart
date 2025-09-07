import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aimy_ai/homepage/pages/sidepage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // State variables for profile data
  bool _isLoading = true;
  Map<String, dynamic> _profileData = {};
  String _error = '';

  // Controllers for the update text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _yearOfStudyController = TextEditingController();
  final TextEditingController _denominationController = TextEditingController();
  final TextEditingController _feeCategoryController = TextEditingController();
  final TextEditingController _postalAddressController = TextEditingController();

  final String _baseUrl = 'https://aimyai.inlakssolutions.com';
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    _fetchProfileData();
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _yearOfStudyController.dispose();
    _denominationController.dispose();
    _feeCategoryController.dispose();
    _postalAddressController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('authToken');

      if (authToken == null || authToken.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'Authentication token is missing. Please log in again.';
            _isLoading = false;
          });
        }
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Profile data received: $data');
        if (mounted) {
          setState(() {
            _profileData = data;
            _isLoading = false;
            _populateControllers();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Failed to load profile data: Status ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to connect to the server. Please check your network or try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _populateControllers() {
    _firstNameController.text = _profileData['first_name'] ?? '';
    _lastNameController.text = _profileData['last_name'] ?? '';
    _phoneNumberController.text = _profileData['phone_number'] ?? '';
    _yearOfStudyController.text = _profileData['year_of_study']?.toString() ?? '';
    _denominationController.text = _profileData['denomination'] ?? '';
    _feeCategoryController.text = _profileData['feeCategory'] ?? '';
    _postalAddressController.text = _profileData['postalAddress'] ?? '';
  }

  // --- START OF MODIFIED CODE ---
  Future<void> _uploadProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      // User canceled the image picking
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('authToken');

      if (authToken == null || authToken.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'Authentication token is missing.';
            _isLoading = false;
          });
        }
        return;
      }
      
      final uri = Uri.parse('$_baseUrl/auth/profile/image/');
      final request = http.MultipartRequest('PATCH', uri);
      request.headers['Authorization'] = 'Bearer $authToken';

      // Read the image file as bytes, which works on all platforms.
      final bytes = await image.readAsBytes();
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'profile_image', // The field name on the server
          bytes,
          filename: image.name, // The file name
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Profile image updated successfully.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully!')),
          );
        }
        await _fetchProfileData(); // Refresh profile data to show the new image
      } else {
        final errorData = json.decode(responseBody);
        final errorMessage = errorData['detail'] ?? 'Failed to update image.';
        print('Error uploading image: ${response.statusCode}, $errorMessage');
        if (mounted) {
          setState(() {
            _error = errorMessage;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Network error during image upload: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to upload image. Check your network connection.';
          _isLoading = false;
        });
      }
    }
  }
  // --- END OF MODIFIED CODE ---

  // New function to handle profile data update
  Future<void> _updateProfileData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('authToken');

      if (authToken == null || authToken.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'Authentication token is missing.';
            _isLoading = false;
          });
        }
        return;
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/auth/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'phone_number': _phoneNumberController.text.trim(),
          'year_of_study': int.tryParse(_yearOfStudyController.text.trim()) ?? 0,
          'denomination': _denominationController.text.trim(),
          'feeCategory': _feeCategoryController.text.trim(),
          'postalAddress': _postalAddressController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        print('Profile data updated successfully.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
        await _fetchProfileData(); // Refresh profile data to reflect changes
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Failed to update profile.';
        print('Error updating profile: ${response.statusCode}, $errorMessage');
        if (mounted) {
          setState(() {
            _error = errorMessage;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Network error during profile update: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to update profile. Check your network connection.';
          _isLoading = false;
        });
      }
    }
  }

  // ... (existing build methods)
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF8B0000),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF8B0000),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final String firstName = _profileData['first_name'] ?? '';
    final String lastName = _profileData['last_name'] ?? '';
    final String fullName = '$firstName $lastName'.trim();
    final String? profileImageUrl = _profileData['profile_image'];

    // Added code to handle the insecure HTTP URL
    String? safeProfileImageUrl;
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      safeProfileImageUrl = profileImageUrl.replaceFirst('http://', 'https://');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF8B0000),
      appBar: AppBar(
        title: const Text('Profile'),
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
      endDrawer: const SidePage(initialIndex: 2),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF8B0000),
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      // Use the safeProfileImageUrl here
                      backgroundImage: safeProfileImageUrl != null ? NetworkImage(safeProfileImageUrl) : null,
                      child: safeProfileImageUrl == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _uploadProfileImage,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: const Color(0xFF8B0000),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _profileData['email'] ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            _buildCustomTab(context, 'Personal', 0),
                            _buildCustomTab(context, 'Programme', 1),
                            _buildCustomTab(context, 'Contact', 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPersonalTabContent(),
                        _buildProgrammeTabContent(),
                        _buildContactTabContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTabContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoField(context, 'First Name', _profileData['first_name'] ?? 'N/A', showEditButton: true, onEdit: () => _showUpdateDialog(
            title: 'Update Personal Details',
            fields: {
              'First Name': _firstNameController,
              'Last Name': _lastNameController,
              'Phone Number': _phoneNumberController,
              'Year of Study': _yearOfStudyController,
            },
          )),
          _buildInfoField(context, 'Last Name', _profileData['last_name'] ?? 'N/A'),
          _buildInfoField(context, 'Student ID', _profileData['student_id'] ?? 'N/A'),
          _buildInfoField(context, 'Username', _profileData['username'] ?? 'N/A'),
          _buildInfoField(context, 'Gender', _profileData['gender'] ?? 'N/A'),
          _buildInfoField(context, 'Date of Birth', _profileData['dateOfBirth'] ?? 'N/A'),
          _buildInfoField(context, 'Passport Number', _profileData['passportNumber'] ?? 'N/A'),
          _buildInfoField(context, 'Country', _profileData['country'] ?? 'N/A'),
          _buildInfoField(context, 'Region', _profileData['region'] ?? 'N/A'),
          _buildInfoField(context, 'Religion', _profileData['religion'] ?? 'N/A'),
          _buildInfoField(context, 'Denomination/Group', _profileData['denomination'] ?? 'N/A', showEditButton: true, onEdit: () => _showUpdateDialog(
            title: 'Update Denomination',
            fields: {
              'Denomination/Group': _denominationController,
            },
          )),
        ],
      ),
    );
  }

  Widget _buildProgrammeTabContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoField(context, 'College', _profileData['college'] ?? 'N/A'),
          _buildInfoField(context, 'Year of Study', _profileData['year_of_study']?.toString() ?? 'N/A', showEditButton: true, onEdit: () => _showUpdateDialog(
            title: 'Update Year of Study',
            fields: {
              'Year of Study': _yearOfStudyController,
            },
          )),
          _buildInfoField(context, 'Department', _profileData['department']?['name'] ?? 'N/A'),
          _buildInfoField(context, 'Index Number', _profileData['indexNumber'] ?? 'N/A'),
          _buildInfoField(context, 'Programme Stream', _profileData['programmeStream'] ?? 'N/A'),
          _buildInfoField(context, 'Programme Option', _profileData['programmeOption'] ?? 'N/A'),
          _buildInfoField(context, 'Current Year', _profileData['currentYear'] ?? 'N/A'),
          _buildInfoField(context, 'Campus', _profileData['campus'] ?? 'N/A'),
          _buildInfoField(context, 'Fee Category', _profileData['feeCategory'] ?? 'N/A', showEditButton: true, onEdit: () => _showUpdateDialog(
            title: 'Update Fee Category',
            fields: {
              'Fee Category': _feeCategoryController,
            },
          )),
        ],
      ),
    );
  }

  Widget _buildContactTabContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoField(context, 'Email', _profileData['email'] ?? 'N/A'),
          _buildInfoField(context, 'School Email', _profileData['schoolEmail'] ?? 'N/A'),
          _buildInfoField(context, 'Personal Email', _profileData['personalEmail'] ?? 'N/A'),
          _buildInfoField(context, 'KNUST Mobile', _profileData['knustMobile'] ?? 'N/A'),
          _buildInfoField(context, 'Primary Personal Mobile', _profileData['primaryPersonalMobile'] ?? 'N/A', showEditButton: true, onEdit: () => _showUpdateDialog(
            title: 'Update Mobile Number',
            fields: {
              'Primary Personal Mobile': _phoneNumberController,
            },
          )),
          _buildInfoField(context, 'Alternate Personal Mobile', _profileData['alternatePersonalMobile'] ?? 'N/A'),
          _buildInfoField(context, 'Postal Address', _profileData['postalAddress'] ?? 'N/A', showEditButton: true, onEdit: () => _showUpdateDialog(
            title: 'Update Postal Address',
            fields: {
              'Postal Address': _postalAddressController,
            },
          )),
          _buildInfoField(context, 'Residential Address', _profileData['residentialAddress'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildCustomTab(BuildContext context, String text, int index) {
    final bool isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B0000) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8B0000),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value, {bool showEditButton = false, VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showEditButton)
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 25.0, thickness: 1.0, color: Colors.black12),
        ],
      ),
    );
  }

  // New method to show the update dialog
  void _showUpdateDialog({required String title, required Map<String, TextEditingController> fields}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields.entries.map((entry) {
                final label = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateProfileData();
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}