import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_recipe/models/recipe.dart';
import 'package:share_recipe/services/recipe_service.dart';

final newRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final recipeService = RecipeService();
  return recipeService.streamNewRecipes();
});
