import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/dataBaseServices.dart';
import 'PostForm.dart';
import 'LoginPage.dart';

// Définition d'une classe HomePage qui hérite de StatelessWidget
class HomePage extends StatelessWidget {
  // Création d'une instance de DataBaseServices pour interagir avec la base de données
  final DataBaseServices _dataBaseServices = DataBaseServices();

  // Surcharge de la méthode build pour construire l'interface utilisateur de la page d'accueil
  @override
  Widget build(BuildContext context) {
    // Retourne un widget Scaffold qui fournit la structure de base de l'interface utilisateur
    return Scaffold(
      // Définit la barre d'application en haut de l'écran
      appBar: AppBar(
        title: Text("Post App"),
        automaticallyImplyLeading: false,
        actions: [
          // Utilisation de StreamBuilder pour écouter les changements d'état d'authentification
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, snapshot) {
              // Affiche une barre de progression circulaire si la connexion est en cours
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                // Affiche le nom de l'utilisateur connecté ou 'Non connecté' si l'utilisateur n'est pas connecté
                if (snapshot.hasData && snapshot.data != null) {
                  String userUid = snapshot.data!.displayName ?? "";
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text(
                        'Connecté: $userUid',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text(
                        'Non connecté',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      // Définit le contenu principal de la page d'accueil
      body: Stack(
        children: [
          Center(
            child: StreamBuilder<QuerySnapshot>(
              // Écoute les changements de données de la collection de posts dans Firestore
              stream: _dataBaseServices.getPosts(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                // Affiche un message d'erreur si quelque chose ne va pas
                if (snapshot.hasError) {
                  return Text("Quelque chose s'est mal passé");
                }
                // Affiche une barre de progression circulaire si les données sont en cours de chargement
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                // Construit une liste de posts à partir des données récupérées
                return Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  margin: EdgeInsets.all(16.0),
                  child: ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      List<dynamic> comments =
                          data['messageList'] ?? <dynamic>[];

                      // Crée une carte pour chaque post
                      return Card(
                        elevation: 1.0,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10.0),
                          title: Text(
                            data['authorName'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Affiche la date du post
                              if (data['datePosting'] != null)
                                Text(
                                  formatDate(data['datePosting'].toDate()),
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              SizedBox(height: 8),
                              Text(data['content'] ?? ''),

                              // ExpansionTile pour afficher les commentaires

                              if (comments.length > 0)
                                ExpansionTile(
                                  title: Text(
                                    "Voir les commentaires",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        var comment = comments[index];
                                        return ListTile(
                                          title: Row(
                                            children: [
                                              Text(comment['authorName'] ?? '',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              SizedBox(width: 8),
                                              if (comment['datePosting'] !=
                                                  null)
                                                Text(
                                                  formatDate(
                                                      comment['datePosting']
                                                          .toDate()),
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey),
                                                ),
                                            ],
                                          ),
                                          subtitle:
                                              Text(comment['content'] ?? ''),
                                          trailing: FirebaseAuth.instance
                                                      .currentUser?.uid ==
                                                  comment['author']
                                              ? IconButton(
                                                  icon: Icon(Icons.delete),
                                                  onPressed: () async {
                                                    // Utilise le service pour supprimer le commentaire
                                                    await _dataBaseServices
                                                        .deleteComment(
                                                            document.id,
                                                            comment);
                                                  },
                                                )
                                              : null,
                                        );
                                      },
                                    ),
                                  ],
                                ),

                              // Bouton J'aime et compteur de j'aime
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      User? currentUser =
                                          FirebaseAuth.instance.currentUser;
                                      if (currentUser != null) {
                                        await _dataBaseServices
                                            .handleLike(document);
                                      }
                                    },
                                    child: StreamBuilder<User?>(
                                      stream: FirebaseAuth.instance
                                          .authStateChanges(),
                                      builder:
                                          (BuildContext context, snapshot) {
                                        User? currentUser = snapshot.data;
                                        bool isLiked = (document.data() as Map<
                                                    String, dynamic>)['likes']
                                                ?.contains(currentUser?.uid) ??
                                            false;
                                        return Icon(
                                          Icons.thumb_up,
                                          color: isLiked
                                              ? Colors.blue
                                              : Colors.grey,
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text((document.data() as Map<String,
                                                dynamic>)['likes']
                                            ?.length
                                            ?.toString() ??
                                        '0'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  _dataBaseServices.createReply(
                                      context, document.id);
                                },
                                child: Icon(Icons.add),
                              ),
                              FirebaseAuth.instance.currentUser?.uid ==
                                      data['author']
                                  ? IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _dataBaseServices
                                            .deletePost(document.id);
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Vérifier si la largeur de l'écran est supérieure à 971 pixels
              if (constraints.maxWidth > 971) {
                // Écouter les changements d'état d'authentification
                return StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (BuildContext context, snapshot) {
                    // Vérifier si l'utilisateur est connecté
                    bool isLoggedIn = snapshot.hasData && snapshot.data != null;
                    // Aligner les éléments en bas à droite
                    return Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Afficher le texte "Ajouter un post"
                                Text("Ajouter un post",
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(width: 8),
                                // Bouton pour naviguer vers le formulaire d'ajout de post
                                FloatingActionButton(
                                  heroTag: 'Ajouter un post',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PostForm()),
                                    );
                                  },
                                  child: Icon(Icons.add),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Afficher le texte "Se déconnecter" ou "Se connecter" selon l'état de connexion
                                Text(
                                    isLoggedIn
                                        ? "Se déconnecter"
                                        : "Se connecter",
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(width: 8),
                                // Bouton pour se connecter ou se déconnecter
                                FloatingActionButton(
                                  heroTag: 'Connexion / Deconnexion',
                                  onPressed: () {
                                    if (isLoggedIn) {
                                      FirebaseAuth.instance.signOut();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage()),
                                          (route) => false);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                      );
                                    }
                                  },
                                  child: Icon(Icons.exit_to_app),
                                ),
                              ],
                            ),
                            // Si l'utilisateur est connecté, afficher l'option de suppression de compte
                            if (isLoggedIn) ...[
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Afficher le texte "Effacer compte"
                                  Text("Effacer compte",
                                      style: TextStyle(fontSize: 14)),
                                  SizedBox(width: 8),
                                  // Bouton pour supprimer le compte
                                  FloatingActionButton(
                                    heroTag: 'Effacer compte',
                                    onPressed: () {
                                      _dataBaseServices.deleteAccount(context);
                                    },
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Si la largeur de l'écran est inférieure ou égale à 971 pixels, utiliser un layout différent
                return StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (BuildContext context, snapshot) {
                    bool isLoggedIn = snapshot.hasData && snapshot.data != null;
                    return Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 8),
                                // Bouton pour naviguer vers le formulaire d'ajout de post (version réduite)
                                FloatingActionButton(
                                  heroTag: 'addComment',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PostForm()),
                                    );
                                  },
                                  child: Icon(Icons.add),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 8),
                                // Bouton pour se connecter ou se déconnecter (version réduite)
                                FloatingActionButton(
                                  heroTag: 'Déconnexion',
                                  onPressed: () {
                                    if (isLoggedIn) {
                                      FirebaseAuth.instance.signOut();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage()),
                                          (route) => false);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                      );
                                    }
                                  },
                                  child: Icon(Icons.exit_to_app),
                                ),
                              ],
                            ),
                            // Si l'utilisateur est connecté, afficher l'option de suppression de compte (version réduite)
                            if (isLoggedIn) ...[
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width: 8),
                                  // Bouton pour supprimer le compte (version réduite)
                                  FloatingActionButton(
                                    heroTag: 'Supprimer compte',
                                    onPressed: () {
                                      _dataBaseServices.deleteAccount(context);
                                    },
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Fonction pour formater ladate
  String formatDate(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString()} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
