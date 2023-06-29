import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/AuthService.dart';
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
  bool _isRegistering = false;

  final AuthService _authService = AuthService();

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
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRegistering ? null : _register,
              child: Text('Register'),
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            Visibility(
              visible: _successMessage.isNotEmpty,
              child: Text(
                _successMessage,
                style: TextStyle(color: Colors.green),
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
    String username = _usernameController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'Le nom d\'utilisateur ne peut pas être vide.';
        _isRegistering = false;
      });
      return;
    }

    setState(() {
      _isRegistering = true;
      _successMessage = '';
    });

    try {
      User? user = await _authService.registerWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
        username,
      );

      if (user != null) {
        await FirebaseAuth.instance.signOut();

        setState(() {
          _errorMessage = '';
          _successMessage =
              'Inscription réussie! Vous pouvez maintenant vous connecter.';
          _isRegistering = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de l\'inscription. Veuillez réessayer.';
          _successMessage = '';
          _isRegistering = false;
        });
      }
    } catch (e) {
      print(
          "Full error message: ${e.toString()}"); // Imprimer le message d'erreur complet
      String errorCode;
      String errorMessage;

      // Extraire le code d'erreur si l'exception est une erreur Firebase
      final regex = RegExp(r'\(auth\/([a-zA-Z-]+)\)');
      final match = regex.firstMatch(e.toString());
      if (match != null && match.groupCount >= 1) {
        errorCode = match.group(1)!; // Utilise le code d'erreur extrait
      } else {
        errorCode =
            'unknown-error'; // Utilise 'unknown-error' si l'erreur ne peut pas être extraite
      }

      errorMessage = getErrorMessageInFrench(errorCode);

      setState(() {
        _errorMessage = errorMessage;
        _successMessage = '';
        _isRegistering =
            false; // Ceci permettra de réactiver le bouton d'inscription
      });
    }
  }

  // Cette fonction convertit les codes d'erreur Firebase en messages d'erreur en français
  String getErrorMessageInFrench(String errorCode) {
    print("coodee " + errorCode);
    switch (errorCode) {
      case 'email-already-in-use':
        return 'L\'adresse e-mail est déjà utilisée par un autre compte.';
      case 'invalid-email':
        return 'L\'adresse e-mail n\'est pas valide.';
      case 'operation-not-allowed':
        return 'L\'opération n\'est pas autorisée.';
      case '[firebase_auth/unknown] An unknown error occurred: FirebaseError: Firebase: Password should be at least 6 characters (auth/weak-password).':
        return 'Le mot de passe est trop faible.';
      case 'unknown-error':
        return 'Une erreur inconnue s\'est produite.';
      default:
        return 'Veuillez vérifier votre saisie.';
    }
  }
}
