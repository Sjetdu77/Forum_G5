import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '/screens/loginPage.dart';
import '/screens/registerPage.dart';
import '/screens/HomePage.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>
            HomePage(), // Définir la route par défaut comme la `HomePage`.
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
