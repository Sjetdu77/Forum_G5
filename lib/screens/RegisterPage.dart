import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/AuthService.dart';
import 'loginPage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController =
      TextEditingController(); // Nouveau contrôleur pour le nom d'utilisateur
  String _errorMessage = '';
  String _successMessage = '';

  final AuthService _authService =
      AuthService(); // Créer une instance de AuthService

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
            TextField(
              controller:
                  _usernameController, // Champ de saisie pour le nom d'utilisateur
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _register();
              },
              child: Text('Register'),
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            Visibility(
              visible: _successMessage.isNotEmpty,
              child: Column(
                children: [
                  Text(
                    _successMessage,
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                'Se connecter',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _register() async {
    try {
      User? user = await _authService.registerWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
      );

      if (user != null) {
        // Utilisateur enregistré avec succès
        setState(() {
          _errorMessage = '';
          _successMessage = 'Inscription réussie !';
        });
      } else {
        // Erreur lors de l'enregistrement
        setState(() {
          _errorMessage = 'Erreur lors de l\'inscription. Veuillez réessayer.';
          _successMessage = '';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _errorMessage =
            'Erreur lors de l\'inscription: $e. Veuillez réessayer.';
        _successMessage = '';
      });
    }
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _usernameController
        .clear(); // Effacer le champ de saisie du nom d'utilisateur
  }
}
