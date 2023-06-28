import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  late final String id;
  late final String userId;
  late final String content;
  late final DateTime dateCreation;

  Message(this.id, this.userId, this.content, Timestamp timestamp) {
    dateCreation = timestamp.toDate();
  }

  Message.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        userId = doc.data()!['userId'],
        content = doc.data()!['content'],
        dateCreation = doc.data()!['dateCreation'].toDate();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'dateCreation': Timestamp.fromDate(dateCreation)
    };
  }
}
