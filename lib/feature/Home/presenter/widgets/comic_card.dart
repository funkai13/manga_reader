import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manga_reader/core/theme/colors.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';

class ComicCard extends StatelessWidget {
  final ComicEntity comic;

  const ComicCard({super.key, required this.comic});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: comic.picture.isNotEmpty
                  ? Image.file(
                      File(comic.picture),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark
                              ? AppColorsDark.cardColor
                              : AppColorsLight.cardColor,
                          child: Icon(
                            Icons.image_not_supported,
                            color: isDark
                                ? AppColorsDark.textColor.withOpacity(0.3)
                                : AppColorsLight.textColor.withOpacity(0.3),
                            size: 40.sp,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: isDark
                          ? AppColorsDark.cardColor
                          : AppColorsLight.cardColor,
                      child: Icon(
                        Icons.book,
                        color: isDark
                            ? AppColorsDark.textColor.withOpacity(0.3)
                            : AppColorsLight.textColor.withOpacity(0.3),
                        size: 40.sp,
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          comic.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColorsDark.textColor
                : AppColorsLight.textColor,
            height: 1.3,
          ),
        ),
        if (comic.isReading)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColorsDark.accentColor
                        : AppColorsLight.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Leyendo',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColorsDark.accentColor
                        : AppColorsLight.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
