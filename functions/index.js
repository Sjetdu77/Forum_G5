const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();
const functions = require("firebase-functions");
exports.getCollections = functions.https.onRequest((request, response) => {
  db.listCollections()
      .then((collections) => {
        const collectionIds = collections.map((collection) => collection.id);
        response.json({collections: collectionIds});
      })
      .catch((error) => {
        console.error("Error getting collections:", error);
        response.status(500).send("Error getting collections");
      });
});
exports.onCreateUser = functions.auth.user().onCreate((user) => {
  const userRef = db.collection("users").doc(user.uid);
  return userRef.set({
    email: user.email,
    displayName: user.displayName,
  })
      .then(() => {
        console.log('Utilisateur enregistré dans Firestore avec succès');
        return null;
      })
      .catch((error) => {
        console.error("Erreur enregistrement dans Firestore:", error);
        return null;
      });
});

exports.createMessage = functions.https.onRequest(async (req, res) => {
  try {
    const comment = req.body;
    const messageRef = await admin.firestore().collection('messages').add({
      comment: comment,
    });
    res.status(200).json({message: 'Comment successfull', id: messageRef.id});
  } catch (error) {
    console.error('Error creating message:', error);
    res.status(500).json({error: 'An error occurred while creating the msg'});
  }
});
