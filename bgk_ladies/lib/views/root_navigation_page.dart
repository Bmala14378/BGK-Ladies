import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

// Your Views
import 'package:bgk_ladies/views/dashboard_view.dart';
import 'package:bgk_ladies/views/auth/profile_view.dart';

class RootNavigationPage extends StatefulWidget {
  const RootNavigationPage({super.key});

  @override
  State<RootNavigationPage> createState() => _RootNavigationPageState();
}

class _RootNavigationPageState extends State<RootNavigationPage> {
  // We manage the state with a single index:
  // 0 = Dashboard (Home), 1 = Reports (Left Tab), 2 = Profile (Right Tab)
  int _selectedIndex = 0;

  // The actual screens
  final List<Widget> _views = [
    const DashboardView(),
    const Center(
      child: Text("Reports View Coming Soon", style: TextStyle(fontSize: 18)),
    ),
    const ProfileView(),
  ];

  // The icons for the bottom nav bar (Left and Right of the notch)
  final List<IconData> iconList = [
    Icons.bar_chart_rounded, // Index 0 in the Nav Bar
    Icons.person_outline_rounded, // Index 1 in the Nav Bar
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves the state of the pages when switching tabs
      body: IndexedStack(index: _selectedIndex, children: _views),

      // The Center "Home" Button
      floatingActionButton: FloatingActionButton(
        shape:
            const CircleBorder(), // Gives it a nice circular shape to fit the notch
        backgroundColor: _selectedIndex == 0
            ? Colors.blueAccent
            : Colors.grey.shade300,
        elevation: _selectedIndex == 0
            ? 4
            : 0, // Flatten it slightly if not active
        onPressed: () {
          setState(() {
            _selectedIndex = 0; // Switch to Dashboard
          });
        },
        child: Icon(
          Icons.home_rounded,
          color: _selectedIndex == 0 ? Colors.white : Colors.grey.shade700,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // The Animated Bottom Bar
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: const Color.fromARGB(
          167,
          225,
          129,
          241,
        ).withAlpha(100),
        icons: iconList,
        // If Home (0) is selected, we fake the active index and just change the color to hide it
        activeIndex: _selectedIndex == 2 ? 1 : 0,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 20,
        rightCornerRadius: 20,

        // Visual styling
        activeColor: _selectedIndex == 0 ? Colors.grey[200] : Colors.blueAccent,
        inactiveColor: Colors.grey[200],
        iconSize: 28,

        // Handle Tab Clicks
        onTap: (index) {
          setState(() {
            // Map the Nav Bar index (0 or 1) to our View index (1 or 2)
            _selectedIndex = index == 0 ? 1 : 2;
          });
        },
      ),
    );
  }
}
