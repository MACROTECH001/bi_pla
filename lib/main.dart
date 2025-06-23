import 'package:flutter/material.dart';
import 'models/meal.dart';
import 'services/meal_provider.dart';
import 'screens/recipe_screen.dart';
import 'screens/meal_search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'screens/main_navigation.dart';
import 'screens/welcome_screen.dart';

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
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFFFF7E7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD87D4A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD87D4A),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> savedMeals = [];
  int currentMealIndex = DateTime.now().weekday - 1; // valeur par défaut selon le jour
  // int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadSavedMeals();
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

  String getDayName(int weekday) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[weekday - 1];
  }

  void nextMeal(List<Meal> meals) {
    setState(() {
      currentMealIndex = (currentMealIndex + 1) % meals.length;
    });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Meal>>(
      future: loadMeals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Erreur : ${snapshot.error}"),
            ),
          );
        } else {
          final meals = snapshot.data!;
          if (meals.isEmpty) {
            return const Scaffold(
              body: Center(child: Text("Aucun plat disponible 😢")),
            );
          }

          // final today = DateTime.now();
          // final meal = meals[_currentIndex % meals.length];
          final today = DateTime.now();
          // int index = today.weekday - 1; // 0 = Lundi, 6 = Dimanche
          final meal = meals[currentMealIndex % meals.length];


          return Scaffold(
            appBar: AppBar(
              title: const Text("Bi Pla"),
              actions: [
                IconButton(
                  onPressed: () => toggleSave(meal.name),
                  icon: Icon(
                    isSavedMeal(meal.name) ? Icons.star : Icons.star_border,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Plat du jour – ${getDayName(today.weekday)} ${today.day}/${today.month}/${today.year}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD87D4A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          // 🌟 La carte principale
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.asset(meal.image, height: 200, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    meal.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
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
                                  const SizedBox(height: 1),
                                  ...meal.ingredients.map(
                                    (i) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Text("• $i"),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
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
                                ],
                              ),
                            ),
                          ),

                          // 👉 Flèche sur le bord droit, centrée verticalement
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                onPressed: () => nextMeal(meals),
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFFD87D4A),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text("Rechercher un plat"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MealSearchScreen(),
                            ),
                          );
                        },
                      ),
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
