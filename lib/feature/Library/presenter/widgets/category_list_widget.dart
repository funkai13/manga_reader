import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Library/presenter/controller/library_controller.dart';
import 'package:manga_reader/feature/Library/presenter/screens/filtered_comics_screen.dart';
import 'package:manga_reader/feature/Library/presenter/widgets/rename_category_dialog.dart';

class CategoryListWidget extends ConsumerWidget {
  final String type; // 'author', 'genre', 'collection'

  const CategoryListWidget({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryControllerProvider(type));

    return state.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Text('No hay elementos en esta categoría'),
          );
        }
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              title: Text(category.name),
              trailing: Chip(
                label: Text(category.count.toString()),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FilteredComicsScreen(
                      title: category.name,
                      type: type,
                      value: category.name,
                    ),
                  ),
                );
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => RenameCategoryDialog(
                    currentName: category.name,
                    type: type,
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
