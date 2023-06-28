//import 'package:flutter_forum/firebase_auth.dart;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
//import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Récupérez l'ID utilisateur généré
      String userId = userCredential.user!.uid;

      // Enregistrez le champ "username" dans Firestore
      await firestore.collection('users').doc(userId).set({
        'username': 'test', // Valeur du champ "username"
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        var errorMessage = e.message;
      });
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  void setState(Null Function() param0) {}
}
