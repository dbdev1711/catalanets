class UserModel {
  final String uid;
  final String nom;
  final int? edat;
  final String bio;
  final List<String> photoUrls;
  final List<String> interessos;

  UserModel({
    required this.uid,
    required this.nom,
    required this.edat,
    required this.bio,
    required this.photoUrls,
    required this.interessos,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nom': nom,
      'edat': edat,
      'bio': bio,
      'photoUrls': photoUrls,
      'interessos': interessos,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      nom: map['nom'] as String? ?? 'Sense nom',
      edat: _parseEdat(map['edat']),
      bio: map['bio'] as String? ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      interessos: List<String>.from(map['interessos'] ?? []),
    );
  }

  static int _parseEdat(dynamic edat) {
    if (edat is int) return edat;
    if (edat is String) return int.tryParse(edat) ?? 0;
    return 0;
  }
}