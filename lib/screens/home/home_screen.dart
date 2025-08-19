// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:ph_power/models/map_navigation.dart';
import 'package:ph_power/screens/home/area_list_view.dart';
import 'package:ph_power/screens/home/map_view.dart';
import 'package:ph_power/screens/profile/profile_screen.dart';

// This is our global communication channel for map navigation.
final mapNavigationNotifier = ValueNotifier<MapNavigation?>(null);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // We use a PageController to control the visible page.
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Animate the page transition for a smoother feel.
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The PageView widget is what keeps all three screens alive.
      body: PageView(
        controller: _pageController,
        // This prevents users from swiping between pages.
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          // Page 0: The Map
          MapView(navigationNotifier: mapNavigationNotifier),
          // Page 1: The List
          AreaListView(
            onAreaSelected: (navigationData) {
              mapNavigationNotifier.value = navigationData;
              // When an item is tapped, we directly control the PageController and BottomNavBar
              _onItemTapped(0);
            },
          ),
          // Page 2: The Profile
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list_alt),
              label: 'List'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
