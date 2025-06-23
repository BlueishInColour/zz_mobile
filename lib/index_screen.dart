// index_page.dart (or your current file name index_screen.dart)
import 'package:flutter/material.dart';
import 'package:yt/chat/screens/main_chat_host_screen.dart';
import 'story_screen.dart';
import 'note_screen.dart';
import 'bookkeeper_screen.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    MainChatHostScreen(),
    StoryScreen(),
    NoteScreen(),
    BookkeeperScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),

            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            label: 'Story',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Accounts',
          ),
        ],
        currentIndex: _selectedIndex,
        // For dark theme, you might want to adjust selectedItemColor
        // The default dark theme might use the accent color or primary color variant.
        // If you want something specific:
        selectedItemColor: Theme.of(context).colorScheme.secondary, // Example: Use secondary color from dark theme
        // Unselected color will also be derived from the theme, but can be overridden
        // unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        // Optional: Explicitly set background color for BottomNavigationBar in dark mode
        // If not set, it will inherit a suitable color from the darkTheme.
        // backgroundColor: Colors.black26, // Example custom background
      ),
    );
  }
}