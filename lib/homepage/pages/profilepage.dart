import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aimy_ai/homepage/pages/sidepage.dart';

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

  // Placeholder for the backend URL. The auth token will be retrieved from storage.
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

  // Fetch profile data from the backend using an HTTP request
  Future<void> _fetchProfileData() async {
    try {
      // Retrieve the authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('authToken');

      // If we don't have an auth token, we can't proceed
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
          });
        }
      } else {
        // Handle API errors based on status code
        if (mounted) {
          setState(() {
            _error = 'Failed to load profile data: Status ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Handle network or other exceptions
      if (mounted) {
        setState(() {
          _error = 'Failed to connect to the server. Please check your network or try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(() {}); // Remove listener before disposing
    _tabController.dispose();
    super.dispose();
  }

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

    // Extract names for the profile header. Using first_name and last_name as per the schema.
    final String firstName = _profileData['first_name'] ?? '';
    final String lastName = _profileData['last_name'] ?? '';
    final String fullName = '$firstName $lastName'.trim();

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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16.0),
                // User Name and Details
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

  // --- Helper Methods for Building Tab Contents ---

  Widget _buildPersonalTabContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using first_name and last_name as per API schema
          _buildInfoField(context, 'First Name', _profileData['first_name'] ?? 'N/A'),
          _buildInfoField(context, 'Last Name', _profileData['last_name'] ?? 'N/A'),
          _buildInfoField(context, 'Student ID', _profileData['student_id'] ?? 'N/A'),
          _buildInfoField(context, 'Username', _profileData['username'] ?? 'N/A'),
          _buildInfoField(context, 'Gender', _profileData['gender'] ?? 'N/A'),
          _buildInfoField(context, 'Date of Birth', _profileData['dateOfBirth'] ?? 'N/A'),
          _buildInfoField(context, 'Passport Number', _profileData['passportNumber'] ?? 'N/A'),
          _buildInfoField(context, 'Country', _profileData['country'] ?? 'N/A'),
          _buildInfoField(context, 'Region', _profileData['region'] ?? 'N/A'),
          _buildInfoField(context, 'Religion', _profileData['religion'] ?? 'N/A'),
          _buildInfoField(context, 'Denomination/Group', _profileData['denomination'] ?? 'N/A', showEditButton: true),
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
          // Displaying college and year of study from the schema
          _buildInfoField(context, 'College', _profileData['college'] ?? 'N/A'),
          _buildInfoField(context, 'Year of Study', _profileData['year_of_study']?.toString() ?? 'N/A'),
          // Accessing the nested department name
          _buildInfoField(context, 'Department', _profileData['department']?['name'] ?? 'N/A'),
          _buildInfoField(context, 'Index Number', _profileData['indexNumber'] ?? 'N/A'),
          _buildInfoField(context, 'Programme Stream', _profileData['programmeStream'] ?? 'N/A'),
          _buildInfoField(context, 'Programme Option', _profileData['programmeOption'] ?? 'N/A'),
          _buildInfoField(context, 'Current Year', _profileData['currentYear'] ?? 'N/A'),
          _buildInfoField(context, 'Campus', _profileData['campus'] ?? 'N/A'),
          _buildInfoField(context, 'Fee Category', _profileData['feeCategory'] ?? 'N/A', showEditButton: true),
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
          _buildInfoField(context, 'Primary Personal Mobile', _profileData['primaryPersonalMobile'] ?? 'N/A'),
          _buildInfoField(context, 'Alternate Personal Mobile', _profileData['alternatePersonalMobile'] ?? 'N/A'),
          _buildInfoField(context, 'Postal Address', _profileData['postalAddress'] ?? 'N/A', showEditButton: true),
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

  Widget _buildInfoField(BuildContext context, String label, String value, {bool showEditButton = false}) {
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
                    onPressed: () {
                      print('Edit button tapped for $label');
                    },
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
}
