import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Library/presenter/controller/library_controller.dart';

class RenameCategoryDialog extends ConsumerStatefulWidget {
  final String currentName;
  final String type; // 'author', 'genre', 'collection'

  const RenameCategoryDialog({
    super.key,
    required this.currentName,
    required this.type,
  });

  @override
  ConsumerState<RenameCategoryDialog> createState() => _RenameCategoryDialogState();
}

class _RenameCategoryDialogState extends ConsumerState<RenameCategoryDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Renombrar ${widget.type}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Nuevo nombre',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre no puede estar vacío';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final newName = _controller.text.trim();
              if (newName != widget.currentName) {
                try {
                  await ref
                      .read(libraryControllerProvider(widget.type).notifier)
                      .renameCategory(widget.currentName, newName, widget.type);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Renombrado con éxito')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al renombrar')),
                    );
                  }
                }
              } else {
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
