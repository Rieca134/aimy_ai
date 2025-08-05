import 'package:aimy_ai/homepage/pages/profilepage.dart';
import 'package:flutter/material.dart';

// This is the new page the side menu will navigate to.
// The user has provided a new implementation for this Drawer.
class SidePage extends StatefulWidget {
  const SidePage({super.key});

  @override
  _SidePageState createState() => _SidePageState();
}

class _SidePageState extends State<SidePage> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> _drawerItems = [
    {'title': 'Aimmy', 'icon': Icons.chat_bubble},
    {'title': 'Profile', 'icon': Icons.person},
    {'title': 'Registration', 'icon': Icons.app_registration},
    {'title': 'Results', 'icon': Icons.grade},
    {'title': 'Fees', 'icon': Icons.money},
    {'title': 'Timetable', 'icon': Icons.calendar_today},
    {'title': 'Lecturer Assessment', 'icon': Icons.assignment},
    {'title': 'Student\'s Guide', 'icon': Icons.book},
    {'title': 'Counselling Centre', 'icon': Icons.people},
    {'title': 'Notifications', 'icon': Icons.notifications},
    {'title': 'Downloads', 'icon': Icons.download},
    {'title': 'Settings', 'icon': Icons.settings},
    {'title': 'Help', 'icon': Icons.help},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0; // Set 'Aimmy' as the initially active item
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF8B0000), // Dark red background
        child: Column( // Use a Column to place the list and the logout button at the bottom
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  // Drawer header
                  Container(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 20.0, left: 16.0),
                    child: const Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0), // Some space below "Home"

                  // Build all dynamic drawer items
                  ..._drawerItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> item = entry.value;

                    final bool isSelected = _selectedIndex == index;
                    final bool isDividerTarget = item['title'] == 'Settings';

                    Widget currentItemWidget = _buildDrawerItem(
                      title: item['title'],
                      icon: item['icon'],
                      index: index,
                      isSelected: isSelected,
                    );

                    // If selected, wrap the ListTile in a Container with white background and padding
                    if (isSelected) {
                      currentItemWidget = Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: currentItemWidget, // The ListTile itself
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (isDividerTarget)
                          const Divider(color: Colors.white54, height: 40.0),
                        currentItemWidget, // This will be either the padded white Container or just the ListTile
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            // Logout Button at the bottom
            const Divider(color: Colors.white54, height: 40.0),
            _buildDrawerItem(
              title: 'Logout',
              icon: Icons.logout,
              index: -1, // Use a unique index for the logout item
              isSelected: false,
              textColor: Colors.white,
              iconColor: Colors.white70,
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required int index,
    required bool isSelected,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      tileColor: Colors.transparent,
      leading: Icon(
        icon,
        color: isSelected ? Colors.black : iconColor ?? Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : textColor ?? Colors.white,
          fontSize: 18.0,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      onTap: () {
        // Handle navigation based on the item tapped
        if (index == -1) {
          // Handle logout
          Navigator.pop(context); // Close the drawer
          print('Tapped on Logout');
          // You can add your logout logic here.
        } else {
          // Update the selected index for the active item styling
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); // Close the drawer after a selection

          // Navigate to a new page if the profile item is selected
          if (title == 'Profile') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
          print('Tapped on $title (Index: $index)');
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  // A property to hold the full name of the logged-in user
  final String fullName;

  const HomeScreen({super.key, required this.fullName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    // Calculate the greeting when the widget is first created
    _getGreeting();
  }

  // Helper method to determine the appropriate greeting based on the time of day
  void _getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 12) {
      setState(() {
        _greeting = 'Good Morning';
      });
    } else if (hour < 17) {
      setState(() {
        _greeting = 'Good Afternoon';
      });
    } else {
      setState(() {
        _greeting = 'Good Evening';
      });
    }
  }

  // Helper methods for action cards and trending images
  Widget _buildActionCard(String title, Color color) {
    return GestureDetector(
      onTap: () {
        // Implement what happens when this card is tapped
      },
      child: Container(
        width: 120, // Adjust width as needed
        height: 90, // Adjust height as needed
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000), // Set Scaffold background to red
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 30, // Increased font size for prominence
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon press
              print('Notification icon pressed');
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const SidePage(), // Use the new SidePage as an endDrawer
      body: SafeArea( // Use SafeArea to avoid content overlapping status bar/notch
        child: Column(
          children: <Widget>[
            // The body content is now a white section below the AppBar
            Expanded(
              child: Container(
                width: double.infinity, // Ensures it takes full width
                decoration: const BoxDecoration(
                  color: Colors.white, // The white background for the content
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0), // Curved top-left border
                    topRight: Radius.circular(30.0), // Curved top-right border
                  ),
                ),
                child: SingleChildScrollView( // Keep SingleChildScrollView inside for its content
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dynamic Greeting section
                        Text(
                          _greeting,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.fullName, // Display the user's full name
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Your next class section
                        const Text(
                          'Your next class',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F5), // Light pink background
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Your next class will appear here.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // What would you like to do? section
                        const Text(
                          'What would you like to do?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildActionCard('check Results', const Color(0xFFFFF0F5)),
                              const SizedBox(width: 15),
                              _buildActionCard('Pay Fees', const Color(0xFFFFF0F5)),
                              const SizedBox(width: 15),
                              _buildActionCard('Register Courses', const Color(0xFFFFF0F5)),
                              const SizedBox(width: 15),
                              _buildActionCard('Hi Aimmy', const Color(0xFFFFF0F5)), // Assuming similar card
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // What's trending? section
                        const Text(
                          "what's trending?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // _buildTrendingImage('assets/trending1.png'), // Replace with your image asset
                        // const SizedBox(height: 20),
                        // _buildTrendingImage('assets/trending2.png'), // Replace with your image asset
                        // const SizedBox(height: 20), // Add some bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
