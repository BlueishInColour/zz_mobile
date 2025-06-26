// index_page.dart (or your current file name index_screen.dart)
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <--- IMPORT THIS
import 'package:yt/accounts/screens/account_tab_screen.dart';
import 'package:yt/jotter/screens/jotter_tab_screen.dart';
import 'package:yt/story/screens/glimpse_tab_screen.dart';
import 'chat/screens/chats_tab_screen.dart';
// import 'story_screen.dart'; // These seem unused in _widgetOptions
// import 'note_screen.dart';   // These seem unused in _widgetOptions


class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectedIndex = 0;

  // Ensure these screens are correctly defined and imported
  static final List<Widget> _widgetOptions = <Widget>[
    const ChatsTabScreen(),
    GlimpseTabScreen(), // Assuming this is correct
    const JotterTabScreen(),
    AccountTabScreen(), // Assuming this is correct
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Define a color for the SVG icons that will work well with the selectedItemColor
    // and unselectedItemColor logic of BottomNavigationBar.
    // We'll apply the color conditionally based on selection.
    // The `selectedItemColor` will tint the SVG when it's active.
    // For the inactive state, we can use the default icon theme color or a specific grey.

    final Color unselectedIconColor = Theme.of(context).unselectedWidgetColor; // A good default
    final Color selectedIconColor = Theme.of(context).colorScheme.secondary; // Your selected color

    return Scaffold(
      body: IndexedStack( // Use IndexedStack to preserve state of the tabs
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svgs/chat_icon.svg',
              colorFilter: ColorFilter.mode(
                _selectedIndex == 0 ? selectedIconColor : unselectedIconColor,
                BlendMode.srcIn,
              ),
              width: 24, // Adjust size as needed
              height: 24, // Adjust size as needed
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svgs/glimpse_icon.svg',
              colorFilter: ColorFilter.mode(
                _selectedIndex == 1 ? selectedIconColor : unselectedIconColor,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
            label: 'Glimpse',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svgs/jotter_icon.svg',
              colorFilter: ColorFilter.mode(
                _selectedIndex == 2 ? selectedIconColor : unselectedIconColor,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
            label: 'Jotter',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svgs/accounts_icon.svg',
              colorFilter: ColorFilter.mode(
                _selectedIndex == 3 ? selectedIconColor : unselectedIconColor,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
            label: 'Accounts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: selectedIconColor, // This primarily affects the label
        unselectedItemColor: unselectedIconColor, // This primarily affects the label
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Good choice for 4 items
        // To ensure labels are always shown for fixed type (default behavior)
        // showUnselectedLabels: true, // This is default for fixed
        // showSelectedLabels: true,   // This is default for fixed
      ),
    );
  }
}