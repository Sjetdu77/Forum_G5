import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PostForm.dart';
import 'RegisterPage.dart';
import 'loginPage.dart';

class HomePage extends StatelessWidget {
  void createReply(BuildContext context, String parentId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostForm(parentId: parentId)),
    );
  }

  Future<void> handleLike(DocumentSnapshot document) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(document.id);

      // Vérifier si l'utilisateur a déjà aimé le post
      bool isLiked = document['likes'] != null &&
          document['likes'].contains(currentUser.uid);

      if (isLiked) {
        // Si l'utilisateur a déjà aimé le post, annuler le "like"
        await postRef.update({
          'likes': FieldValue.arrayRemove([currentUser.uid])
        });
      } else {
        // Sinon, ajouter un "like" au post
        await postRef.update({
          'likes': FieldValue.arrayUnion([currentUser.uid])
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      floatingActionButton: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // Utilisateur connecté
            return Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 72, right: 0),
                child: FloatingActionButton(
                  heroTag: 'postform',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostForm(parentId: ""),
                      ),
                    );
                  },
                  child: Icon(Icons.add),
                ),
              ),
            );
          } else {
            // Utilisateur non connecté
            return Container();
          }
        },
      ),
      body: Stack(
        children: [
          // StreamBuilder pour afficher la liste des messages au centre.
          Center(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                // Construire une liste de messages sous forme de cartes dans un conteneur centré.
                return Container(
                  width: MediaQuery.of(context).size.width *
                      0.8, // 80% de la largeur de l'écran
                  margin: EdgeInsets.all(16.0),
                  child: ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      List<dynamic> comments =
                          data['MessageList'] ?? <dynamic>[];

                      return Card(
                        elevation: 1.0,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        //composant enfant
                        //titre
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10.0),
                          title: Text(
                            data['author'] != null ? data['author'] : '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['content']),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(comments[index]['author']),
                                    subtitle: Text(comments[index]['content']),
                                  );
                                },
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      // Récupérer l'utilisateur actuel
                                      User? currentUser =
                                          FirebaseAuth.instance.currentUser;
                                      if (currentUser != null) {
                                        // Ajouter l'ID de l'utilisateur à la liste des "likes" dans la base de données
                                        DocumentReference postRef =
                                            FirebaseFirestore.instance
                                                .collection('posts')
                                                .doc(document.id);
                                        await postRef.update({
                                          'likes': FieldValue.arrayUnion(
                                              [currentUser.uid])
                                        });
                                      }
                                    },
                                    child: Icon(Icons.thumb_up,
                                        color: Colors.grey),
                                  ),
                                  SizedBox(width: 4),
                                  Text(data['likes'] != null
                                      ? data['likes'].length.toString()
                                      : '0'),
                                ],
                              ),
                            ],
                          ),
                          //bouton a droite pour message
                          trailing: InkWell(
                            onTap: () {
                              createReply(context, document.id);
                            },
                            child: Icon(Icons.add),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: FloatingActionButton(
                onPressed: () {
                  FirebaseAuth.instance.currentUser != null
                      ? FirebaseAuth.instance.signOut()
                      : Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                },
                child: Icon(
                  FirebaseAuth.instance.currentUser != null
                      ? Icons.logout
                      : Icons.login,
                ),
              ),
            ),
          ),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.hasData && snapshot.data != null) {
                  // Utilisateur connecté
                  String userUid = snapshot.data!.displayName ??
                      ""; // Récupérer le nom d'affichage de l'utilisateur
                  return Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      child: Text(
                        'Utilisateur connecté: $userUid',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Utilisateur non connecté
                  return Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      child: Text(
                        'Logged out',
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
    );
  }
}
