import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Post.dart';

class PostForm extends StatelessWidget {
  final TextEditingController _contentController = TextEditingController();

  void _submitPost() {
    final String content = _contentController.text;

    // Créez une instance du modèle Post avec les valeurs saisies
    final Post newPost = Post(
      id: 'unique_id_here', // Générez un ID unique pour le post
      content: content,
      timestamp: DateTime.now(),
    );

    // Appelez une fonction pour enregistrer le post dans la base de données Firebase
    savePostToFirebase(newPost);
  }

  void savePostToFirebase(Post post) {
    // Ici, vous pouvez utiliser le package firebase_auth pour obtenir l'ID de l'utilisateur connecté
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    // Enregistrez le post dans la base de données Firebase
    final CollectionReference postsRef =
        FirebaseFirestore.instance.collection('posts');
    postsRef.doc(post.id).set({
      'userId': userId,
      'content': post.content,
      'timestamp': post.timestamp,
    }).then((_) {
      // Succès de l'enregistrement
      print('Post enregistré avec succès!');
    }).catchError((error) {
      // Gestion des erreurs lors de l'enregistrement
      print('Erreur lors de l enregistrement du post: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
