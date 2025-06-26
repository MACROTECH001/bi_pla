import 'dart:io';
import 'package:bi_pla/main.dart';
import 'package:bi_pla/screens/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/meal.dart';
import '../services/custom_meal_storage.dart';
import 'user_meals.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  int time = 0;
  int servings = 0;
  int budget = 0;
  String ingredientsText = '';
  String stepsText = '';
  String tip = '';
  File? selectedImage;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> saveMeal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        image: selectedImage?.path ?? '',
        time: time,
        servings: servings,
        budget: budget,
        ingredients: ingredientsText.split(',').map((e) => e.trim()).toList(),
        steps: stepsText.split(',').map((e) => e.trim()).toList(),
        tip: tip,
      );

      await CustomMealStorage.saveMeal(meal);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );


      Future.delayed(const Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Recette ajoutée avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter une recette")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : const Center(child: Text("Cliquer pour ajouter une image")),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom du plat'),
                validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Durée (minutes)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => time = int.tryParse(value!) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre de personnes'),
                keyboardType: TextInputType.number,
                onSaved: (value) => servings = int.tryParse(value!) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Budget (FCFA)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => budget = int.tryParse(value!) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ingrédients (séparés par des virgules)'),
                onSaved: (value) => ingredientsText = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Etapes de préparation (séparées par des virgules)'),
                maxLines: 3,
                onSaved: (value) => stepsText = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Conseil ou astuce'),
                maxLines: 2,
                onSaved: (value) => tip = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveMeal,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD87D4A)),
                child: const Text("Enregistrer la recette"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
