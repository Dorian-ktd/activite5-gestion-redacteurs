# 📰 Activité 5 — Gestion des Rédacteurs

Application Flutter de gestion des rédacteurs du magazine **« Magazine Infos »** avec base de données locale **SQLite**.

Ce projet a été réalisé dans le cadre de l'activité n°5 du cours de **Développement Mobile** (niveau intermédiaire).

---

## 🎯 Objectif

Créer une application Flutter permettant de gérer les rédacteurs du magazine à l'aide d'une base de données locale SQLite. L'application offre les fonctionnalités **CRUD** complètes (Create, Read, Update, Delete) et persiste les données entre les sessions.

---

## ✨ Fonctionnalités

- ✅ **Ajouter** un rédacteur (nom, prénom, email)
- ✅ **Afficher** la liste des rédacteurs enregistrés
- ✅ **Modifier** les informations via une boîte de dialogue
- ✅ **Supprimer** un rédacteur avec confirmation
- ✅ **Persistance** des données (SQLite)
- ✅ **Validation** du format email
- ✅ **Vérification d'unicité** de l'email
- ✅ **Tri** par nom ou prénom (A→Z, Z→A)
- ✅ **Bouton "Vider tous les rédacteurs"** avec confirmation
- ✅ **Compatibilité** Windows, Android, iOS

---

## 📁 Structure du projet
activite5_gestion_redacteurs/
├── lib/
│ ├── main.dart # Point d'entrée de l'application
│ ├── modele/
│ │ └── redacteur.dart # Modèle de données Redacteur
│ ├── services/
│ │ └── database_manager.dart # Gestion de la base SQLite (CRUD)
│ └── views/
│ └── redacteur_interface.dart # Interface utilisateur
├── pubspec.yaml # Dépendances du projet
└── README.md # Documentation (ce fichier)

text

---

## 🛠️ Technologies utilisées

| Technologie | Version | Rôle |
|-------------|---------|------|
| Flutter | 3.x | Framework de développement mobile |
| Dart | 3.x | Langage de programmation |
| sqflite | ^2.3.0 | Gestion de la base SQLite |
| sqflite_common_ffi | ^2.3.0 | Support SQLite sur Windows |
| path | ^1.8.0 | Manipulation des chemins |
| path_provider | ^2.0.2 | Accès au dossier de l'application |

---

## 🚀 Installation et exécution

### Prérequis

- Flutter SDK installé ([guide d'installation](https://flutter.dev/docs/get-started/install))
- Un éditeur de code (VS Code recommandé)
- Un émulateur Android ou Windows Desktop activé

### Étapes

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/Dorian-ktd/activite5-gestion-redacteurs.git
   cd activite5-gestion-redacteurs
Installer les dépendances

bash
flutter pub get
Lancer l'application

Sur Windows :

bash
flutter run -d windows
Sur Android (émulateur ou téléphone) :

bash
flutter run
⚠️ Attention : Ne lancez PAS sur Chrome (flutter run -d chrome). sqflite et path_provider ne supportent pas nativement le Web.

📸 Captures d'écran
Écran principal	Ajout d'un rédacteur
[Insérer capture 1]	[Insérer capture 2]
Modification	Suppression
[Insérer capture 3]	[Insérer capture 4]
🗄️ Base de données
Structure de la table redacteurs
Colonne	Type	Contrainte
id	INTEGER	PRIMARY KEY AUTOINCREMENT
nom	TEXT	NOT NULL
prenom	TEXT	NOT NULL
email	TEXT	NOT NULL UNIQUE
Requête SQL de création
sql
CREATE TABLE redacteurs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom TEXT NOT NULL,
  prenom TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE
);
🧩 Architecture
Le projet suit une architecture en couches pour une meilleure lisibilité et maintenabilité :

Modèle (modele/) : définit la structure des données

Service (services/) : gère l'accès à la base de données

Vue (views/) : gère l'affichage et les interactions utilisateur

🔍 Fonctionnalités détaillées
Ajout d'un rédacteur
Saisie du nom, prénom et email

Validation du format email

Vérification de l'unicité de l'email

Insertion dans la base SQLite

Modification d'un rédacteur
Clic sur l'icône ✏️

Ouverture d'une boîte de dialogue pré-remplie

Validation des modifications

Mise à jour dans la base

Suppression d'un rédacteur
Clic sur l'icône 🗑️

Confirmation via AlertDialog

Suppression dans la base

🚧 Difficultés rencontrées
Problème	Solution
MissingPluginException sur Chrome	Lancement sur Windows Desktop
databaseFactory not initialized sur Windows	Ajout de sqflite_common_ffi
Regex email trop stricte	Utilisation d'une regex permissive
🎁 Améliorations futures
🔍 Barre de recherche dans la liste

🎨 SnackBar colorés (succès/erreur)

📤 Export/Import des données en JSON

🌙 Mode sombre

☁️ Synchronisation avec un serveur distant

👤 Auteur
Dorian-ktd

GitHub : @Dorian-ktd

📄 Licence
Ce projet a été réalisé dans un cadre pédagogique. Libre d'utilisation à des fins éducatives.

🙏 Remerciements
À l'équipe pédagogique pour l'encadrement

À la communauté Flutter pour la documentation

Dernière mise à jour : Septembre 2026