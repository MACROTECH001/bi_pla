import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';
import '../screens/recipe_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Meal> allMeals = [];
  List<String> savedMealNames = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('savedMeals') ?? [];
    final meals = await loadMeals();
    setState(() {
      savedMealNames = saved;
      allMeals = meals.where((meal) => saved.contains(meal.name)).toList();
    });
  }

  Future<List<Meal>> loadMeals() async {
    final data = await rootBundle.loadString('assets/json/meals.json');
    final List<dynamic> jsonResult = json.decode(data);
    return jsonResult.map((e) => Meal.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes plats enregistrés")),
      body: allMeals.isEmpty
          ? const Center(child: Text("Aucun plat favori pour l’instant."))
          : ListView.builder(
              itemCount: allMeals.length,
              itemBuilder: (context, index) {
                final meal = allMeals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeScreen(meal: meal),
                        ),
                      );
                    },
                    leading: Image.asset(
                      meal.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(meal.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        savedMealNames.remove(meal.name);
                        await prefs.setStringList('savedMeals', savedMealNames);
                        loadFavorites();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
