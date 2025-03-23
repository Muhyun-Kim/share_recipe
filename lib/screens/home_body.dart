import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_recipe/components/recipe_thumbnail.dart';
import 'package:share_recipe/providers/new_recipe_provider.dart';
import 'package:share_recipe/screens/add_recipe/add_recipe_screen.dart';
import 'package:share_recipe/screens/country_recipe/country_recipe_screen.dart';

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final countries = [
      {'country': "日本", 'img': "assets/images/japan.jpg"},
      {'country': "韓国", 'img': "assets/images/korea.jpg"},
      {'country': "中国", 'img': "assets/images/china.jpg"},
      {'country': "イタリア", 'img': "assets/images/italy.jpg"},
    ];
    final newRecipes = ref.watch(newRecipesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('国別レシピ', style: theme.textTheme.titleLarge),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: countries.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CountryRecipeScreen(
                            country: countries[index]['country']!,
                          ),
                    ),
                  );
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
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            countries[index]['img']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          countries[index]['country']!,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('新着レシピ', style: theme.textTheme.titleLarge),
          ),
          newRecipes.when(
            data:
                (recipes) =>
                    recipes.isEmpty
                        ? const Center(child: Text('新着レシピがありません'))
                        : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: recipes.length,
                          itemBuilder:
                              (context, index) => RecipeThumbnail(
                                recipe: recipes[index],
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AddRecipeScreen(
                                              recipe: recipes[index],
                                            ),
                                      ),
                                    ),
                              ),
                        ),
            error: (error, stack) => const Center(child: Text('エラーが発生しました')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
