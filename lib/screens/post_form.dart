import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class PostForm extends StatefulWidget {
  const PostForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final TextEditingController _contentController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Post'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Contenu'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _post();
              },
              child: const Text('Poster'),
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
      /*DocumentReference docRef =
          await FirebaseFirestore.instance.collection('messagesTest').add({
        'id': user.uid,
        'content': _contentController.text,
        'author': user.displayName ?? '',
      });

      print('Post créé avec succès: ${docRef.id}');*/

      setState(() {
        _errorMessage = '';
        _successMessage = 'Post créé avec succès!';
      });

      _contentController.clear();
    } catch (e) {
      //print('Erreur lors de la création du post: $e');
      setState(() {
        _errorMessage =
            'Erreur lors de la création du post. Veuillez réessayer.';
        _successMessage = '';
      });
    }
  }
}
