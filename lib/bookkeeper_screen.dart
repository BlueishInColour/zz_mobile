// home_screen.dart
import 'package:flutter/material.dart';

class BookkeeperScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold will automatically adapt to the dark theme
    return Scaffold(
      appBar: AppBar(
        // AppBar will also adapt to the dark theme (or you can customize it further in MaterialApp's darkTheme)
        title: Text('bookkeeper'),
      ),
      body: Center(
        child: Text(
          'bookkeeper Screen Content',
          // Text widget will also pick up dark theme text styles
        ),
      ),
    );
  }
}