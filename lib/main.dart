import 'package:flutter/material.dart';
import 'models/meal.dart';
import 'services/meal_provider.dart';
import 'screens/recipe_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/saved_meals_screen.dart';

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
          seedColor: const Color(0xFFD87D4A),
          primary: const Color(0xFFD87D4A),
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
  List<String> savedMeals = []; // On garde ici la liste des plats sauvegardés
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadSavedMeals(); // Charger les plats enregistrés dès le démarrage
  }

  void loadSavedMeals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedMeals = prefs.getStringList('savedMeals') ?? [];
    });
  }

  void toggleSave(String mealName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (savedMeals.contains(mealName)) {
        savedMeals.remove(mealName);
      } else {
        savedMeals.add(mealName);
      }
      prefs.setStringList('savedMeals', savedMeals);
    });
  }

  bool isSavedMeal(String mealName) {
    return savedMeals.contains(mealName);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Meal>>(
      future: loadMeals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        } else {
          final meals = snapshot.data!;
          final meal = meals[_currentIndex % meals.length]; // 💡 Sélection contrôlée

          final today = DateTime.now();

          return Scaffold(
            appBar: AppBar(title: const Text('Bi Pla – Plat du jour')),
            body: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Plat du jour – ${today.day}/${today.month}/${today.year}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B2E2B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // 🧱 Affichage du plat
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(meal.image, height: 200, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                meal.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD87D4A),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Ingrédients",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B2E2B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...meal.ingredients.map(
                                (i) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text("• $i"),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD87D4A),
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

                              IconButton(
                                icon: Icon(
                                  isSavedMeal(meal.name) ? Icons.bookmark : Icons.bookmark_border,
                                  color: const Color(0xFFD87D4A),
                                  size: 28,
                                ),
                                onPressed: () {
                                  toggleSave(meal.name);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🎲 Nouveau bouton pour changer de plat
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentIndex = (_currentIndex + 1) % meals.length;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Changer de plat"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD87D4A),
                          side: const BorderSide(color: Color(0xFFD87D4A)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedMealsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bookmarks_outlined, color: Color(0xFFD87D4A)),
                        label: const Text(
                          "Mes plats enregistrés",
                          style: TextStyle(color: Color(0xFFD87D4A)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
