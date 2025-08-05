import 'package:flutter/material.dart';

class SidePage extends StatefulWidget {
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
    );
  }

  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required int index,
    required bool isSelected,
  }) {
    // Note: tileColor is now transparent here because the white background
    // for selected items is handled by the wrapping Container in the build method.
    return ListTile(
      tileColor: Colors.transparent, // Always transparent here, background handled by parent
      leading: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 18.0,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        // Navigator.pop(context); // Close the drawer
        print('Tapped on $title (Index: $index)');
      },
    );
  }
}

// To use this in your Scaffold:
// class MyScaffoldScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your App Title'),
//         backgroundColor: const Color(0xFF8B0000),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       drawer: HomeScreenDrawer(),
//       body: const Center(
//         child: Text('Main Content Area'),
//       ),
//     );
//   }
// }