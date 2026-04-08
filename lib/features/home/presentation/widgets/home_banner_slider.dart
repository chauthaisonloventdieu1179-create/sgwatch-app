import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/home/data/models/banner_model.dart';
import 'package:video_player/video_player.dart';

class HomeBannerSlider extends StatefulWidget {
  final List<BannerModel> banners;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<BannerModel>? onBannerTap;

  const HomeBannerSlider({
    super.key,
    required this.banners,
    this.onPageChanged,
    this.onBannerTap,
  });

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  static const _multiplier = 1000;
  late PageController _pageController;
  int _currentPage = 0; // real index (0..banners.length-1)
  int _rawPage = 0; // raw PageView index
  Timer? _autoScrollTimer;

  // Video controllers keyed by banner index
  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _initPageController();
    _initVideoControllers();
    _startAutoScrollForImages();
  }

  @override
  void didUpdateWidget(covariant HomeBannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi banner list thay đổi (từ empty → có data, hoặc refresh)
    if (!_bannersEqual(oldWidget.banners, widget.banners)) {
      _autoScrollTimer?.cancel();
      for (final vc in _videoControllers.values) {
        vc.dispose();
      }
      _videoControllers.clear();
      _currentPage = 0;
      _pageController.dispose();
      _initPageController();
      _initVideoControllers();
      _startAutoScrollForImages();
      if (mounted) setState(() {});
    }
  }

  bool _bannersEqual(List<BannerModel> a, List<BannerModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].imageUrl != b[i].imageUrl) return false;
    }
    return true;
  }

  void _initPageController() {
    final initialRaw = widget.banners.isEmpty
        ? 0
        : widget.banners.length * _multiplier;
    _rawPage = initialRaw;
    _pageController = PageController(initialPage: initialRaw);
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    for (final vc in _videoControllers.values) {
      vc.dispose();
    }
    super.dispose();
  }

  void _initVideoControllers() {
    for (int i = 0; i < widget.banners.length; i++) {
      final banner = widget.banners[i];
      if (banner.isVideo) {
        final controller =
            VideoPlayerController.networkUrl(Uri.parse(banner.imageUrl))
              ..setLooping(false)
              ..setVolume(1.0);
        controller.initialize().then((_) {
          if (mounted) {
            setState(() {});
            // Auto-play first video
            if (i == 0) controller.play();
          }
        });
        // When video ends, go to next banner
        controller.addListener(() {
          if (controller.value.isInitialized &&
              controller.value.position >= controller.value.duration &&
              controller.value.duration > Duration.zero) {
            _goToNextPage();
          }
        });
        _videoControllers[i] = controller;
      }
    }
  }

  void _startAutoScrollForImages() {
    _autoScrollTimer?.cancel();
    if (widget.banners.isEmpty) return;
    final current = widget.banners[_currentPage];
    if (!current.isVideo) {
      _autoScrollTimer = Timer(const Duration(seconds: 4), _goToNextPage);
    }
  }

  void _goToNextPage() {
    if (!mounted || widget.banners.isEmpty) return;
    _rawPage++;
    _pageController.animateToPage(
      _rawPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int rawIndex) {
    final realIndex = rawIndex % widget.banners.length;

    // Pause previous video
    if (_videoControllers.containsKey(_currentPage)) {
      _videoControllers[_currentPage]!.pause();
      _videoControllers[_currentPage]!.seekTo(Duration.zero);
    }

    _rawPage = rawIndex;
    setState(() => _currentPage = realIndex);
    widget.onPageChanged?.call(realIndex);

    // Play current video or start auto-scroll timer for images
    if (_videoControllers.containsKey(realIndex)) {
      _autoScrollTimer?.cancel();
      _videoControllers[realIndex]!.seekTo(Duration.zero);
      _videoControllers[realIndex]!.play();
    } else {
      _startAutoScrollForImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length * _multiplier * 2,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, rawIndex) {
              final index = rawIndex % widget.banners.length;
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: () {
                  if (banner.isVideo && _videoControllers.containsKey(index)) {
                    _openFullScreenVideo(index);
                  } else {
                    widget.onBannerTap?.call(banner);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.backgroundGrey,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: banner.isVideo
                      ? _buildVideo(index)
                      : CachedNetworkImage(
                          imageUrl: banner.imageUrl,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (_, __) => Container(
                            color: AppColors.backgroundGrey,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.greyLight,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(Icons.image,
                                size: 48, color: AppColors.greyLight),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentPage == index
                    ? AppColors.black
                    : AppColors.greyLight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openFullScreenVideo(int index) {
    final controller = _videoControllers[index]!;
    // Pause in banner
    controller.pause();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenVideoPage(
          videoUrl: widget.banners[index].imageUrl,
          initialPosition: controller.value.position,
        ),
      ),
    ).then((_) {
      // Resume in banner when back
      if (mounted) {
        controller.seekTo(Duration.zero);
        controller.play();
      }
    });
  }

  Widget _buildVideo(int index) {
    final controller = _videoControllers[index];
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.greyLight,
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

// ── Full-screen video player ────────────────────────────────
class _FullScreenVideoPage extends StatefulWidget {
  final String videoUrl;
  final Duration initialPosition;

  const _FullScreenVideoPage({
    required this.videoUrl,
    required this.initialPosition,
  });

  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(false)
      ..setVolume(1.0);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
        _controller.seekTo(widget.initialPosition);
        _controller.play();
        _startHideTimer();
      }
    });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
      _startHideTimer();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video
            if (_controller.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            // Controls overlay
            if (_showControls) ...[
              // Close button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Play/Pause center button
              if (_controller.value.isInitialized)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              // Progress bar + time
              if (_controller.value.isInitialized)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: AppColors.primary,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
