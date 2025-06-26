import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/meal.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Meal> meals = [];

// class MealProvider {
//   static Future<List<Meal>> loadMeals() async {
//     final String jsonString = await rootBundle.loadString('assets/json/meals.json');
//     final List<dynamic> jsonData = json.decode(jsonString);
//     return jsonData.map((mealJson) => Meal.fromJson(mealJson)).toList();
//   }
// }

// Future<List<Meal>> loadMeals() async {
//   final String data = await rootBundle.loadString('assets/json/meals.json');
//   final List<dynamic> jsonResult = json.decode(data);
//   return jsonResult.map((e) => Meal.fromJson(e)).toList();
// }

Future<List<Meal>> loadMeals() async {
  // 1. Charger les plats depuis le fichier JSON d’origine
  final data = await rootBundle.loadString('assets/json/meals.json');
  final List<dynamic> jsonList = json.decode(data);

  final meals = jsonList.map((json) => Meal.fromJson(json)).toList();

  // 2. Charger les plats personnalisés depuis SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final savedCustom = prefs.getStringList('customMeals') ?? [];

  final customMeals = savedCustom
      .map((jsonStr) => Meal.fromJson(json.decode(jsonStr)))
      .toList();

  // 3. Fusionner les deux listes
  return [...meals, ...customMeals];
}
