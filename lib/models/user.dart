import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  Map<String, dynamic> toMap() {
    return {'username': username, 'email': email};
  }

  User.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        username = doc.data()!['username'],
        email = doc.data()!['email'];
}
