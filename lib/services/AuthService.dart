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

  Future<void> userSetup(String displayName, email) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();
    users.add({'displayName': displayName, 'id': uid, 'email': email});
  }

  // Register with email & password
  Future registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      await Firebase.initializeApp();
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = FirebaseAuth.instance.currentUser;

      // Mettre à jour le displayName dans Firebase Authentication
      await user!.updateDisplayName(username);
      print(user);
      print('User : ' + user!.uid);
      // Ajouter l'utilisateur à la base de données
      await Future.delayed(Duration(seconds: 2));
      await user!.updateDisplayName(username);
      await _firestore.collection('users').doc(user!.uid).set({
        'email': email,
        'displayName': username,
        'id': user!.uid,
        // Ajout d'autres champs utilisateur si nécessaire
      });
      userSetup(username, email);
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
