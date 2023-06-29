import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/LoginPage.dart';
import '../screens/PostForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour récupérer les posts
  Stream<QuerySnapshot> getPosts() {
    return _firestore.collection('posts').snapshots();
  }

  // Méthode pour supprimer un commentaire
  Future<void> deleteComment(
      String documentId, Map<String, dynamic> comment) async {
    DocumentReference postRef = _firestore.collection('posts').doc(documentId);
    return postRef.update({
      'messageList': FieldValue.arrayRemove([comment])
    });
  }

  // Méthode pour supprimer un post
  Future<void> deletePost(String documentId) {
    return _firestore.collection('posts').doc(documentId).delete();
  }

  Future<String> post(String content, [String? postId]) async {
    User? user = _auth.currentUser;
    if (user == null) {
      return 'Vous devez être connecté pour poster.';
    }

    if (content.isEmpty) {
      return 'Le contenu ne peut pas être vide.';
    }

    try {
      if (postId == null) {
        Map<String, dynamic> postData = {
          'author': user.uid,
          'authorName': user.displayName,
          'content': content,
          'datePosting': DateTime.now(),
          'messageList': [],
          'likes': [],
        };
        await _firestore.collection('posts').add(postData);
        return 'success';
      } else {
        Map<String, dynamic> commentData = {
          'author': user.uid,
          'authorName': user.displayName,
          'content': content,
          'datePosting': DateTime.now(),
          'messageList': [],
          'likes': [],
        };
        DocumentSnapshot postSnapshot =
            await _firestore.collection('posts').doc(postId).get();

        if (!postSnapshot.exists) {
          return 'Post principal introuvable';
        }

        List<dynamic> existingComments =
            postSnapshot['messageList'] ?? <dynamic>[];

        existingComments.add(commentData);

        await _firestore
            .collection('posts')
            .doc(postId)
            .update({'messageList': existingComments});

        return 'success';
      }
    } catch (e) {
      print('Erreur lors de la création du post: $e');
      return 'Erreur lors de la création du post. Veuillez réessayer.';
    }
  }

  Future<String> createPost(String content) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Vous devez être connecté pour poster.';
    }

    if (content.isEmpty) {
      return 'Le contenu ne peut pas être vide.';
    }

    try {
      Map<String, dynamic> postData = {
        'author': user.uid,
        'authorName': user.displayName,
        'content': content,
        'datePosting': DateTime.now(),
        'messageList': [],
        'likes': [],
      };
      await FirebaseFirestore.instance.collection('posts').add(postData);
      return 'success';
    } catch (e) {
      print('Erreur lors de la création du post: $e');
      return 'Erreur lors de la création du post. Veuillez réessayer.';
    }
  }

  Future<String> addCommentToPost(String postId, String content) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Vous devez être connecté pour commenter.';
    }

    if (content.isEmpty) {
      return 'Le contenu ne peut pas être vide.';
    }

    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (!postSnapshot.exists) {
        return 'Post principal introuvable';
      }

      List<dynamic> existingComments =
          postSnapshot['messageList'] ?? <dynamic>[];

      Map<String, dynamic> commentData = {
        'author': user.uid,
        'authorName': user.displayName,
        'content': content,
        'datePosting': DateTime.now(),
        'messageList': [],
        'likes': [],
      };

      existingComments.add(commentData);

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({'messageList': existingComments});

      return 'success';
    } catch (e) {
      print('Erreur lors de l\'ajout d\'un commentaire: $e');
      return 'Erreur lors de l\'ajout du commentaire. Veuillez réessayer.';
    }
  }

  Future<String> loginUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return 'success'; // Retourner 'success' si la connexion réussit
    } catch (e) {
      print('Erreur de connexion: $e');
      return 'failed'; // Retourner 'failed' si la connexion échoue
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    // Obtenir l'instance de Firebase Auth et Firestore
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Obtenir l'utilisateur actuellement connecté
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      final String userId = currentUser.uid;

      // 1. Supprimer les posts de l'utilisateur
      final QuerySnapshot userPosts = await firestore
          .collection('posts')
          .where('author', isEqualTo: userId)
          .get();
      for (final post in userPosts.docs) {
        await post.reference.delete();
      }

      // 1.1 Supprimer les commentaires de l'utilisateur dans les posts d'autres utilisateurs
      final QuerySnapshot allPosts = await firestore.collection('posts').get();
      for (final post in allPosts.docs) {
        List<dynamic> comments = post['messageList'] ?? <dynamic>[];
        comments =
            comments.where((comment) => comment['author'] != userId).toList();
        await post.reference.update({'messageList': comments});
      }

      // 2. Supprimer les commentaires de l'utilisateur (si stockés séparément)
      final QuerySnapshot userComments = await firestore
          .collection('comments')
          .where('author', isEqualTo: userId)
          .get();
      for (final comment in userComments.docs) {
        await comment.reference.delete();
      }

      // 3. Supprimer l'utilisateur dans Firestore (si vous stockez des données de profil séparées)
      await firestore.collection('users').doc(userId).delete();

      // 4. Supprimer le compte utilisateur dans Firebase Authentication
      await currentUser.delete().catchError((error) {
        // Gérer les erreurs (par exemple, si l'utilisateur doit se reconnecter)
        print("Erreur lors de la suppression du compte: $error");
      });

      // Rediriger l'utilisateur vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void createReply(BuildContext context, String userId) async {
    final newComment = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostForm(postId: userId)),
    );

    if (newComment != null) {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(userId);

      postRef.update({
        'messageList': FieldValue.arrayUnion([newComment])
      });
    }
  }

  Future<void> handleLike(DocumentSnapshot document) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(document.id);

      bool isLiked = document['likes'] != null &&
          document['likes'].contains(currentUser.uid);

      if (isLiked) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([currentUser.uid])
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([currentUser.uid])
        });
      }
    }
  }
}
