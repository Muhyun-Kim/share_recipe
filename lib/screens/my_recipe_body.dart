import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_recipe/components/recipe_thumbnail.dart';
import 'package:share_recipe/providers/my_recipe_provider.dart';
import 'package:share_recipe/screens/add_recipe/add_recipe_screen.dart';

class MyRecipeBody extends ConsumerWidget {
  const MyRecipeBody({super.key, required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(myRecipesProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('マイレシピ', style: theme.textTheme.titleLarge),
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
              return RecipeThumbnail(
                recipe: recipes[index],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddRecipeScreen(recipe: recipes[index]),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
