import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      //print('TEST ' + userCredential.user!.uid);

      // Mettre à jour le nom d'affichage de l'utilisateur avec la valeur du contrôleur
      await userCredential.user!.updateDisplayName(_usernameController.text);

      // Recharger l'utilisateur pour obtenir les dernières informations depuis Firebase
      await userCredential.user!.reload();

      // Obtenir l'utilisateur avec les informations mises à jour
      print('Utilisateur mis à jour: ${userCredential.user!.displayName}');

      // Utiliser une transaction pour enregistrer les données dans Firestore
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid);

        transaction.set(userRef, {
          'email': _emailController.text,
          'displayName': _usernameController.text,
          'id': userCredential.user!.uid,
        });
      });

      print('Utilisateur enregistré: ${userCredential.user!}');

      // Se déconnecter après l'enregistrement réussi
      await FirebaseAuth.instance.signOut();

      setState(() {
        _errorMessage = '';
        _successMessage = 'Inscription réussie !';
      });

      _clearFields();
    } catch (e) {
      print(e);
      print('Erreur d\'enregistrement: $e');
      setState(() {
        _errorMessage = 'Erreur d\'enregistrement: $e. Veuillez réessayer.';
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
