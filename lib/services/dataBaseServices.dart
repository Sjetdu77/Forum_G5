import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/LoginPage.dart';
import '../screens/PostForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseServices {
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
