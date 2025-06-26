import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/custom_meal_storage.dart';
import 'recipe_screen.dart';

class UserMealsScreen extends StatefulWidget {
  const UserMealsScreen({super.key});

  @override
  State<UserMealsScreen> createState() => _UserMealsScreenState();
}

class _UserMealsScreenState extends State<UserMealsScreen> {
  List<Meal> userMeals = [];

  @override
  void initState() {
    super.initState();
    loadUserMeals();
  }

  Future<void> loadUserMeals() async {
    final meals = await CustomMealStorage.loadMeals();
    setState(() {
      userMeals = meals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes recettes")),
      body: userMeals.isEmpty
          ? const Center(child: Text("Aucune recette personnalisée trouvée."))
          : ListView.builder(
              itemCount: userMeals.length,
              itemBuilder: (context, index) {
                final meal = userMeals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    leading: meal.image.isNotEmpty && File(meal.image).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(meal.image),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                    title: Text(meal.name),
                    subtitle: Text("${meal.servings} pers • ${meal.time} min • ${meal.budget} FCFA"),
                    onTap: () {
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
