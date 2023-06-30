import 'package:flutter/material.dart';
// Importation de la bibliothèque FirebaseAuth pour l'authentification
import 'package:firebase_auth/firebase_auth.dart';
// Importation du service d'authentification personnalisé
import '../services/AuthService.dart';
// Importation d'une page avec des fonctions
import '../services/functionPage.dart';
// Importation de la page de connexion
import 'loginPage.dart';

// Définition de la classe RegisterPage qui est un widget d'état
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Contrôleurs pour les champs de texte email, mot de passe et nom d'utilisateur
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  // Variables pour stocker les messages d'erreur et de succès
  String _errorMessage = '';
  String _successMessage = '';
  // Variable pour vérifier si l'enregistrement est en cours
  bool _isRegistering = false;

  // Création d'une instance du service d'authentification
  final AuthService _authService = AuthService();

  // Méthode de construction de l'interface utilisateur
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
              // Champ de texte pour l'email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              // Champ de texte pour le mot de passe
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true, // Cache le texte pour la confidentialité
              ),
              // Champ de texte pour le nom d'utilisateur
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16),
              // Bouton d'enregistrement
              ElevatedButton(
                onPressed: _isRegistering
                    ? null // Désactive le bouton si l'enregistrement est en cours
                    : _register,
                child: Text('Register'),
              ),
              SizedBox(height: 16),
              // Afficher le message d'erreur s'il y en a un
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              // Afficher le message de succès s'il y en a un
              Visibility(
                visible: _successMessage.isNotEmpty,
                child: Text(
                  _successMessage,
                  style: TextStyle(color: Colors.green),
                ),
              ),
              SizedBox(height: 8),
              // Lien vers la page de connexion
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

  // Méthode pour gérer l'enregistrement de l'utilisateur
  void _register() async {
    String username = _usernameController.text.trim();

    // Vérifier si le nom d'utilisateur est vide
    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'Le nom d\'utilisateurne peut pas être vide.';
        _isRegistering = false;
      });
      return;
    }

    // Définir _isRegistering à true pour indiquer que le processus d'enregistrement a commencé
    setState(() {
      _isRegistering = true;
      _successMessage = '';
    });

    try {
      // Appeler le service d'authentification pour enregistrer l'utilisateur
      User? user = await _authService.registerWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
        username,
      );

      // Vérifier si l'utilisateur est enregistré avec succès
      if (user != null) {
        // Déconnexion de l'utilisateur
        await FirebaseAuth.instance.signOut();

        // Mise à jour de l'état avec le message de succès
        setState(() {
          _errorMessage = '';
          _successMessage =
              'Inscription réussie! Vous pouvez maintenant vous connecter.';
          _isRegistering = false;
        });
      } else {
        // Mise à jour de l'état avec le message d'erreur
        setState(() {
          _errorMessage = 'Erreur lors de l\'inscription. Veuillez réessayer.';
          _successMessage = '';
          _isRegistering = false;
        });
      }
    } catch (e) {
      // Imprimer le message d'erreur complet
      print("Full error message: ${e.toString()}");

      // Extraire et gérer les codes d'erreur Firebase spécifiques
      String errorCode;
      String errorMessage;
      final regex = RegExp(r'\(auth\/([a-zA-Z-]+)\)');
      final match = regex.firstMatch(e.toString());
      if (match != null && match.groupCount >= 1) {
        errorCode = match.group(1)!;
      } else {
        errorCode = 'unknown-error';
      }
      errorMessage = getErrorMessageInFrench(errorCode);

      // Mise à jour de l'état avec le message d'erreur
      setState(() {
        _errorMessage = errorMessage;
        _successMessage = '';
        _isRegistering = false;
      });
    }
  }

  // Fonction pour convertir les codes d'erreur Firebase en messages d'erreur en français
  String getErrorMessageInFrench(String errorCode) {
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
