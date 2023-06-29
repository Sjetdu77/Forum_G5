import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/functionPage.dart';
import '/screens/HomePage.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = ''; // Nouvelle variable

  @override
  Widget build(BuildContext context) {
    return PageWithFloatingButton(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login Page'),
          automaticallyImplyLeading: false,
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
                  _login();
                },
                child: Text('Login'),
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              Visibility(
                visible: _successMessage.isNotEmpty, // Nouveau
                child: Text(
                  _successMessage,
                  style: TextStyle(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(
                  "S'enregistrer",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    // Réinitialisez les messages
    setState(() {
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('Utilisateur connecté: ${userCredential.user}');

      // Afficher un message de succès
      setState(() {
        _successMessage = 'Connexion réussie !';
      });

      // Ici, vous pouvez également ajouter un délai avant de rediriger vers la page d'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Erreur de connexion: $e');
      setState(() {
        _errorMessage =
            'Erreur de connexion. Veuillez vérifier vos identifiants.';
      });
    }
  }
}
