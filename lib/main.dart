import 'package:flutter/material.dart';
import 'models/meal.dart';
import 'services/meal_provider.dart';

void main() {
  runApp(const BiPlaApp());
}

class BiPlaApp extends StatelessWidget {
  const BiPlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bi Pla',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Meal>> _meals;

  @override
  void initState() {
    super.initState();
    _meals = MealProvider.loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bi Pla – Plat du jour')),
      body: FutureBuilder<List<Meal>>(
        future: _meals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun plat trouvé'));
          }

          // Ici on affiche juste le premier plat (comme test)
          final meal = snapshot.data![0];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Image.asset(meal.image, height: 200, fit: BoxFit.cover),
                const SizedBox(height: 10),
                Text("Ingrédients :"),
                ...meal.ingredients.map((i) => Text("• $i")).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
