import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostForm extends StatefulWidget {
  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  TextEditingController _contentController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Post'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Contenu'),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _post();
              },
              child: Text('Poster'),
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
          ],
        ),
      ),
    );
  }

  void _post() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Vous devez être connecté pour poster.';
        _successMessage = '';
      });
      return;
    }

    if (_contentController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Le contenu ne peut pas être vide.';
        _successMessage = '';
      });
      return;
    }

    try {
      // Obtenir la date actuelle
      var currentDate = DateTime.now();

      // Créer un document dans la collection 'posts'
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('posts').add({
        'idUser': user.uid,
        'author': user.displayName ?? '',
        'content': _contentController.text,
        'datePosting': currentDate,
        'messagesList': [],
        'likes': []
      });

      print('Post créé avec succès: ${docRef.id}');

      setState(() {
        _errorMessage = '';
        _successMessage = 'Post créé avec succès!';
      });

      _contentController.clear();
    } catch (e) {
      print('Erreur lors de la création du post: $e');
      setState(() {
        _errorMessage =
            'Erreur lors de la création du post. Veuillez réessayer.';
        _successMessage = '';
      });
    }
  }
}
