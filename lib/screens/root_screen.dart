import 'package:flutter/material.dart';
import 'package:share_recipe/screens/add_recipe/add_recipe_screen.dart';
import 'package:share_recipe/screens/home_body.dart';
import 'package:share_recipe/screens/my_recipe_body.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: currentPageIndex == 0 ? Text("検索") : Text("自分のレシピ"),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            label: "検索",
            selectedIcon: Icon(Icons.search),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "自分のレシピ",
            selectedIcon: Icon(Icons.person),
          ),
        ],
      ),
      body: <Widget>[HomeBody(), MyRecipeBody(theme: theme)][currentPageIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipeScreen()),
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
    );
  }
}
