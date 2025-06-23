import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:yt/index_screen.dart';

import '../home.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    String googleID = "27515328035-10r2gpaonqr58i436lbltbdbm347npp8.apps.googleusercontent.com";
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical : 15.0),
            child: SignInScreen(
              providers: [
            EmailAuthProvider(),
                GoogleProvider(clientId: googleID),
              ],
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset('assets/icon.png'),
                  ),

                );
              },
              showPasswordVisibilityToggle: true,

            ),
          );
        }

        return  IndexPage();
      },
    );
  }
}
