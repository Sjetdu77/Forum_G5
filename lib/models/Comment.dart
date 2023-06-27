class Comment {
  final String id;            // id of comment
  final String postId;        // id of post commented
  final String userId;        // id of user who commented
  final DateTime dateCreated; // date of creation of comment
  final List<String> likes;   // list of users who liked the comment
  String content;             // content

  Comment ({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content
  }) {
    this.dateCreated = DateTime.timestamp();
  }

  void edit(content) {
    this.content = content;
  }

  void like(userId) {
    likes.add(userId);
  }

  int getLikeNumber() {
    return likes.length;
  }
}