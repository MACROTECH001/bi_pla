class Meal {
  final int id;
  final String name;
  final String image;
  // final String recipe;
  final int time;
  final int servings;
  final List<String> ingredients;
  final int budget;
  final List<String> steps;
  final String tip;

  Meal({
    required this.id,
    required this.name,
    required this.image,
    // required this.recipe,
    required this.time,
    required this.servings,
    required this.ingredients,
    required this.budget,
    required this.steps,
    required this.tip,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      // recipe: json['recipe'],
      time: json['time'],
      servings: json['servings'],
      ingredients: List<String>.from(json['ingredients']),
      budget: json['budget'],
      steps: List<String>.from(json['steps']),
      tip: json['tip'],
    );
  }
}
