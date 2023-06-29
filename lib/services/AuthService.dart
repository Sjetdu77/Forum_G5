import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // Register with email & password
  Future registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      await Firebase.initializeApp();
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = FirebaseAuth.instance.currentUser;

      // Ajouter l'utilisateur à la base de données
      await _firestore.collection('users').doc(user!.uid).set({
        'email': email,
        'displayName': username,
      });

      // Attendre que le document soit créé avec le bon ID utilisateur
      bool isDocumentCreated = false;
      while (!isDocumentCreated) {
        // Attendre un peu avant de vérifier à nouveau
        //await Future.delayed(Duration(seconds: 1));

        // Vérifier si le document existe avec le bon ID utilisateur
        DocumentSnapshot docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists && docSnapshot.id == user.uid) {
          isDocumentCreated = true;
        }
      }

      // Maintenant que le document est créé, mettre à jour le displayName et stocker l'ID
      await user.updateDisplayName(username);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'id': user.uid, 'displayName': username});

      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
