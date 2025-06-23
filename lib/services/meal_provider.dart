import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/meal.dart';

List<Meal> meals = [];

class MealProvider {
  static Future<List<Meal>> loadMeals() async {
    final String jsonString = await rootBundle.loadString('assets/json/meals.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((mealJson) => Meal.fromJson(mealJson)).toList();
  }
}

Future<List<Meal>> loadMeals() async {
  final String data = await rootBundle.loadString('assets/json/meals.json');
  final List<dynamic> jsonResult = json.decode(data);
  return jsonResult.map((e) => Meal.fromJson(e)).toList();
}
