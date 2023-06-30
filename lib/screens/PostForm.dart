import 'package:flutter/material.dart';
// Importation des services de base de données
import '../services/dataBaseServices.dart';
// Importation d'une page avec des fonctions
import '../services/functionPage.dart';

// Définition de la classe PostForm qui est un widget d'état
class PostForm extends StatefulWidget {
  // postId est facultatif et peut être null
  final String? postId;

  // Constructeur qui prend postId comme argument facultatif
  PostForm({this.postId});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  // Contrôleur pour le champ de texte du contenu du post
  TextEditingController _contentController = TextEditingController();
  // Variables pour stocker les messages d'erreur et de succès
  String _errorMessage = '';
  String _successMessage = '';
  // Variable pour vérifier si le formulaire est en cours de soumission
  bool _isSubmitting = false;
  // Création d'une instance de DataBaseServices pour interagir avec la base de données
  final DataBaseServices _dataBaseServices = DataBaseServices();

  // Méthode de construction de l'interface utilisateur
  Widget build(BuildContext context) {
    return PageWithFloatingButton(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Nouveau Post'),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Champ de texte pour le contenu du post
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Contenu'),
                maxLines: 4, // Nombre maximum de lignes
              ),
              SizedBox(height: 16),
              // Bouton de soumission
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null // Désactive le bouton si le formulaire est en cours de soumission
                    : () async {
                        // Définir _isSubmitting à vrai pour indiquer que le formulaire est en cours de soumission
                        setState(() {
                          _isSubmitting = true;
                        });

                        // Envoyer le post ou le commentaire à la base de données
                        String result = await _dataBaseServices.post(
                            _contentController.text, widget.postId);

                        // Traitement du résultat
                        if (result == 'success') {
                          setState(() {
                            // Message de succès selon s'il s'agit d'un post ou d'un commentaire
                            _successMessage = widget.postId == null
                                ? 'Post créé avec succès!'
                                : 'Commentaire ajouté avec succès!';
                            _errorMessage = '';
                          });

                          // Effacer le champ de texte et revenir à la page précédente
                          _contentController.clear();
                          Navigator.pop(context);
                        } else {
                          // Afficher le message d'erreur retourné par la base de données
                          setState(() {
                            _errorMessage = result;
                            _successMessage = '';
                          });
                        }

                        // Réinitialiser _isSubmitting à faux après la soumission
                        setState(() {
                          _isSubmitting = false;
                        });
                      },
                // Afficher une animation de chargement si le formulaire est en cours de soumission, sinon afficher "Poster"
                child: _isSubmitting
                    ? CircularProgressIndicator()
                    : Text('Poster'),
              ),
              SizedBox(height: 16),
              // Afficher le message d'erreur s'il y en a un
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              // Afficher le message de succès s'il y en a un
              Visibility(
                visible: _successMessage.isNotEmpty,
                child: Text(
                  _successMessage,
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
