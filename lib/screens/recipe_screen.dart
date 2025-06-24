import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/meal.dart';

class RecipeScreen extends StatefulWidget {
  final Meal meal;

  const RecipeScreen({super.key, required this.meal});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();

    if (widget.meal.video != null && widget.meal.video!.isNotEmpty) {
      try {
        _videoController = VideoPlayerController.asset('assets/videos/${widget.meal.video}')
          ..initialize().then((_) {
            setState(() {
              _isVideoReady = true;
            });
          }).catchError((e) {
            print("⚠️ Erreur chargement vidéo : $e");
          });
      } catch (e) {
        print("⚠️ Exception vidéo : $e");
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Scaffold(
      appBar: AppBar(title: Text(meal.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🍽 Image du plat
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(meal.image, height: 200, width: double.infinity, fit: BoxFit.cover),
            ),

            const SizedBox(height: 16),
            const Text("Ingrédients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...meal.ingredients.map((i) => Text("• $i")),

            const SizedBox(height: 16),
            const Text("Préparation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...meal.steps.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text("👉 $s"),
            )),

            const SizedBox(height: 16),
            if (meal.tip != null && meal.tip!.isNotEmpty) ...[
              const Text("Astuce", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(meal.tip!),
            ],

            const SizedBox(height: 20),

            // 🎥 Vidéo locale
            if (_isVideoReady && _videoController != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Vidéo tutorielle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _videoController!.value.isPlaying
                              ? _videoController!.pause()
                              : _videoController!.play();
                        });
                      },
                      icon: Icon(
                        _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(_videoController!.value.isPlaying ? "Pause" : "Lire"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
