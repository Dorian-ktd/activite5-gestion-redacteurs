import 'package:flutter/material.dart';

import '../modele/redacteur.dart';
import '../services/database_manager.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  // Contrôleurs pour les champs de texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Liste des rédacteurs
  List<Redacteur> _redacteurs = [];

  // Instance du gestionnaire de base
  final DatabaseManager _dbManager = DatabaseManager();

  // Contrôleur pour la boîte de dialogue de modification
  final TextEditingController _editNomController = TextEditingController();
  final TextEditingController _editPrenomController = TextEditingController();
  final TextEditingController _editEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerRedacteurs();
  }

  @override
  void dispose() {
    // Libérer les contrôleurs pour éviter les fuites de mémoire
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _editNomController.dispose();
    _editPrenomController.dispose();
    _editEmailController.dispose();
    super.dispose();
  }

  /// Charge tous les rédacteurs depuis la base
  Future<void> _chargerRedacteurs() async {
    try {
      final redacteurs = await _dbManager.getAllRedacteurs();
      setState(() {
        _redacteurs = redacteurs;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ ERREUR CHARGEMENT: $e');
      debugPrint('📍 STACK: $stackTrace');
      _showMessage('Erreur: $e');
    }
  }

  /// Ajoute un rédacteur
  Future<void> _ajouterRedacteur() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();

    // 1. Vérifier que les champs ne sont pas vides
    if (nom.isEmpty || prenom.isEmpty || email.isEmpty) {
      _showMessage('Veuillez remplir tous les champs');
      return;
    }

    // 2. Vérifier le format de l'email
    if (!await _dbManager.emailValide(email)) {
      _showMessage('Format d\'email invalide (ex: nom@domaine.com)');
      return;
    }

    // 3. Vérifier si l'email existe déjà
    if (await _dbManager.emailExiste(email)) {
      _showMessage('Cet email est déjà utilisé');
      return;
    }

    try {
      final redacteur = Redacteur.sansId(
        nom: nom,
        prenom: prenom,
        email: email,
      );

      await _dbManager.insertRedacteur(redacteur);

      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();

      await _chargerRedacteurs();
      _showMessage('✅ Rédacteur ajouté avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'ajout : $e');
      _showMessage('Erreur lors de l\'ajout');
    }
  }

  /// Ouvre la boîte de dialogue de modification
  Future<void> _modifierRedacteur(Redacteur redacteur) async {
    // Pré-remplir les contrôleurs
    _editNomController.text = redacteur.nom;
    _editPrenomController.text = redacteur.prenom;
    _editEmailController.text = redacteur.email;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le rédacteur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _editNomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _editPrenomController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: _editEmailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );

    // Si l'utilisateur a validé
    if (result == true) {
      await _validerModification(redacteur.id!);
    }
  }

  /// Vide tous les rédacteurs après confirmation
  Future<void> _viderTousRedacteurs() async {
    if (_redacteurs.isEmpty) {
      _showMessage('Aucun rédacteur à supprimer');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tout supprimer ?'),
        content: Text(
          'Voulez-vous vraiment supprimer TOUS les ${_redacteurs.length} rédacteurs ?\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tout supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dbManager.deleteAllRedacteurs();
        await _chargerRedacteurs();
        _showMessage('🗑️ Tous les rédacteurs ont été supprimés');
      } catch (e) {
        debugPrint('❌ Erreur lors de la suppression globale : $e');
        _showMessage('Erreur lors de la suppression');
      }
    }
  }

  /// Valide la modification
  Future<void> _validerModification(int id) async {
    final nom = _editNomController.text.trim();
    final prenom = _editPrenomController.text.trim();
    final email = _editEmailController.text.trim();

    // 1. Vérifier que les champs ne sont pas vides
    if (nom.isEmpty || prenom.isEmpty || email.isEmpty) {
      _showMessage('Veuillez remplir tous les champs');
      return;
    }

    // 2. Vérifier le format de l'email
    if (!await _dbManager.emailValide(email)) {
      _showMessage('Format d\'email invalide (ex: nom@domaine.com)');
      return;
    }

    // 3. Vérifier si l'email existe déjà (en excluant le rédacteur actuel)
    if (await _dbManager.emailExiste(email, excludeId: id)) {
      _showMessage('Cet email est déjà utilisé par un autre rédacteur');
      return;
    }

    try {
      final redacteur = Redacteur(
        id: id,
        nom: nom,
        prenom: prenom,
        email: email,
      );

      await _dbManager.updateRedacteur(redacteur);
      await _chargerRedacteurs();
      _showMessage('✅ Rédacteur modifié avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de la modification : $e');
      _showMessage('Erreur lors de la modification');
    }
  }

  /// Supprime un rédacteur après confirmation
  Future<void> _supprimerRedacteur(Redacteur redacteur) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation de suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer le rédacteur '
          '"${redacteur.prenom} ${redacteur.nom}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dbManager.deleteRedacteur(redacteur.id!);
        await _chargerRedacteurs();
        _showMessage('🗑️ Rédacteur supprimé avec succès');
      } catch (e) {
        debugPrint('❌ Erreur lors de la suppression : $e');
        _showMessage('Erreur lors de la suppression');
      }
    }
  }

  /// Affiche un message temporaire (SnackBar)
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Rédacteurs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _viderTousRedacteurs,
            tooltip: 'Tout supprimer',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerRedacteurs,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ---------- SECTION AJOUT ----------
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Ligne : Nom + Prénom
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nomController,
                            decoration: const InputDecoration(
                              labelText: 'Nom',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _prenomController,
                            decoration: const InputDecoration(
                              labelText: 'Prénom',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Email
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    // Bouton Ajouter
                    ElevatedButton.icon(
                      onPressed: _ajouterRedacteur,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un Rédacteur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ---------- SECTION LISTE ----------
            Expanded(
              child: Card(
                elevation: 2,
                child: _redacteurs.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun rédacteur enregistré',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _redacteurs.length,
                        itemBuilder: (context, index) {
                          final redacteur = _redacteurs[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                redacteur.prenom[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${redacteur.prenom} ${redacteur.nom}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(redacteur.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _modifierRedacteur(redacteur),
                                  tooltip: 'Modifier',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _supprimerRedacteur(redacteur),
                                  tooltip: 'Supprimer',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
