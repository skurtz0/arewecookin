import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/cooking_icons.dart';
import '../providers/locale_provider.dart';
import '../providers/discover_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/shopping_list_provider.dart';
import 'discover_screen.dart';
import 'pantry_screen.dart';
import 'account_screen.dart';
import 'shopping_list_screen.dart';
import 'social_screen.dart';

/// From this width on, the tabs move to a side rail and the content is centred.
const double wideLayoutBreakpoint = 840;

/// Widest the page content gets, so lists and forms stay readable on big screens.
const double maxContentWidth = 1200;

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
    ShoppingListScreen(),
    SocialScreen(),
    AccountScreen(),
  ];

  void _select(int index) {
    if (index == _currentIndex) {
      if (index == 0) {
        // Re-tapping Discover tab scrolls to top
        ref.read(discoverScrollToTopProvider.notifier).trigger();
      }
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final openItems = ref.watch(shoppingListProvider).where((e) => !e.done).length;
    final pantryCount = ref.watch(pantryProvider.select((p) => p.selectedKeys.length));
    const grey = Color(0xFF64748B);
    const orange = Color(0xFFFF5722);
    const green = Color(0xFF059669);

    // One list feeds both the bottom bar and the side rail.
    final tabs = <_Tab>[
      _Tab(
        key: 'tab_discover_${strings.locale}',
        icon: const Icon(CookingIcons.compass, color: grey),
        selectedIcon: const Icon(CookingIcons.compass, color: orange),
        label: strings.tabDiscover,
      ),
      _Tab(
        key: 'tab_pantry_${strings.locale}',
        icon: Badge(
          key: const Key('pantry_badge'),
          isLabelVisible: pantryCount > 0,
          label: Text('$pantryCount'),
          backgroundColor: green,
          child: const Icon(CookingIcons.pantry, color: grey),
        ),
        selectedIcon: Badge(
          isLabelVisible: pantryCount > 0,
          label: Text('$pantryCount'),
          backgroundColor: green,
          child: const Icon(CookingIcons.pantry, color: green),
        ),
        label: strings.tabPantry,
      ),
      _Tab(
        key: 'tab_shopping_${strings.locale}',
        icon: Badge(
          key: const Key('shopping_badge'),
          isLabelVisible: openItems > 0,
          label: Text('$openItems'),
          child: const Icon(Icons.shopping_basket_outlined, color: grey),
        ),
        selectedIcon: Badge(
          isLabelVisible: openItems > 0,
          label: Text('$openItems'),
          child: const Icon(Icons.shopping_basket_rounded, color: orange),
        ),
        label: strings.shoppingListTitle,
      ),
      _Tab(
        key: 'tab_social_${strings.locale}',
        icon: const Icon(Icons.groups_outlined, color: grey),
        selectedIcon: const Icon(Icons.groups_rounded, color: orange),
        label: strings.tabSocial,
      ),
      _Tab(
        key: 'tab_account_${strings.locale}',
        icon: const Icon(Icons.person_outline_rounded, color: grey),
        selectedIcon: const Icon(Icons.person_rounded, color: orange),
        label: strings.tabAccount,
      ),
    ];

    final wide = MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;
    final pages = IndexedStack(index: _currentIndex, children: _screens);

    // Back on another tab returns to Discover first; only from Discover does it leave the app.
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        body: wide
            ? Row(
                children: [
                  NavigationRail(
                    key: ValueKey('main_nav_rail_${strings.locale}'),
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Colors.white,
                    indicatorColor: orange.withValues(alpha: 0.15),
                    destinations: [
                      for (final t in tabs)
                        NavigationRailDestination(
                          icon: t.icon,
                          selectedIcon: t.selectedIcon,
                          label: Text(t.label),
                        ),
                    ],
                  ),
                  VerticalDivider(width: 1, color: Colors.grey.shade200),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: maxContentWidth),
                        child: pages,
                      ),
                    ),
                  ),
                ],
              )
            : pages,
        bottomNavigationBar: wide
            ? null
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: NavigationBar(
                  key: ValueKey('main_nav_bar_${strings.locale}'),
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _select,
                  backgroundColor: Colors.white,
                  indicatorColor: orange.withValues(alpha: 0.15),
                  destinations: [
                    for (final t in tabs)
                      NavigationDestination(
                        key: ValueKey(t.key),
                        icon: t.icon,
                        selectedIcon: t.selectedIcon,
                        label: t.label,
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Tab {
  final String key;
  final Widget icon;
  final Widget selectedIcon;
  final String label;
  const _Tab({required this.key, required this.icon, required this.selectedIcon, required this.label});
}
