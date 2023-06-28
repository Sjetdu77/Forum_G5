import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  late final String id;
  late final String userId;
  late final String messageId;
  late final String content;
  late final int milliCreation;
  late final DateTime dateCreation;

  Comment(this.id, this.userId, this.messageId, this.content, this.milliCreation) {
    dateCreation = DateTime.fromMillisecondsSinceEpoch(milliCreation);
  }

  Comment.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        userId = doc.data()!['userId'],
        messageId = doc.data()!['messageId'],
        content = doc.data()!['content'],
        milliCreation = doc.data()!['milliCreation'];

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'messageId': messageId,
      'content': content,
      'milliCreation': milliCreation
    };
  }
}
