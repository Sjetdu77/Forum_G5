import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/AuthService.dart';
import '../services/functionPage.dart';
import 'loginPage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';
  bool _isRegistering =
      false; // Ajouter cet état pour suivre si l'inscription est en cours

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return PageWithFloatingButton(
      child: Scaffold(
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
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isRegistering
                    ? null
                    : () {
                        // Désactiver le bouton pendant l'inscription
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
      ),
    );
  }

  void _register() async {
    setState(() {
      _isRegistering = true; // Définir l'état d'inscription comme vrai
      _successMessage = ''; // Réinitialiser le message de réussite
    });

    try {
      User? user = await _authService.registerWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
      );

      if (user != null) {
        // Utilisateur enregistré avec succès
        // Se déconnecter après un enregistrement réussi
        await FirebaseAuth.instance.signOut();

        setState(() {
          _errorMessage = '';
          _successMessage =
              'Inscription réussie ! Vous pouvez maintenant vous connecter.';
          _isRegistering = false; // Définir l'état d'inscription comme faux
        });
      } else {
        // Erreur lors de l'enregistrement
        setState(() {
          _errorMessage = 'Erreur lors de l\'inscription. Veuillez réessayer.';
          _successMessage = '';
          _isRegistering = false; // Définir l'état d'inscription comme faux
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _errorMessage =
            'Erreur lors de l\'inscription: $e. Veuillez réessayer.';
        _successMessage = '';
        _isRegistering = false; // Définir l'état d'inscription comme faux
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
