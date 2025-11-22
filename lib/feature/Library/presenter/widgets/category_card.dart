import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manga_reader/core/theme/colors.dart';
import 'package:manga_reader/feature/Library/domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final double scale;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.onLongPress,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardColor : AppColorsLight.cardColor,
          borderRadius: BorderRadius.circular(12.r * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8 * scale,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (category.coverPath != null)
              Image.file(
                File(category.coverPath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: isDark
                      ? AppColorsDark.backgroundColor
                      : AppColorsLight.backgroundColor,
                  child: Icon(
                    Icons.image_not_supported,
                    color: isDark
                        ? AppColorsDark.textColor.withValues(alpha: 0.5)
                        : AppColorsLight.textColor.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              Container(
                color: isDark
                    ? AppColorsDark.backgroundColor
                    : AppColorsLight.backgroundColor,
                child: Icon(
                  Icons.category,
                  size: 48.sp * scale,
                  color: isDark
                      ? AppColorsDark.textColor.withValues(alpha: 0.2)
                      : AppColorsLight.textColor.withValues(alpha: 0.2),
                ),
              ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(12.w * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16.sp * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h * scale),
                  Text(
                    '${category.count} cómics',
                    style: TextStyle(
                      fontSize: 12.sp * scale,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
