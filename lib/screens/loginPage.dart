import 'package:flutter/material.dart';
// Importation des services de base de données
import '../services/dataBaseServices.dart';
// Importation d'une page avec des fonctions
import '../services/functionPage.dart';
// Importation de la page d'accueil
import '/screens/HomePage.dart';
// Importation de la page d'inscription
import 'RegisterPage.dart';

// Définition de la classe LoginPage qui est un widget d'état
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Création de contrôleurs pour les champs email et mot de passe
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  // Variables pour stocker les messages d'erreur et de succès
  String _errorMessage = '';
  String _successMessage = '';

  // Création d'une instance de DataBaseServices pour interagir avec la base de données
  final DataBaseServices _dataBaseServices = DataBaseServices();

  // Méthode de construction de l'interface utilisateur
  Widget build(BuildContext context) {
    return PageWithFloatingButton(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login Page'),
          // Désactiver le bouton de retour
          automaticallyImplyLeading: false,
        ),
        // Conteneur pour le corps de la page
        body: Container(
          // Marge intérieure du conteneur
          padding: EdgeInsets.all(16),
          child: Column(
            // Centrer les éléments de la colonne
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Champ de texte pour l'email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              // Champ de texte pour le mot de passe (obscured)
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              // Bouton de connexion
              ElevatedButton(
                onPressed: () async {
                  // Tentative de connexion de l'utilisateur
                  String result = await _dataBaseServices.loginUser(
                    _emailController.text,
                    _passwordController.text,
                  );

                  // Traitement du résultat
                  if (result == 'success') {
                    // Redirection vers la page d'accueil en cas de succès
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    // Affichage d'un message d'erreur en cas d'échec
                    setState(() {
                      _errorMessage =
                          'Erreur de connexion. Veuillez vérifier vos identifiants.';
                    });
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 16),
              // Affichage du message d'erreur
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              // Bouton pour aller à la page d'inscription
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
}
