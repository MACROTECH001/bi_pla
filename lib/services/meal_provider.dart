import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/meal.dart';

class MealProvider {
  static Future<List<Meal>> loadMeals() async {
    final String jsonString = await rootBundle.loadString('assets/json/meals.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((mealJson) => Meal.fromJson(mealJson)).toList();
  }
}
