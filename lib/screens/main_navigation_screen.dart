import 'package:flutter/material.dart';
import '../utils/cooking_icons.dart';
import 'discover_screen.dart';
import 'pantry_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DiscoverScreen(),
    PantryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFF5722).withValues(alpha: 0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(CookingIcons.compass, color: Color(0xFF64748B)),
              selectedIcon: Icon(CookingIcons.compass, color: Color(0xFFFF5722)),
              label: 'Keşfet',
            ),
            NavigationDestination(
              icon: Icon(CookingIcons.pantry, color: Color(0xFF64748B)),
              selectedIcon: Icon(CookingIcons.pantry, color: Color(0xFF059669)),
              label: 'Kilerim',
            ),
          ],
        ),
      ),
    );
  }
}
