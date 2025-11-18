// lib/feature/Home/presenter/widgets/long_press_overlay.dart

import 'package:flutter/material.dart';

class LongPressOverlay extends StatelessWidget {
  final bool visible;

  const LongPressOverlay({
    super.key,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      color: Colors.black54,
      child: const Center(
        child: Icon(
          Icons.touch_app,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}
