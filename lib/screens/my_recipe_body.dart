import 'package:flutter/material.dart';
import 'package:share_recipe/models/recipe.dart';
import 'package:share_recipe/screens/add_recipe/add_recipe_screen.dart';
import 'package:share_recipe/services/recipe_service.dart';

class MyRecipeBody extends StatefulWidget {
  const MyRecipeBody({super.key, required this.theme});

  final ThemeData theme;

  @override
  State<MyRecipeBody> createState() => _MyRecipeBodyState();
}

class _MyRecipeBodyState extends State<MyRecipeBody> {
  List<Recipe> recipes = [];
  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final recipeService = RecipeService();
    final recipes = await recipeService.getRecipes();
    if (!mounted) return;
    setState(() {
      this.recipes = recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('新着レシピ', style: widget.theme.textTheme.titleLarge),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddRecipeScreen(recipe: recipes[index]),
                    ),
                  );
                  _fetchRecipes();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.network(
                          recipes[index].imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          recipes[index].title,
                          style: widget.theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
