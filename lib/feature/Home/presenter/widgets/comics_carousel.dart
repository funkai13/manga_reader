import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manga_reader/core/theme/colors.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';
import 'package:manga_reader/feature/Home/presenter/screen/comic_viewer_screen.dart';

import 'comic_card.dart';

class ComicsCarousel extends StatelessWidget {
  final String title;
  final List<ComicEntity> comics;

  const ComicsCarousel({required this.title, required this.comics, super.key});

  @override
  Widget build(BuildContext context) {
    if (comics.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColorsDark.textColor
                  : AppColorsLight.textColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 280.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: comics.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ComicViewerScreen(comic: comics[index]),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(right: 16.w),
                  width: 160.w,
                  child: ComicCard(comic: comics[index]),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
