import 'package:flutter/material.dart';

//TODO: temp, evry class should have a file when implmented
class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Work in progress...',
          style: TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }
}

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
