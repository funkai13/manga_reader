import 'package:flutter/material.dart';

class EmptyComicsScreen extends StatefulWidget {
  final VoidCallback onAddComic;

  const EmptyComicsScreen({
    super.key,
    required this.onAddComic,
  });

  @override
  State<EmptyComicsScreen> createState() => _EmptyComicsScreenState();
}

class _EmptyComicsScreenState extends State<EmptyComicsScreen> {
  double _opacity = 0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1;
        _scale = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          opacity: _opacity,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded,
                    size: 90, color: Colors.black.withOpacity(0.35)),
                const SizedBox(height: 20),
                const Text(
                  'Sin comics aún',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Agrega tu primer comic para comenzar.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: widget.onAddComic,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Comic'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
