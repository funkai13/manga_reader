import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../controller/comic_viewer_controller.dart';

class ComicViewerScreen extends ConsumerStatefulWidget {
  final String filePath;

  const ComicViewerScreen({super.key, required this.filePath});

  @override
  ConsumerState<ComicViewerScreen> createState() => _ComicViewerScreenState();
}

class _ComicViewerScreenState extends ConsumerState<ComicViewerScreen> {
  final PageController _pageController = PageController();
  final Map<int, double> _pageScales = {};
  int _currentPageIndex = 0;
  bool _showControls = false;
  bool _mangaMode = false;
  late Timer _longPressTimer;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _pageController.addListener(_updateCurrentPage);

    Future(() {
      ref
          .read(comicViewerControllerProvider.notifier)
          .loadComic(widget.filePath);
    });
  }

  void _startLongPress() {
    _longPressTimer = Timer(const Duration(milliseconds: 300), () async {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 50);
      }
      setState(() {
        _isLongPressing = true;
        _showControls = true;
      });
    });
  }

  void _endLongPress() {
    _longPressTimer.cancel();
    if (_isLongPressing) {
      setState(() => _isLongPressing = false);
    }
  }

  void _updateCurrentPage() {
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPageIndex) {
      setState(() => _currentPageIndex = newPage);
    }
  }

  bool get _enablePageView => (_pageScales[_currentPageIndex] ?? 1.0) == 1.0;

  void _toggleControls() => setState(() => _showControls = !_showControls);

  void _toggleMangaMode() => setState(() => _mangaMode = !_mangaMode);

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comicState = ref.watch(comicViewerControllerProvider);
    final totalPages = comicState.maybeWhen(
      data: (images) => images.length,
      orElse: () => 0,
    );
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
            _buildComicViewer(comicState, totalPages),
            if (_showControls) _buildControlsOverlay(totalPages),
            if (_isLongPressing) _buildLongPressFeedback(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(int totalPages) {
    final progress =
        totalPages > 0 ? (_currentPageIndex + 1) / totalPages : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.transparent,
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _mangaMode ? Icons.book : Icons.menu_book,
                    color: Colors.white,
                  ),
                  onPressed: _toggleMangaMode,
                ),
              ],
            ),
            _buildBottomControls(progress, totalPages),
          ],
        ),
      ),
    );
  }

  Widget _buildLongPressFeedback() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Icon(Icons.touch_app, size: 50, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomControls(double progress, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Página ${_currentPageIndex + 1}',
                style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${totalPages} Páginas',
                style: const TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.8),
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          /* Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 32),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: Colors.white, size: 32),
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }

  Widget _buildComicViewer(AsyncValue<List<File>> comicState, int totalPages) {
    return comicState.when(
      data: (images) => PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        reverse: _mangaMode,
        // Invierte dirección para manga
        physics: _enablePageView
            ? const PageScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: images.length,
        itemBuilder: (context, index) => ComicPage(
          image: images[index],
          onScaleChanged: (scale) => setState(() => _pageScales[index] = scale),
          initialScale: _pageScales[index] ?? 1.0,
        ),
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

class _ComicPageState extends State<ComicPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
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
    super.build(context);
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

  @override
  bool get wantKeepAlive => true;
}
