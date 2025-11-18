import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/feature/Home/domain/entity/comic.dart';
import 'package:manga_reader/feature/Home/presenter/controller/comic_controller.dart';
import 'package:manga_reader/feature/Home/presenter/widgets/comic_page_view.dart';
import 'package:manga_reader/feature/Home/presenter/widgets/long_press_overlay.dart';
import 'package:vibration/vibration.dart';

import '../controller/comic_viewer_controller.dart';
import '../widgets/comic_controls_overlay.dart';
import '../widgets/comic_page_grid_dialog.dart';

class ComicViewerScreen extends ConsumerStatefulWidget {
  final ComicEntity comic;

  const ComicViewerScreen({super.key, required this.comic});

  @override
  ConsumerState<ComicViewerScreen> createState() => _ComicViewerScreenState();
}

class _ComicViewerScreenState extends ConsumerState<ComicViewerScreen> {
  late final PageController _pageController;
  final Map<int, double> _pageScales = {};
  int _currentPageIndex = 0;
  bool _showControls = false;
  bool _mangaMode = false;
  Timer? _longPressTimer;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadComicAndJumpToInitialPage();
    });
  }

  Future<void> _loadComicAndJumpToInitialPage() async {
    await ref
        .read(comicViewerControllerProvider.notifier)
        .loadComic(widget.comic.imagesPath, widget.comic.id!);

    if (!mounted) return;

    final images = ref.read(comicViewerControllerProvider).value ?? <File>[];

    if (images.isEmpty) return;

    final totalPages = images.length;
    final targetPage = widget.comic.currentReadPage.clamp(0, totalPages - 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_pageController.hasClients) return;
      _pageController.jumpToPage(targetPage);
    });
  }

  void _startLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = Timer(const Duration(milliseconds: 300), () async {
      final hasVibrator = (await Vibration.hasVibrator()) ?? false;
      if (hasVibrator) {
        Vibration.vibrate(duration: 50);
      }
      if (!mounted) return;
      setState(() {
        _isLongPressing = true;
        _showControls = true;
      });
    });
  }

  void _endLongPress() {
    _longPressTimer?.cancel();
    if (_isLongPressing) {
      setState(() => _isLongPressing = false);
    }
  }

  bool get _enablePageView => (_pageScales[_currentPageIndex] ?? 1.0) == 1.0;

  void _toggleControls() => setState(() => _showControls = !_showControls);

  void _toggleMangaMode() => setState(() => _mangaMode = !_mangaMode);

  void _toggleBookMark() {
    ref
        .read(comicControllerProvider.notifier)
        .createBookmark(widget.comic.id!, _currentPageIndex, widget.comic);
  }

  void _goBack() {
    _toggleBookMark();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _longPressTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comicState = ref.watch(comicViewerControllerProvider);

    final images = comicState.maybeWhen(
      data: (imgs) => imgs,
      orElse: () => <File>[],
    );
    final totalPages = images.length;
    return PopScope(
      canPop: !_showControls,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && _showControls) {
          _toggleControls();
        }
      },
      child: GestureDetector(
        onLongPressStart: (_) => _startLongPress(),
        onLongPressEnd: (_) => _endLongPress(),
        onTap: () {
          if (_showControls) _toggleControls();
        },
        child: Stack(
          children: [
            _buildComicViewer(comicState),
            if (_showControls)
              ComicControlsOverlay(
                currentPageIndex: _currentPageIndex,
                totalPages: totalPages,
                mangaMode: _mangaMode,
                isBookmarked: widget.comic.currentReadPage == _currentPageIndex,
                onBack: _goBack,
                onToggleBookmark: _toggleBookMark,
                onToggleMangaMode: _toggleMangaMode,
                onOpenPageGrid: () => _showPageSelector(images),
                onPageSelected: (page) {
                  _pageController.animateToPage(
                    page,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            LongPressOverlay(visible: _isLongPressing)
          ],
        ),
      ),
    );
  }

  void _showPageSelector(List<File> images) {
    if (images.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => ComicPageGridDialog(
        images: images,
        currentPageIndex: _currentPageIndex,
        mangaMode: _mangaMode,
        onPageSelected: (page) {
          Navigator.of(context).pop();
          _pageController.animateToPage(
            page,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  Widget _buildComicViewer(AsyncValue<List<File>> comicState) {
    return comicState.when(
      data: (images) => ComicPageView(
        controller: _pageController,
        images: images,
        mangaMode: _mangaMode,
        enablePageScroll: _enablePageView,
        pageScales: _pageScales,
        onPageScaleChanged: (index, scale) {
          setState(() => _pageScales[index] = scale);
        },
        onPageChanged: (index) {
          setState(() => _currentPageIndex = index);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class ComicPage extends StatefulWidget {
  final File image;
  final Function(double) onScaleChanged;
  final double initialScale;

  const ComicPage({
    super.key,
    required this.image,
    required this.onScaleChanged,
    required this.initialScale,
  });

  @override
  State<ComicPage> createState() => _ComicPageState();
}

class _ComicPageState extends State<ComicPage> with TickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final AnimationController _animationController;
  late Offset _doubleTapLocalPosition = Offset.zero;
  final double minScale = 1.0;
  final double maxScale = 5.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformChanged);
    _transformationController.value = Matrix4.identity()
      ..scale(widget.initialScale);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    widget.onScaleChanged(scale);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _animateTransition(Matrix4 endMatrix) {
    final animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    animation.addListener(() {
      _transformationController.value = animation.value;
    });
    _animationController.forward(from: 0);
  }

  void _onDoubleTap() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final targetScale = currentScale <= minScale ? maxScale : minScale;

    final newMatrix = Matrix4.identity()
      ..translate(
        -_doubleTapLocalPosition.dx * (targetScale - 1),
        -_doubleTapLocalPosition.dy * (targetScale - 1),
      )
      ..scale(targetScale);
    _animateTransition(newMatrix);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onDoubleTapDown: (details) {
        _doubleTapLocalPosition = details.localPosition;
      },
      child: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(20),
        maxScale: maxScale,
        minScale: minScale,
        onInteractionUpdate: (_) => widget.onScaleChanged(
            _transformationController.value.getMaxScaleOnAxis()),
        child: Image.file(widget.image),
      ),
    );
  }
}
