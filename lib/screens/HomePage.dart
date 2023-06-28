import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PostForm.dart';
import 'RegisterPage.dart';
import 'LoginPage.dart';

class HomePage extends StatelessWidget {
  void createReply(BuildContext context, String userId) async {
    final newComment = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostForm(postId: userId)),
    );

    if (newComment != null) {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(userId);

      postRef.update({
        'messageList': FieldValue.arrayUnion([newComment])
      });
    }
  }

  Future<void> handleLike(DocumentSnapshot document) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(document.id);

      bool isLiked = document['likes'] != null &&
          document['likes'].contains(currentUser.uid);

      if (isLiked) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([currentUser.uid])
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([currentUser.uid])
        });
      }
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    // Obtenir l'instance de Firebase Auth et Firestore
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Obtenir l'utilisateur actuellement connecté
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      final String userId = currentUser.uid;

      // 1. Supprimer les posts de l'utilisateur
      final QuerySnapshot userPosts = await firestore
          .collection('posts')
          .where('author', isEqualTo: userId)
          .get();
      for (final post in userPosts.docs) {
        await post.reference.delete();
      }

      // 1. Supprimer les commentaires de l'utilisateur (si stockés séparément)
      final QuerySnapshot userComments = await firestore
          .collection('comments')
          .where('author', isEqualTo: userId)
          .get();
      for (final comment in userComments.docs) {
        await comment.reference.delete();
      }

      // 2. Supprimer l'utilisateur dans Firestore (si vous stockez des données de profil séparées)
      await firestore.collection('users').doc(userId).delete();

      // 3. Supprimer le compte utilisateur dans Firebase Authentication
      await currentUser.delete().catchError((error) {
        // Gérer les erreurs (par exemple, si l'utilisateur doit se reconnecter)
        print("Erreur lors de la suppression du compte: $error");
      });

      // Rediriger l'utilisateur vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Stack(
        children: [
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
                                            onPressed: () {
                                              // Logic to delete comment
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
                                        FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(document.id)
                                            .delete();
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
          // Aligner les boutons flottants en bas à droite
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Vérifier si l'utilisateur est connecté avant d'afficher le bouton de suppression de compte
                  if (FirebaseAuth.instance.currentUser != null)
                    FloatingActionButton(
                      heroTag: 'deleteAccount',
                      onPressed: () {
                        deleteAccount(context);
                      },
                      child: Icon(Icons.delete),
                    ),
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
                  FloatingActionButton(
                    heroTag: 'logout',
                    onPressed: () {
                      FirebaseAuth.instance.currentUser != null
                          ? FirebaseAuth.instance.signOut()
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                    },
                    child: Icon(
                      FirebaseAuth.instance.currentUser != null
                          ? Icons.logout
                          : Icons.login,
                    ),
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
