import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostForm extends StatefulWidget {
  final String parentId; // Modifier le nom ici

  PostForm({required this.parentId}); // Utiliser le nom ici

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
      if (widget.parentId.isEmpty) {
        // Création d'un nouveau post principal
        DocumentReference postRef =
            await FirebaseFirestore.instance.collection('posts').add({
          'author': user.displayName ?? '',
          'content': _contentController.text,
          'parentId': widget.parentId,
          'date': DateTime.now(),
          'like': <dynamic>[],
          'MessageList': <dynamic>[],
        });

        print('Post principal créé avec succès: ${postRef.id}');
      } else {
        // Ajout d'un commentaire à un post principal existant
        DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.parentId)
            .get();

        if (!postSnapshot.exists) {
          print('Post principal introuvable');
          return;
        }

        List<dynamic> existingComments =
            (postSnapshot.data() as Map<String, dynamic>)['MessageList'] ??
                <dynamic>[];

        Map<String, dynamic> newComment = {
          'id': user.uid,
          'content': _contentController.text,
          'author': user.displayName ?? '',
          'date': DateTime.now(),
          'like': 0,
        };

        existingComments.add(newComment);

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.parentId)
            .update({'MessageList': existingComments});

        print('Commentaire ajouté avec succès');
      }

      setState(() {
        _errorMessage = '';
        _successMessage = 'Post créé avec succès!';
      });

      _contentController.clear();
      Navigator.pop(context); // Retour à la page précédente
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
