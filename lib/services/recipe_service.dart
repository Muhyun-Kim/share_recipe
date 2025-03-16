import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:share_recipe/models/recipe.dart';
import 'package:share_recipe/services/firebase_service.dart';

class RecipeService {
  Future<void> addRecipe(Recipe recipe) async {
    await firestore.collection('recipes').doc(recipe.id).set(recipe.toJson());
  }

  Future<List<Recipe>> getMyRecipes(String userId) async {
    final snapshot =
        await firestore
            .collection('recipes')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Recipe.fromJson(data).copyWith(id: doc.id);
    }).toList();
  }

  Stream<List<Recipe>> streamNewRecipes() {
    return firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Recipe.fromJson(data).copyWith(id: doc.id);
          }).toList();
        });
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await firestore
          .collection('recipes')
          .doc(recipe.id)
          .update(recipe.toJson());
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await firestore.collection('recipes').doc(id).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<String> uploadImage(XFile image) async {
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final file = File(image.path);
    // check file size
    print(file.lengthSync());
    final ref = storage.ref().child('recipes/$fileName');
    try {
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    final ref = storage.refFromURL(imageUrl);
    await ref.delete();
  }
}

final recipeService = RecipeService();
