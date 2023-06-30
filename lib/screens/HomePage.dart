import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/dataBaseServices.dart';
import 'PostForm.dart';
import 'LoginPage.dart';

class HomePage extends StatelessWidget {
  final DataBaseServices _dataBaseServices = DataBaseServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post App"),
        automaticallyImplyLeading: false,
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
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
      body: Stack(
        children: [
          Center(
            child: StreamBuilder<QuerySnapshot>(
              stream: _dataBaseServices.getPosts(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Quelque chose s'est mal passé");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

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
                              // Afficher la date du post
                              if (data['datePosting'] != null)
                                Text(
                                  formatDate(data['datePosting'].toDate()),
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              SizedBox(height: 8),
                              Text(data['content'] ?? ''),

                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  var comment = comments[index];
                                  return ListTile(
                                    title: Row(
                                      children: [
                                        Text(comment['authorName'] ?? '',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                            width:
                                                8), // Espace entre le nom de l'auteur et la date
                                        if (comment['datePosting'] != null)
                                          Text(
                                            formatDate(comment['datePosting']
                                                .toDate()),
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                    subtitle: Text(comment['content'] ?? ''),
                                    trailing: FirebaseAuth
                                                .instance.currentUser?.uid ==
                                            comment['author']
                                        ? IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () async {
                                              // Utilisez le service pour supprimer le commentaire
                                              await _dataBaseServices
                                                  .deleteComment(
                                                      document.id, comment);
                                            },
                                          )
                                        : null,
                                  );
                                },
                              ),

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
              // Vérifier la largeur de l'écran
              if (constraints.maxWidth > 971) {
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
                                Text("Ajouter un post",
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(width: 8),
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
                                Text(
                                    isLoggedIn
                                        ? "Se déconnecter"
                                        : "Se connecter",
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(width: 8),
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
                            if (isLoggedIn) ...[
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Effacer compte",
                                      style: TextStyle(fontSize: 14)),
                                  SizedBox(width: 8),
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
                            if (isLoggedIn) ...[
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width: 8),
                                  FloatingActionButton(
                                    heroTag: 'Supprimer compte',
                                    onPressed: () {
                                      _dataBaseServices.deleteAccount(context);
                                    },
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.delete,
                                    ),
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
