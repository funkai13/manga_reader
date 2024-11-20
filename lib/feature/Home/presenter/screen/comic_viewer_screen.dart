import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/comic_viewer_controller.dart';

class ComicViewerScreen extends ConsumerStatefulWidget {
  final String filePath;

  const ComicViewerScreen({super.key, required this.filePath});

  @override
  ConsumerState<ComicViewerScreen> createState() => _ComicViewerScreenState();
}

class _ComicViewerScreenState extends ConsumerState<ComicViewerScreen> {
  @override
  void initState() {
    super.initState();
    Future(() {
      ref
          .read(comicViewerControllerProvider.notifier)
          .loadComic(widget.filePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final comicState = ref.watch(comicViewerControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Comic Viewer')),
      body: comicState.when(
        data: (images) => PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Image.file(images[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
