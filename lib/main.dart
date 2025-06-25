import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:yt/firebase_options.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:yt/story/providers/story_provider.dart';
import 'auth_account_security/auth.dart';
import 'chat/providers/chat_provider.dart';
import 'chat/providers/chats_tab_content_state_provider.dart';
import 'chat/services/socket_service.dart';
import 'chat/widgets/chat_view.dart';
import 'jotter/providers/jotter_provider.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final socketService = SocketService(); // Create a single instance

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JotterProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()..loadUserProfile()), // Initialize and load user
        ChangeNotifierProvider(create: (_) => StoryProvider()), // Initialize and load user

        //  ENSURE THIS LINE IS PRESENT AND CORRECT  //
        ChangeNotifierProvider(create: (_) => ChatsTabContentStateProvider()),
        // Add any other global providers here
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
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: GoogleFonts.inter(textStyle: ThemeData.dark().textTheme.bodyLarge),
          bodyMedium: GoogleFonts.inter(textStyle: ThemeData.dark().textTheme.bodyMedium),
          displayLarge: GoogleFonts.inter(textStyle: ThemeData.dark().textTheme.displayLarge, fontWeight: FontWeight.bold),
        ),
      ),
      home: const AuthGate(),
    );
  }
}


// Temporary loader to demonstrate switching chat contexts
class ChatScreenLoader extends StatefulWidget {
  @override
  _ChatScreenLoaderState createState() => _ChatScreenLoaderState();
}

class _ChatScreenLoaderState extends State<ChatScreenLoader> {
  @override
  void initState() {
    super.initState();
    // Start with AI chat by default for this example
    // In your full app, this would be controlled by ChatsTabContentStateProvider
    // and the assistive prompt screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<ChatProvider>(context, listen: false).switchToAiChat();
      // Or uncomment below to test P2P
      Provider.of<ChatProvider>(context, listen: false).switchToP2pChat(
          "peer_xyz_789",
          "John Doe",
          "https://example.com/peer_avatar.png" // Can be null
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // In your actual app, this ChatView would be part of your
    // TabScreenWrapper -> ChatsTabContentStateProvider logic.
    return ChatView();
  }
}