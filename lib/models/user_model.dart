class UserModel {
  final String uid;
  final String email;
  final bool acceptaNormativa;
  final DateTime dataRegistre;

  UserModel({
    required this.uid,
    required this.email,
    required this.acceptaNormativa,
    required this.dataRegistre,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'acceptaNormativa': acceptaNormativa,
    'dataRegistre': dataRegistre.toIso8601String(),
  };
}