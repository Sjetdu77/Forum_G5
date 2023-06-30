import 'package:flutter/material.dart';
import '../services/dataBaseServices.dart'; // Assurez-vous d'importer DataBaseServices
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
  String _successMessage = '';

  final DataBaseServices _dataBaseServices =
      DataBaseServices(); // Instance de DataBaseServices

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
                onPressed: () async {
                  String result = await _dataBaseServices.loginUser(
                    _emailController.text,
                    _passwordController.text,
                  );

                  // Traiter le résultat
                  if (result == 'success') {
                    // Rediriger vers la page d'accueil
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    setState(() {
                      _errorMessage =
                          'Erreur de connexion. Veuillez vérifier vos identifiants.';
                    });
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
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
}
