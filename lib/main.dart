import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:yt/firebase_options.dart';

import 'auth_account_security/auth.dart';
import 'chat/providers/chat_provider.dart';
import 'chat/services/socket_service.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final socketService = SocketService(); // Create a single instance

  runApp(
    MultiProvider(
      providers: [
        Provider<SocketService>.value(value: socketService),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(socketService),
        ),
        // Add NavigationProvider if you implement complex bottom nav logic
      ],
      child: const MyApp(),
    ),
  );
}





class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,


      darkTheme: ThemeData(
        brightness: Brightness.dark, // Signifies this is a dark theme
        primarySwatch: Colors.teal, // Example primary color for dark theme
        // You can customize other properties like:
        // scaffoldBackgroundColor: Colors.black,
        // accentColor: Colors.tealAccent, // Note: accentColor is deprecated, use colorScheme.secondary
        colorScheme: ColorScheme.dark( // Using ColorScheme for modern theme building
          primary: Colors.teal,
          secondary: Colors.tealAccent,
          // ... other colors
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
                  side: BorderSide(width: 4)
            ))
          )
        )
      ),
      home: const AuthGate(),
    );
  }
}