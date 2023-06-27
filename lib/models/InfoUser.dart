class InfoUser {
  final String idInfo;
  String firstName;
  String lastName;
  final Picture avatar;

  InfoUser({
    required this.idInfo,
    required this.firstName,
    required this.lastName
  });

  editName(firstName, lastName) {
    this.firstName = firstName;
    this.lastName = lastName;
  }
}