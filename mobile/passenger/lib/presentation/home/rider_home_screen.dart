import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../domain/auth_session.dart';
import 'activity_screen.dart';
import 'home_tab.dart';
import 'profile_screen.dart';

/// Post-login rider home (placeholder for map / request flow).
class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({
    super.key,
    required this.session,
    required this.onSignOut,
  });

  final AuthSession session;
  final VoidCallback onSignOut;

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  int _currentIndex = 0;

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'SakAI · Home';
      case 1: return 'Activity';
      case 2: return 'Profile & Settings';
      default: return 'SakAI';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentIndex) {
      case 1: 
        body = const ActivityScreen(); 
        break;
      case 2: 
        body = ProfileScreen(onSignOut: widget.onSignOut); 
        break;
      case 0:
      default: 
        body = HomeTab(session: widget.session); 
        break;
    }

    return SakaiScreenScaffold(
      title: _getTitle(_currentIndex),
      body: body,
      bottom: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
