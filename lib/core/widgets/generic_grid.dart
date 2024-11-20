import 'package:flutter/cupertino.dart';

class GenericGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final double maxCrossAxisExtent;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double mainAxisExtent;

  const GenericGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.maxCrossAxisExtent,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.mainAxisExtent,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisExtent: mainAxisExtent,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return itemBuilder(item);
        });
  }
}
