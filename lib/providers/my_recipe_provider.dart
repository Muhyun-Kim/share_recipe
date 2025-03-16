import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_recipe/models/recipe.dart';
import 'package:share_recipe/providers/auth_provider.dart';
import 'package:share_recipe/services/recipe_service.dart';

final myRecipesProvider = StateNotifierProvider<MyRecipeNotifier, List<Recipe>>(
  (ref) {
    final user = ref.watch(authProvider);
    if (user == null) {
      return MyRecipeNotifier("");
    }
    return MyRecipeNotifier(user.uid);
  },
);

class MyRecipeNotifier extends StateNotifier<List<Recipe>> {
  final String userId;
  final RecipeService _recipeService = RecipeService();
  MyRecipeNotifier(this.userId) : super([]) {
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    final recipes = await _recipeService.getMyRecipes(userId);
    state = recipes;
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _recipeService.addRecipe(recipe);
    fetchRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _recipeService.updateRecipe(recipe);
    fetchRecipes();
  }

  Future<void> deleteRecipe(String id) async {
    await _recipeService.deleteRecipe(id);
    fetchRecipes();
  }
}
