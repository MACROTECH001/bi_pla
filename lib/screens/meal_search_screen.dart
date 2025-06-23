import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_provider.dart';

class MealSearchScreen extends StatefulWidget {
  const MealSearchScreen({super.key});

  @override
  State<MealSearchScreen> createState() => _MealSearchScreenState();
}

class _MealSearchScreenState extends State<MealSearchScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rechercher un plat")),
      body: FutureBuilder<List<Meal>>(
        future: loadMeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun plat disponible"));
          }

          final meals = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Budget max (FCFA)"),
                ),
                TextField(
                  controller: _servingsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Nombre de personnes"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final int? budget = int.tryParse(_budgetController.text);
                    final int? servings = int.tryParse(_servingsController.text);

                    final filtered = meals.where((meal) {
                      final matchBudget = budget == null || meal.budget <= budget;
                      final matchServings = servings == null || meal.servings >= servings;
                      return matchBudget && matchServings;
                    }).toList();

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Résultats"),
                        content: filtered.isNotEmpty
                            ? SizedBox(
                                height: 300,
                                width: double.maxFinite,
                                child: ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final meal = filtered[index];
                                    return ListTile(
                                      title: Text(meal.name),
                                      subtitle: Text("Budget: ${meal.budget} FCFA • ${meal.servings} pers."),
                                      leading: Image.asset(meal.image, width: 40, height: 40, fit: BoxFit.cover),
                                    );
                                  },
                                ),
                              )
                            : const Text("Aucun plat trouvé selon vos critères."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Fermer"),
                          )
                        ],
                      ),
                    );
                  },
                  child: const Text("Rechercher"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
