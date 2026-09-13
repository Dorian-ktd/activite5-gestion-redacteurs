/// Classe représentant un rédacteur du magazine
class Redacteur {
  // Attributs
  final int? id;        // Nullable car auto-incrémenté par la base
  final String nom;
  final String prenom;
  final String email;

  // Constructeur avec tous les attributs (pour lecture depuis la base)
  Redacteur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Constructeur sans id (pour insertion dans la base)
  factory Redacteur.sansId({
    required String nom,
    required String prenom,
    required String email,
  }) {
    return Redacteur(
      id: null,
      nom: nom,
      prenom: prenom,
      email: email,
    );
  }

  /// Convertit un objet Redacteur en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
  }

  /// Convertit un Map SQLite en objet Redacteur
  factory Redacteur.fromMap(Map<String, dynamic> map) {
    return Redacteur(
      id: map['id'],
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
    );
  }

  /// Pour afficher un rédacteur dans la console (débogage)
  @override
  String toString() {
    return 'Redacteur(id: $id, nom: $nom, prenom: $prenom, email: $email)';
  }
}