import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LongPressOverlay extends StatelessWidget {
  final bool visible;

  const LongPressOverlay({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Icon(
              Icons.touch_app,
              size: 50.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
