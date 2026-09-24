// ignore_for_file: avoid_print
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arewecookin/firebase_options.dart';
import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/services/recipe_generator.dart';

/// Bulk Recipe Firestore Seeder for 10,000+ Recipes.
/// Handles Firestore WriteBatch constraints (max 500 writes per batch).
class BulkRecipeSeeder {
  static const int batchLimit = 500;

  final FirebaseFirestore? firestore;

  BulkRecipeSeeder({this.firestore});

  Recipe generateRecipe(int index) => RecipeGenerator.generate(index);

  /// Bulk seed recipes in batches of max 500.
  /// If [dryRun] is true, it does not contact Firestore but tests batch slicing and generation.
  Future<int> seedRecipes({
    int totalCount = 10000,
    int chunkSize = batchLimit,
    bool dryRun = false,
    void Function(int processed, int total)? onProgress,
  }) async {
    assert(chunkSize <= 500, 'Firestore WriteBatch supports a maximum of 500 operations.');

    int totalCommitted = 0;

    for (int batchStart = 0; batchStart < totalCount; batchStart += chunkSize) {
      final batchEnd = min(batchStart + chunkSize, totalCount);
      final currentChunkLength = batchEnd - batchStart;

      if (dryRun) {
        for (int i = batchStart; i < batchEnd; i++) {
          final recipe = generateRecipe(i);
          assert(recipe.id.isNotEmpty);
          assert(recipe.title.isNotEmpty);
          assert(recipe.ingredientKeys.isNotEmpty);
        }
      } else {
        if (firestore == null) {
          throw StateError('FirebaseFirestore instance must be provided when dryRun is false.');
        }

        WriteBatch batch = firestore!.batch();
        for (int i = batchStart; i < batchEnd; i++) {
          final recipe = generateRecipe(i);
          final docRef = firestore!.collection('recipes').doc(recipe.id);
          batch.set(docRef, recipe.toMap());
        }
        await batch.commit();
      }

      totalCommitted += currentChunkLength;
      onProgress?.call(totalCommitted, totalCount);
    }

    return totalCommitted;
  }
}

Future<void> main(List<String> args) async {
  final isDryRun = args.contains('--dry-run');
  final countArg = args.firstWhere((a) => a.startsWith('--count='), orElse: () => '--count=10000');
  final totalCount = int.tryParse(countArg.split('=').last) ?? 10000;

  print('=== AreWeCookin Bulk Recipe Seeder ===');
  print('Target recipes: $totalCount');
  print('Dry run mode: $isDryRun');
  print('Batch size: ${BulkRecipeSeeder.batchLimit} (Firestore max constraint)');

  FirebaseFirestore? firestore;
  if (!isDryRun) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firestore = FirebaseFirestore.instance;
  }

  final seeder = BulkRecipeSeeder(firestore: firestore);
  final stopwatch = Stopwatch()..start();

  final written = await seeder.seedRecipes(
    totalCount: totalCount,
    dryRun: isDryRun,
    onProgress: (done, total) {
      final pct = (done / total * 100).toStringAsFixed(1);
      print('Progress: $done / $total ($pct%) in ${stopwatch.elapsedMilliseconds}ms');
    },
  );

  stopwatch.stop();
  print('Successfully processed $written recipes in ${stopwatch.elapsed.inSeconds} seconds.');
}
