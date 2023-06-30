import 'package:flutter/material.dart';

import '../screens/HomePage.dart';

class PageWithFloatingButton extends StatelessWidget {
  final Widget child;

  PageWithFloatingButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: FloatingActionButton(
              heroTag: 'homeButton',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              child: Icon(Icons.home),
            ),
          ),
        ),
      ],
    );
  }
}
