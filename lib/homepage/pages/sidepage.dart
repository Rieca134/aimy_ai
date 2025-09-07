import 'package:aimy_ai/homepage/pages/aimmy.dart';
import 'package:aimy_ai/homepage/pages/homescreen.dart';
import 'package:aimy_ai/homepage/pages/profilepage.dart';
import 'package:aimy_ai/homepage/pages/resultscreen.dart';
import 'package:flutter/material.dart';

class SidePage extends StatefulWidget {
  // Add a parameter to store the index of the current page.
  final int initialIndex;
  const SidePage({super.key, required this.initialIndex});

  @override
  _SidePageState createState() => _SidePageState();
}

class _SidePageState extends State<SidePage> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> _drawerItems = [
    {'title': 'Home', 'icon': Icons.home},
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
    // Use the value passed to the widget.
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF8B0000),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
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
                  const SizedBox(height: 10.0),

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
              index: -1,
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
          Navigator.pop(context);
          print('Tapped on Logout');
        } else {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
          if (title == 'Profile') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          } else if (title == 'Home') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen(fullName: 'Student Name')),
            );
          } else if (title == 'Aimmy') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AimmyChatbotScreen()),
            );
              } else if (title == 'Results') { // Add this new condition
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ResultsScreen()),
      );
    }
          print('Tapped on $title (Index: $index)');
        }
      },
    );
  }
}