import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manga_reader/feature/Library/presenter/controller/library_controller.dart';
import 'package:manga_reader/feature/Library/presenter/screens/filtered_comics_screen.dart';
import 'package:manga_reader/feature/Library/presenter/widgets/category_card.dart';
import 'package:manga_reader/feature/Library/presenter/widgets/rename_category_dialog.dart';

class CategoryGridWidget extends ConsumerWidget {
  final String type; // 'author', 'genre', 'collection'

  const CategoryGridWidget({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryControllerProvider(type));
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final scale = isTablet ? 0.8 : 1.0;

    return state.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Text('No hay elementos en esta categoría'),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.all(16.w * scale),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7, // Matches ComicCard aspect ratio
            crossAxisSpacing: 16.w * scale,
            mainAxisSpacing: 16.h * scale,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(
              category: category,
              scale: scale,
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
              onEdit: () {
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
