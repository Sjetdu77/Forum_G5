class Post {
  final String id;
  final String userId;
  final String content;
  final DateTime dateCreated;
  final List<String>
      likes; // Liste des IDs des utilisateurs qui ont aimé ce post.

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.dateCreated,
  }) {
    this.dateCreated = DateTime.timestamp();
  }
}
