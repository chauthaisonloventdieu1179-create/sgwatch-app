import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/big_sale/presentation/big_sale_viewmodel.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_screen.dart';
import 'package:sgwatch_app/features/cart/presentation/cart_viewmodel.dart';
import 'package:sgwatch_app/features/favorites/presentation/favorite_viewmodel.dart';
import 'package:sgwatch_app/features/home/presentation/widgets/home_product_card.dart';
import 'package:sgwatch_app/features/home/product_detail/product_detail_screen.dart';
import 'package:video_player/video_player.dart';

class BigSaleScreen extends StatefulWidget {
  final int id;

  const BigSaleScreen({super.key, required this.id});

  @override
  State<BigSaleScreen> createState() => _BigSaleScreenState();
}

class _BigSaleScreenState extends State<BigSaleScreen> {
  final _viewModel = BigSaleViewModel();
  final _favoriteVM = FavoriteViewModel();
  final _cartVM = CartViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
    _favoriteVM.addListener(_onChanged);
    _cartVM.addListener(_onChanged);
    _viewModel.loadBigSale(widget.id);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onBuyTap(product) async {
    if (product.isCarnival == true) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          groupedProducts: product.groupedProducts,
        ),
      ));
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final success = await _cartVM.addToCart(product.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể thêm vào giỏ hàng.')),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _favoriteVM.removeListener(_onChanged);
    _cartVM.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _viewModel.bigSale?.title ?? 'BIG SALE',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _viewModel.error!,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _viewModel.loadBigSale(widget.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final bigSale = _viewModel.bigSale;
    if (bigSale == null) {
      return const Center(
        child: Text(
          'Không có chương trình khuyến mãi.',
          style: TextStyle(color: AppColors.grey, fontSize: 14),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner image / video
          if (bigSale.mediaUrl != null && bigSale.mediaUrl!.isNotEmpty)
            if (bigSale.mediaType == 'video')
              _VideoPlayerWidget(
                videoUrl: bigSale.mediaUrl!,
                thumbnailUrl: bigSale.thumbnailUrl,
              )
            else
              Image.network(
                bigSale.thumbnailUrl?.isNotEmpty == true
                    ? bigSale.thumbnailUrl!
                    : bigSale.mediaUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 220,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Center(
                    child: Icon(Icons.local_offer, size: 48, color: AppColors.primary),
                  ),
                ),
              ),

          // Description
          if (bigSale.description != null && bigSale.description!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bigSale.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bigSale.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      height: 1.5,
                    ),
                  ),
                  if (bigSale.saleStartDate != null && bigSale.saleEndDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Từ ${bigSale.saleStartDate} đến ${bigSale.saleEndDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Products header
          if (bigSale.products.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sản phẩm khuyến mãi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Product grid (same card as home)
          if (bigSale.products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.495,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: bigSale.products.length,
                itemBuilder: (context, index) {
                  final product = bigSale.products[index];
                  return HomeProductCard(
                    product: product,
                    isFavorite: _favoriteVM.isFavorite(product.id),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    onBuyTap: () => _onBuyTap(product),
                    onFavoriteTap: () => _favoriteVM.toggle(product),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Video Player Widget ───────────────────────────────────────────────────────

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const _VideoPlayerWidget({required this.videoUrl, this.thumbnailUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _started = false;
  bool _initialized = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initAndPlay() async {
    setState(() => _started = true);
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller = ctrl;
    await ctrl.initialize();
    ctrl.addListener(_onVideoChanged);
    if (mounted) {
      setState(() => _initialized = true);
      ctrl.play();
      _resetHideTimer();
    }
  }

  void _onVideoChanged() {
    if (mounted) setState(() {});
  }

  void _togglePlayPause() {
    final ctrl = _controller;
    if (ctrl == null) return;
    if (ctrl.value.isPlaying) {
      ctrl.pause();
    } else {
      ctrl.play();
      _resetHideTimer();
    }
    setState(() {});
  }

  void _toggleMute() {
    final ctrl = _controller;
    if (ctrl == null) return;
    ctrl.setVolume(ctrl.value.volume > 0 ? 0 : 1);
    setState(() {});
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _onTapVideo() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _resetHideTimer();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    // Chưa bấm play — hiện thumbnail
    if (!_started) {
      return GestureDetector(
        onTap: _initAndPlay,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
              Image.network(
                widget.thumbnailUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 220,
                  color: Colors.black,
                ),
              )
            else
              Container(width: double.infinity, height: 220, color: Colors.black),
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.black38,
            ),
            const Icon(Icons.play_circle_outline, size: 72, color: Colors.white),
          ],
        ),
      );
    }

    // Đang khởi tạo
    if (!_initialized) {
      return Container(
        width: double.infinity,
        height: 220,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final ctrl = _controller!;
    final isPlaying = ctrl.value.isPlaying;
    final isMuted = ctrl.value.volume == 0;
    final position = ctrl.value.position;
    final duration = ctrl.value.duration;

    return GestureDetector(
      onTap: _onTapVideo,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: ctrl.value.aspectRatio,
              child: VideoPlayer(ctrl),
            ),
            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Seek bar
                    VideoProgressIndicator(
                      ctrl,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white12,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    // Controls row
                    Row(
                      children: [
                        // Play/Pause
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _togglePlayPause,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        // Time
                        Text(
                          '${_formatDuration(position)} / ${_formatDuration(duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        // Mute/Unmute
                        IconButton(
                          icon: Icon(
                            isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _toggleMute,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Center play/pause button khi controls hiện
            if (_showControls)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}