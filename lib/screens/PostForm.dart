import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/functionPage.dart';

class PostForm extends StatefulWidget {
  final String? postId;

  PostForm({this.postId});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  TextEditingController _contentController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';

  @override
  Widget build(BuildContext context) {
    return PageWithFloatingButton(
      child: Scaffold(
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
                child: Text(
                  _successMessage,
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
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
      if (widget.postId == null) {
        // Création d'un nouveau post principal
        Map<String, dynamic> postData = {
          'author': user.uid,
          'authorName': user.displayName,
          'content': _contentController.text,
          'datePosting': DateTime.now(),
          'messageList': [],
          'likes': [],
        };
        await FirebaseFirestore.instance.collection('posts').add(postData);
        _successMessage = 'Post créé avec succès!';
      } else {
        // Ajout d'un commentaire à un post principal existant
        Map<String, dynamic> commentData = {
          'author': user.uid,
          'authorName': user.displayName,
          'content': _contentController.text,
          'datePosting': DateTime.now(),
          'messageList': [],
          'likes': [],
        };
        await addCommentToPost(widget.postId!, commentData);
        _successMessage = 'Commentaire ajouté avec succès!';
      }

      setState(() {
        _errorMessage = '';
      });

      _contentController.clear();
      Navigator.pop(context); // Retour à la page précédente
    } catch (e) {
      print('Erreur lors de la création du post: $e');
      setState(() {
        _errorMessage =
            'Erreur lors de la création dupost. Veuillez réessayer.';
        _successMessage = '';
      });
    }
  }

  Future<void> addCommentToPost(
      String postId, Map<String, dynamic> commentData) async {
    DocumentSnapshot postSnapshot =
        await FirebaseFirestore.instance.collection('posts').doc(postId).get();

    if (!postSnapshot.exists) {
      print('Post principal introuvable');
      return;
    }

    List<dynamic> existingComments = postSnapshot['messageList'] ?? <dynamic>[];

    existingComments.add(commentData);

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'messageList': existingComments});
  }
}
