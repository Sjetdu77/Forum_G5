import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment.dart';
import '../models/message.dart';
import '../models/user.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  addMessage(Message message) async {
    await _db.collection('messagesTest').add(message.toMap());
  }

  editMessage(Message message) async {
    await _db.collection('messagesTest').doc(message.id).update(message.toMap());
  }

  /*deleteMessage(String messageId) async {
    await _db.collection('messages').doc(messageId).delete();
  }*/

  register(User user) async {
    await _db.collection('users').add(user.toMap());
  }

  modifyUser(User user) async {
    await _db.collection('users').doc(user.id).update(user.toMap());
  }

  replyToMessage(Comment comment) async {
    await _db.collection('comments').add(comment.toMap());
  }

  editComment(Comment comment) async {
    await _db.collection('comments').doc(comment.id).update(comment.toMap());
  }

  Future<List<User>> retrieveUsers() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection('users').get();

    return snapshot.docs
        .map((docSnapshot) => User.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<List<Message>> retrieveMessages() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection('messagesTest').get();

    return snapshot.docs
        .map((docSnapshot) => Message.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<List<Comment>> retrieveComments() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection('comments').get();

    return snapshot.docs
        .map((docSnapshot) => Comment.fromDocumentSnapshot(docSnapshot))
        .toList();
  }
}
