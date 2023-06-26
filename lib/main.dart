import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/screens/loginPage.dart';
import '/screens/registerPage.dart';
import 'HomePage.dart';
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Afficher un indicateur de chargement pendant la vérification de l'état d'authentification.
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              return HomePage(); // Utilisateur connecté, afficher la page d'accueil.
            } else {
              return LoginPage(); // Utilisateur non connecté, afficher la page de connexion.
            }
          }
        },
      ),
      routes: {
        '/login': (context) =>
            LoginPage(), // Définir une route nommée pour la page de connexion.
        '/register': (context) =>
            RegisterPage(), // Définir une route nommée pour la page d'inscription.
      },
    );
  }
}
