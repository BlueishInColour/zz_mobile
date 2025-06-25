// index_page.dart (or your current file name index_screen.dart)
import 'package:flutter/material.dart';
import 'package:yt/jotter/screens/jotter_tab_screen.dart';
import 'package:yt/story/screens/glimpse_tab_screen.dart';
// import 'package:yt/chat/screens/main_chat_host_screen.dart'; // No longer directly used here
import 'chat/screens/chats_tab_screen.dart';
import 'story_screen.dart';
import 'note_screen.dart';
import 'bookkeeper_screen.dart';

// Ensure providers are available above this widget in the tree (e.g. in main.dart)
// import 'package:provider/provider.dart';
// import '../providers/chats_tab_content_state_provider.dart';
// import '../providers/chat_provider.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key); // Added Key

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectedIndex = 0;

  // UPDATED _widgetOptions
  static final List<Widget> _widgetOptions = <Widget>[
    const ChatsTabScreen(), // <--- USE ChatsTabScreen HERE
     GlimpseTabScreen(),    // Assuming these are stateless or manage their own state
    const JotterTabScreen(),
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
      // You might want an AppBar here if you need a global title or actions
      // like a global panel toggle (though we decided against a global panel)
      // appBar: AppBar(
      //   title: Text("My App"),
      // ),
      body: Center( // Center might not be what you want if ChatsTabScreen uses a Row
        // Consider removing Center if ChatsTabScreen defines its own full-width layout
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[ // Added const
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            label: 'Glimpse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Jotter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Accounts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}