import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/cooking_icons.dart';
import '../providers/locale_provider.dart';
import '../providers/discover_provider.dart';
import 'discover_screen.dart';
import 'pantry_screen.dart';
import 'account_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DiscoverScreen(),
    PantryScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

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
            if (index == _currentIndex) {
              if (index == 0) {
                // Re-tapping Discover tab scrolls to top
                ref.read(discoverScrollToTopProvider.notifier).trigger();
              }
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFF5722).withValues(alpha: 0.15),
          destinations: [
            NavigationDestination(
              icon: const Icon(CookingIcons.compass, color: Color(0xFF64748B)),
              selectedIcon: const Icon(CookingIcons.compass, color: Color(0xFFFF5722)),
              label: strings.tabDiscover,
            ),
            NavigationDestination(
              icon: const Icon(CookingIcons.pantry, color: Color(0xFF64748B)),
              selectedIcon: const Icon(CookingIcons.pantry, color: Color(0xFF059669)),
              label: strings.tabPantry,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
              selectedIcon: const Icon(Icons.person_rounded, color: Color(0xFFFF5722)),
              label: strings.tabAccount,
            ),
          ],
        ),
      ),
    );
  }
}

