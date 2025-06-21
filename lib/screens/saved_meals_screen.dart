import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';
import '../screens/recipe_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class SavedMealsScreen extends StatefulWidget {
  const SavedMealsScreen({super.key});

  @override
  State<SavedMealsScreen> createState() => _SavedMealsScreenState();
}

class _SavedMealsScreenState extends State<SavedMealsScreen> {
  List<Meal> allMeals = [];
  List<String> savedMealNames = [];

  @override
  void initState() {
    super.initState();
    loadSavedMeals();
  }

  Future<void> loadSavedMeals() async {
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
          ? const Center(child: Text("Aucun plat enregistré."))
          : ListView.builder(
              itemCount: allMeals.length,
              itemBuilder: (context, index) {
                final meal = allMeals[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(meal.image, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  title: Text(meal.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeScreen(meal: meal),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
