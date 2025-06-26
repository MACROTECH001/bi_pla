import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';
import 'package:image_picker/image_picker.dart';


class EditRecipeScreen extends StatefulWidget {
  final Meal meal;

  const EditRecipeScreen({super.key, required this.meal});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController servingsController;
  late TextEditingController budgetController;
  late TextEditingController timeController;
  late TextEditingController tipController;

  List<String> ingredients = [];
  List<String> steps = [];
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;

    nameController = TextEditingController(text: meal.name);
    servingsController = TextEditingController(text: meal.servings.toString());
    budgetController = TextEditingController(text: meal.budget.toString());
    timeController = TextEditingController(text: meal.time.toString());
    tipController = TextEditingController(text: meal.tip);

    ingredients = List.from(meal.ingredients);
    steps = List.from(meal.steps);

    if (meal.image.isNotEmpty && File(meal.image).existsSync()) {
      selectedImage = File(meal.image);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void updateRecipe() async {
    if (_formKey.currentState!.validate()) {
      final updatedMeal = Meal(
        id: widget.meal.id,
        name: nameController.text.trim(),
        image: selectedImage?.path ?? widget.meal.image,
        servings: int.tryParse(servingsController.text) ?? 1,
        budget: int.tryParse(budgetController.text) ?? 0,
        time: int.tryParse(timeController.text) ?? 30,
        ingredients: ingredients.where((i) => i.trim().isNotEmpty).toList(),
        steps: steps.where((s) => s.trim().isNotEmpty).toList(),
        tip: tipController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('customMeals') ?? [];

      // Supprimer l'ancien
      saved.removeWhere((element) {
        final decoded = json.decode(element);
        return decoded['id'] == updatedMeal.id;
      });

      // Ajouter la version modifiée
      saved.add(jsonEncode(updatedMeal.toJson()));

      await prefs.setStringList('customMeals', saved);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Recette mise à jour avec succès !"),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Recette supprimée"),
          content: const Text("La recette a été supprimée avec succès."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                Navigator.of(context).pop(); // Revient à l’écran précédent
              },
            )
          ],
        ),
      );

      Navigator.pop(context); // Retour à l'écran précédent
    }
  }

  Widget buildDynamicList(String title, List<String> list, String hint, void Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...list.asMap().entries.map((entry) {
          int index = entry.key;
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: entry.value,
                  decoration: InputDecoration(hintText: "$hint ${index + 1}"),
                  onChanged: (val) => onChanged(index == list.length - 1 ? "" : val),
                ),
              ),
              if (index == list.length - 1)
                IconButton(
                  onPressed: () {
                    setState(() {
                      list.add('');
                    });
                  },
                  icon: const Icon(Icons.add),
                )
            ],
          );
        })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier la recette")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nom du plat"),
                validator: (val) => val!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 10),
              selectedImage != null
                  ? Image.file(selectedImage!, height: 150)
                  : const Text("Aucune image sélectionnée"),
              TextButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Changer l'image"),
              ),
              TextFormField(
                controller: servingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Nombre de personnes"),
              ),
              TextFormField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Budget (FCFA)"),
              ),
              TextFormField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Temps (minutes)"),
              ),
              const SizedBox(height: 10),
              buildDynamicList("Ingrédients", ingredients, "Ingrédient", (val) {
                setState(() {
                  ingredients.add('');
                });
              }),
              const SizedBox(height: 10),
              buildDynamicList("Étapes", steps, "Étape", (val) {
                setState(() {
                  steps.add('');
                });
              }),
              const SizedBox(height: 10),
              TextFormField(
                controller: tipController,
                decoration: const InputDecoration(labelText: "Astuces (facultatif)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: updateRecipe,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer les modifications"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
