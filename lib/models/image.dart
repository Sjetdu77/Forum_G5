import 'package:cloud_firestore/cloud_firestore.dart';

class Image {
  final String id;
  final String link;
  final String content;

  Image({required this.id, required this.link, required this.content});

  Map<String, dynamic> toMap() {
    return {'link': link, 'content': content};
  }

  Image.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        link = doc.data()!['link'],
        content = doc.data()!['content'];
}
