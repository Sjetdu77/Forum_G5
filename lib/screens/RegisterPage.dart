import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController(); // Nouveau contrôleur pour le nom d'utilisateur
  String _errorMessage = '';
  String _successMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Page'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller:
                  _usernameController, // Champ de saisie pour le nom d'utilisateur
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _register();
              },
              child: const Text('Register'),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            Visibility(
              visible: _successMessage.isNotEmpty,
              child: Column(
                children: [
                  Text(
                    _successMessage,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
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

      // Mettre à jour le nom d'affichage de l'utilisateur avec la valeur du contrôleur
      await userCredential.user!.updateDisplayName(_usernameController.text);

      // Recharger l'utilisateur pour obtenir les dernières informations depuis Firebase
      await userCredential.user!.reload();

      // Introduire un délai de 2 secondes
      await Future.delayed(const Duration(seconds: 2));

      // Enregistrer le nom d'utilisateur et l'e-mail dans la collection "users"
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text,
        'displayName': _usernameController.text,
        'id': userCredential.user!.uid,
      });

      print('Utilisateur enregistré: ${userCredential.user!}');

      setState(() {
        _errorMessage = '';
        _successMessage = 'Inscription réussie !';
      });

      // Se déconnecter après l'enregistrement réussi
      await FirebaseAuth.instance.signOut();

      _clearFields();
    } catch (e) {
      print(e);
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
