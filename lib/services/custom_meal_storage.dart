import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';

class CustomMealStorage {
  static const String key = 'customMeals';

  static Future<void> saveMeal(Meal meal) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(key) ?? [];
    final updated = List<String>.from(existing);
    updated.add(json.encode(meal.toJson()));
    await prefs.setStringList(key, updated);
  }

  static Future<List<Meal>> loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(key) ?? [];
    return saved.map((e) => Meal.fromJson(json.decode(e))).toList();
  }

  static Future<void> updateMeal(Meal updatedMeal) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(key) ?? [];

    final updated = saved.map((e) {
      final meal = Meal.fromJson(json.decode(e));
      return meal.id == updatedMeal.id ? json.encode(updatedMeal.toJson()) : e;
    }).toList();

    await prefs.setStringList(key, updated);
  }

  static Future<void> deleteMeal(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(key) ?? [];

    final updated = saved.where((e) {
      final meal = Meal.fromJson(json.decode(e));
      return meal.id != id;
    }).toList();

    await prefs.setStringList(key, updated);
  }
}