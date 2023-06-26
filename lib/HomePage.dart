import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/loginPage.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text(
          'Welcome! You are logged in.',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _logout(context);
        },
        child: Icon(Icons.logout),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Déconnexion de l'utilisateur.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      print('Erreur de déconnexion: $e');
    }
  }
}
