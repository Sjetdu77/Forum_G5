import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/dataBaseServices.dart';
import '../services/functionPage.dart';
import 'PostForm.dart';
import 'RegisterPage.dart';
import 'LoginPage.dart';

class HomePage extends StatelessWidget {
  final DataBaseServices _dataBaseServices = DataBaseServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post App"),
      ),
      body: Stack(
        children: [
          Center(
            child: StreamBuilder<QuerySnapshot>(
              stream: _dataBaseServices
                  .getPosts(), // Utilisez la méthode du service
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Quelque chose s'est mal passé");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
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
                              Text(data['content'] ?? ''),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  var comment = comments[index];
                                  return ListTile(
                                    title: Text(comment['authorName'] ?? ''),
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
                                        await handleLike(document);
                                      }
                                    },
                                    child: StreamBuilder<User?>(
                                      stream: FirebaseAuth.instance
                                          .authStateChanges(),
                                      builder:
                                          (BuildContext context, snapshot) {
                                        User? currentUser = snapshot.data;
                                        bool isLiked = (document.data() as Map<
                                                    String, dynamic>)?['likes']
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
                                                dynamic>)?['likes']
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
                                  createReply(context, document.id);
                                },
                                child: Icon(Icons.add),
                              ),
                              FirebaseAuth.instance.currentUser?.uid ==
                                      data['author']
                                  ? IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        // Utilisez le service pour supprimer le post
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
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (FirebaseAuth.instance.currentUser != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Supprimer le compte'),
                        SizedBox(
                            width: 8), // Espacement entre le texte et le bouton
                        FloatingActionButton(
                          heroTag: 'deleteAccount',
                          onPressed: () {
                            deleteAccount(context);
                          },
                          child: Icon(Icons.delete),
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ),
                  SizedBox(height: 8), // Espacement entre les boutons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Ajouter un post'),
                      SizedBox(
                          width: 8), // Espacement entre le texte et le bouton
                      FloatingActionButton(
                        heroTag: 'postform',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostForm(),
                            ),
                          );
                        },
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Espacement entre les boutons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(FirebaseAuth.instance.currentUser != null
                          ? 'Se déconnecter'
                          : 'Se connecter'),
                      SizedBox(
                          width: 8), // Espacement entre le texte et le bouton
                      FloatingActionButton(
                        heroTag: 'logout',
                        onPressed: () async {
                          if (FirebaseAuth.instance.currentUser != null) {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          }
                        },
                        child: Icon(
                          FirebaseAuth.instance.currentUser != null
                              ? Icons.logout
                              : Icons.login,
                        ),
                      ),
                    ],
                  ),
                ],
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
                  String userUid = snapshot.data!.displayName ?? "";
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
                  return Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.all(16),
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
    );
  }
}
