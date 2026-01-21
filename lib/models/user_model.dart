class UserModel {
  final String uid;
  final String nom;
  final int? edat;
  final String bio;
  final List<String> photoUrls;
  final List<String> interessos;

  // Nous camps
  final String sexe;
  final String busco;

  // Estil de vida
  final String fuma;
  final String beu;
  final String exercici;
  final String animals;
  final String fills;
  final String volFills;
  final String alimentacio;

  UserModel({
    required this.uid,
    required this.nom,
    required this.edat,
    required this.bio,
    required this.photoUrls,
    required this.interessos,
    required this.sexe, // Requerit al constructor
    required this.busco, // Requerit al constructor
    required this.fuma,
    required this.beu,
    required this.exercici,
    required this.animals,
    required this.fills,
    required this.volFills,
    required this.alimentacio,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nom': nom,
      'edat': edat,
      'bio': bio,
      'photoUrls': photoUrls,
      'interessos': interessos,
      'sexe': sexe,
      'busco': busco,
      'fuma': fuma,
      'beu': beu,
      'exercici': exercici,
      'animals': animals,
      'fills': fills,
      'volFills': volFills,
      'alimentacio': alimentacio,
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
      sexe: map['sexe'] as String? ?? '',
      busco: map['busco'] as String? ?? '',
      fuma: map['fuma'] as String? ?? '',
      beu: map['beu'] as String? ?? '',
      exercici: map['exercici'] as String? ?? '',
      animals: map['animals'] as String? ?? '',
      fills: map['fills'] as String? ?? '',
      volFills: map['volFills'] as String? ?? '',
      alimentacio: map['alimentacio'] as String? ?? '',
    );
  }

  static int _parseEdat(dynamic edat) {
    if (edat is int) return edat;
    if (edat is String) return int.tryParse(edat) ?? 0;
    return 0;
  }
}