const admin = require("firebase-admin");
const {getFirestore} = require("firebase-admin/firestore")
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
exports.addMessage = functions.https.onRequest(async (req, res) => {
  const content = req.body.text;
  const userId = req.body.userId;

  const writeMessage = getFirestore().collection('Message')
    .add({
      content,
      dateCreation: Date.now(),
      userId
    });

  res.json({result: `Message with ID: ${writeMessage.id} added.`});
});
