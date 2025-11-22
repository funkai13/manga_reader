import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';
import 'package:manga_reader/feature/Home/presenter/widgets/custom_autocomplete_field.dart';

class EditComicScreen extends ConsumerStatefulWidget {
  final ComicEntity comic;

  const EditComicScreen({super.key, required this.comic});

  @override
  ConsumerState<EditComicScreen> createState() => _EditComicScreenState();
}

class _EditComicScreenState extends ConsumerState<EditComicScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _genreController;
  late final TextEditingController _collectionController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.comic.title);
    _authorController = TextEditingController(text: widget.comic.author);
    _genreController = TextEditingController(text: widget.comic.genre);
    _collectionController = TextEditingController(text: widget.comic.collection);
    _selectedType = widget.comic.comicType ?? 'Manga';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _collectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(comicControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cómic'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomAutocompleteField(
                label: 'Autor',
                controller: _authorController,
                optionsBuilder: () => controller.getSuggestions('author'),
                onSelected: (value) => _authorController.text = value,
              ),
              const SizedBox(height: 16),
              CustomAutocompleteField(
                label: 'Género',
                controller: _genreController,
                optionsBuilder: () => controller.getSuggestions('genre'),
                onSelected: (value) => _genreController.text = value,
              ),
              const SizedBox(height: 16),
              CustomAutocompleteField(
                label: 'Colección',
                controller: _collectionController,
                optionsBuilder: () => controller.getSuggestions('collection'),
                onSelected: (value) => _collectionController.text = value,
              ),
              const SizedBox(height: 24),
              Text(
                'Tipo de Lectura',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'Manga',
                    label: Text('Manga'),
                    icon: Icon(Icons.auto_stories),
                  ),
                  ButtonSegment<String>(
                    value: 'Comic',
                    label: Text('Cómic'),
                    icon: Icon(Icons.menu_book),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(comicControllerProvider.notifier).updateComicMetadata(
          id: widget.comic.id!,
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          genre: _genreController.text.trim(),
          collection: _collectionController.text.trim(),
          comicType: _selectedType,
        );
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cambios guardados')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar cambios')),
          );
        }
      }
    }
  }
}
