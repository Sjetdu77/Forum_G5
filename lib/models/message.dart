import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  late final String id;
  late final String userId;
  late final String content;
  late final int milliCreation;
  late final DateTime dateCreation;

  Message(this.id, this.userId, this.content, this.milliCreation) {
    dateCreation = DateTime.fromMillisecondsSinceEpoch(milliCreation);
  }

  Message.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        userId = doc.data()!['userId'],
        content = doc.data()!['content'],
        milliCreation = doc.data()!['dateCreation'];

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'milliCreation': milliCreation
    };
  }
}
