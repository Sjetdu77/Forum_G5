import 'package:flutter/material.dart';
import '../services/dataBaseServices.dart';
import '../services/functionPage.dart'; // N'oubliez pas d'importer DataBaseServices

class PostForm extends StatefulWidget {
  final String? postId;

  PostForm({this.postId});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  TextEditingController _contentController = TextEditingController();
  String _errorMessage = '';
  String _successMessage = '';
  bool _isSubmitting = false;
  final DataBaseServices _dataBaseServices =
      DataBaseServices(); // Instance de DataBaseServices

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
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Contenu'),
                maxLines: 4,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        setState(() {
                          _isSubmitting = true;
                        });

                        String result = await _dataBaseServices.post(
                            _contentController.text, widget.postId);

                        if (result == 'success') {
                          setState(() {
                            _successMessage = widget.postId == null
                                ? 'Post créé avec succès!'
                                : 'Commentaire ajouté avec succès!';
                            _errorMessage = '';
                          });

                          _contentController.clear();
                          Navigator.pop(context); // Retour à la page précédente
                        } else {
                          setState(() {
                            _errorMessage = result;
                            _successMessage = '';
                          });
                        }

                        setState(() {
                          _isSubmitting = false;
                        });
                      },
                child: _isSubmitting
                    ? CircularProgressIndicator()
                    : Text('Poster'),
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
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
