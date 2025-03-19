import 'package:flutter/material.dart';
import 'package:share_recipe/components/recipe_thumbnail.dart';
import 'package:share_recipe/models/recipe.dart';
import 'package:share_recipe/screens/add_recipe/add_recipe_screen.dart';
import 'package:share_recipe/services/recipe_service.dart';

class CountryRecipeScreen extends StatefulWidget {
  const CountryRecipeScreen({super.key, required this.country});

  final String country;

  @override
  State<CountryRecipeScreen> createState() => _CountryRecipeScreenState();
}

class _CountryRecipeScreenState extends State<CountryRecipeScreen> {
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    print(_recipes);
  }

  Future<void> _fetchRecipes() async {
    final recipes = await RecipeService().getRecipesByTags([widget.country]);
    setState(() {
      _recipes = recipes;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.country)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                return RecipeThumbnail(
                  recipe: _recipes[index],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                AddRecipeScreen(recipe: _recipes[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
