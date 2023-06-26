import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'loginPage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _register();
              },
              child: Text('Register'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Already have an account? Login'),
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Utilisez `userCredential` pour accéder aux informations de l'utilisateur enregistré.
      print('Utilisateur enregistré: ${userCredential.user}');
      setState(() {
        _errorMessage =
            ''; // Réinitialiser le message d'erreur s'il y en avait un précédemment.
      });
    } catch (e) {
      print('Erreur d\'enregistrement: $e');
      setState(() {
        _errorMessage =
            'Erreur d\'enregistrement. Veuillez réessayer.'; // Afficher le message d'erreur.
      });
    }
  }
}
