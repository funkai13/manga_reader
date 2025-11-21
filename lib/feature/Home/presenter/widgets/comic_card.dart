import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manga_reader/core/theme/colors.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';

class ComicCard extends StatelessWidget {
  final ComicEntity comic;
  final double scale;

  const ComicCard({super.key, required this.comic, required this.scale});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12 * scale,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r * scale),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (comic.picture.isNotEmpty)
                Image.file(
                  File(comic.picture),
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(isDark);
                  },
                )
              else
                _buildPlaceholder(isDark),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w * scale,
                    vertical: 6.h * scale,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(isDark),
                      if (comic.currentReadPage > 0 && !comic.isCompleted)
                        Text(
                          'Pág. ${comic.currentReadPage + 1}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColorsDark.cardColor : AppColorsLight.cardColor,
      child: Center(
        child: Icon(
          Icons.book,
          color: isDark
              ? AppColorsDark.textColor.withValues(alpha: 0.3)
              : AppColorsLight.textColor.withValues(alpha: 0.3),
          size: 40.sp * scale,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isDark) {
    String? label;
    Color? color;

    if (comic.isCompleted) {
      label = 'Completado';
      color = Colors.greenAccent.shade400;
    } else if (comic.isReading) {
      label = 'Leyendo';
      color = Colors.orangeAccent.shade400;
    } else if (comic.currentReadPage == 0) {
      label = 'Nuevo';
      color = Colors.blueAccent.shade400;
    }

    if (label == null || color == null) {
      return const SizedBox.shrink();
    }

    if (isDark) {
      color = color.withValues(alpha: 0.9);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w * scale,
        vertical: 4.h * scale,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999.r * scale),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp * scale,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
