import 'package:flutter/material.dart';
import '../models/models.dart';

class CookingModeScreen extends StatelessWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: Center(
        child: Text('Cooking Mode for ${recipe.title}'),
      ),
    );
  }
}
