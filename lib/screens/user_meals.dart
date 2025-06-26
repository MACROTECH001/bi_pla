import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/custom_meal_storage.dart';
import 'recipe_screen.dart';
import 'edit_recipe_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> deleteCustomMeal(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('customMeals') ?? [];

    final updated = saved.where((element) {
      final meal = Meal.fromJson(json.decode(element));
      return meal.id != id;
    }).toList();

    await prefs.setStringList('customMeals', updated);
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
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditRecipeScreen(meal: meal),
                            ),
                          );
                        } else if (value == 'delete') {
                          await deleteCustomMeal(meal.id);

                          if (context.mounted) {
                            loadUserMeals(); // 🔁 Recharge la liste
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Plat supprimé')),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                        const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
