import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  late final String id;
  late final String userId;
  late final String messageId;
  late final String content;
  late final DateTime dateCreation;

  Comment(this.id, this.userId, this.messageId, this.content, Timestamp timestamp) {
    dateCreation = timestamp.toDate();
  }

  Comment.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        userId = doc.data()!['userId'],
        messageId = doc.data()!['messageId'],
        content = doc.data()!['content'],
        dateCreation = doc.data()!['dateCreation'].toDate();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'messageId': messageId,
      'content': content,
      'dateCreation': Timestamp.fromDate(dateCreation)
    };
  }
}
