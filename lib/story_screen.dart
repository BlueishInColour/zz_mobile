// home_screen.dart
import 'package:flutter/material.dart';

class StoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scaffold will automatically adapt to the dark theme
    return Scaffold(
      appBar: AppBar(
        // AppBar will also adapt to the dark theme (or you can customize it further in MaterialApp's darkTheme)
        title: Text('story'),
      ),
      body: Center(
        child: Text(
          'story Screen Content',
          // Text widget will also pick up dark theme text styles
        ),
      ),
    );
  }
}