import 'package:flutter/material.dart';
import '../models/meal.dart';

class RecipeScreen extends StatelessWidget {
  final Meal meal;

  const RecipeScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recette – ${meal.name}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(meal.image, height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(
              meal.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFD87D4A)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ingrédients",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B2E2B)),
            ),
            const SizedBox(height: 8),
            ...meal.ingredients.map((i) => Text("• $i")),
            const SizedBox(height: 16),
            const Text(
              "Préparation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B2E2B)),
            ),
            const SizedBox(height: 8),
            ...meal.steps.asMap().entries.map((entry) => Text("${entry.key + 1}. ${entry.value}")),
            if (meal.tip.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "Conseil",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B2E2B)),
              ),
              const SizedBox(height: 8),
              Text(meal.tip),
            ],
          ],
        )
      ),
    );
  }
}
