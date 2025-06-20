import 'package:flutter/material.dart';
import 'models/meal.dart';
import 'services/meal_provider.dart';
import 'screens/recipe_screen.dart';

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
        fontFamily: 'Poppins', // optionnel si tu l'ajoutes plus tard
        scaffoldBackgroundColor: const Color(0xFFFFF7E7), // beige doux
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD87D4A), // orange doux
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFD87D4A),
          primary: Color(0xFFD87D4A),
        ),
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
          final meals = snapshot.data!;
          final today = DateTime.now();
          final index = today.day % meals.length;
          final meal = meals[index];


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Plat du jour – ${today.day}/${today.month}/${today.year}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),

                Text(
                  meal.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Image.asset(meal.image, height: 200, fit: BoxFit.cover),
                const SizedBox(height: 10),
                Text(
                  "Ingrédients",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B2E2B),
                  ),
                ),

                ...meal.ingredients.map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text("• $i"),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD87D4A), // orange
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeScreen(meal: meal),
                    ),
                  );
                },
                child: const Text(
                  "Voir la recette complète",
                  style: TextStyle(fontSize: 16),
                ),
              ),

              ],
            ),
          );
        },
      ),
    );
  }
}
