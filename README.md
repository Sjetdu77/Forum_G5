# Projet Forum

## Contexte
Ce projet a été réalisé dans le cadre d'un défi technique où l'objectif était de développer une application concurrente à Reddit ou Twitter en seulement 5 jours. Ce projet sert de prototype pour démontrer les capacités de base d'un système de forum.

## Fonctionnalités

### 1. Authentification des utilisateurs
Les utilisateurs peuvent créer un compte avec une adresse e-mail et un mot de passe. Ils peuvent également se connecter et se déconnecter de leurs comptes. La possibilité de supprimer un compte utilisateur est également disponible.

### 2. Création de posts
Les utilisateurs authentifiés peuvent créer des posts. Un post contient du texte et est associé à l'utilisateur qui l'a créé. Chaque post affiche également le nom de l'auteur et la date de publication.

### 3. Commentaires
Les utilisateurs peuvent ajouter des commentaires aux posts. Comme pour les posts, un commentaire contient du texte et est associé à l'utilisateur qui l'a créé. Les commentaires sont affichés sous le post correspondant.

### 4. Suppression de posts et commentaires
Les utilisateurs ont la possibilité de supprimer leurs propres posts et commentaires.

### 5. Flux de posts
Les posts sont affichés dans un flux, similaire à la page d'accueil de Reddit ou Twitter. Les utilisateurs peuvent parcourir les posts et interagir avec eux en temps réel.

### 6. Flux de posts
Les utilisateurs connectés peuvent ajouter un seul like par commentaire en temps réel.

## Technologies utilisées
- Flutter pour le développement de l'interface utilisateur.
- Firebase Auth pour la gestion de l'authentification des utilisateurs.
- Cloud Firestore pour la base de données en temps réel.

## Comment démarrer
1. Clonez ce dépôt.
2. Assurez-vous d'avoir Flutter installé et configuré.
3. Ouvrez le projet dans votre éditeur de code préféré.
4. Exécutez `flutter pub get` pour installer les dépendances.
5. Exécutez `flutter run` pour lancer l'application sur un émulateur ou un appareil réel.

## Auteurs
Maxime Avrillon-Thade,
Sami Hella,
Andy Frot

