import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  int? _expandedIndex;

  // Video controllers for each video section
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, bool> _isMuted = {};

  static const _videoSections = <int, String>{
    2: 'assets/videos/huongdanchuyentienATM.mp4',
    3: 'assets/videos/huongdanchuyentienyuucho.mp4',
    4: 'assets/videos/huongdancatday.mp4',
    5: 'assets/videos/huongdandidencuahang.mp4',
  };

  @override
  void dispose() {
    for (final vc in _videoControllers.values) {
      vc.dispose();
    }
    super.dispose();
  }

  void _onSectionTap(int index) {
    final wasExpanded = _expandedIndex == index;

    // Pause previous video if switching sections
    if (_expandedIndex != null && _videoControllers.containsKey(_expandedIndex)) {
      _videoControllers[_expandedIndex]!.pause();
    }

    setState(() {
      _expandedIndex = wasExpanded ? null : index;
    });

    // If expanding a video section, init & play
    if (!wasExpanded && _videoSections.containsKey(index)) {
      _initAndPlayVideo(index);
    }
  }

  void _initAndPlayVideo(int index) {
    final path = _videoSections[index]!;

    if (_videoControllers.containsKey(index)) {
      // Already initialized, just play
      final vc = _videoControllers[index]!;
      vc.seekTo(Duration.zero);
      vc.play();
      return;
    }

    final controller = VideoPlayerController.asset(path)
      ..setLooping(true)
      ..setVolume(1.0);
    _videoControllers[index] = controller;
    _isMuted[index] = false;

    controller.addListener(() {
      if (mounted) setState(() {});
    });
    controller.initialize().then((_) {
      if (mounted && _expandedIndex == index) {
        controller.play();
        setState(() {});
      }
    });
  }

  void _toggleMute(int index) {
    final controller = _videoControllers[index];
    if (controller == null) return;

    setState(() {
      _isMuted[index] = !(_isMuted[index] ?? false);
      controller.setVolume(_isMuted[index]! ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: const Color(0x0D000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hướng dẫn',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SelectionArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpandableSection(
              index: 0,
              number: 1,
              title: 'HƯỚNG DẪN TẠO TÀI KHOẢN',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStep(
                    'Bước 1 - Tạo tài khoản',
                    'Mở ứng dụng SGWATCH, tại màn hình đăng nhập bạn nhấn vào nút "Tạo tài khoản" ở phía dưới.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanh1.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 2 - Điền thông tin',
                    'Điền đầy đủ các thông tin sau:\n'
                        '  - Email: nhập địa chỉ email của bạn\n'
                        '  - Họ và tên: nhập đúng họ tên của bạn\n'
                        '  - Mật khẩu: đặt mật khẩu bạn muốn dùng\n\n'
                        'Sau khi điền xong, nhấn nút "Đăng ký" để tiếp tục.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdan2.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 3 - Xác nhận OTP',
                    'Hệ thống sẽ gửi mã OTP (gồm 6 số) đến email bạn đã đăng ký.\n\n'
                        'Mở email, tìm mã OTP rồi nhập vào ô "Mã xác nhận" trên ứng dụng.\n\n'
                        'Lưu ý: Email có thể đến chậm vài phút, hãy kiểm tra cả mục Spam/Junk nếu không thấy.\n\n'
                        'Nhấn nút "Xác nhận" để hoàn tất đăng ký.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdan3.png'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildExpandableSection(
              index: 1,
              number: 2,
              title: 'HƯỚNG DẪN MUA HÀNG',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStep(
                    'Bước 1 — Đảm bảo bạn đã có tài khoản',
                    'Trước khi mua hàng, bạn cần đăng nhập vào ứng dụng.\n\n'
                        'Nếu chưa có tài khoản, vui lòng xem lại mục "HƯỚNG DẪN TẠO TÀI KHOẢN" ở trên để đăng ký trước.',
                  ),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 2 — Tìm kiếm sản phẩm',
                    'Bạn có thể tìm sản phẩm theo nhiều cách:\n\n'
                        '  • Nếu biết tên hoặc mã sản phẩm → nhập vào ô tìm kiếm.\n'
                        '  • Nếu chưa biết cụ thể → duyệt theo hãng hoặc danh mục phù hợp.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang1.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 3 — Xem danh sách & chọn sản phẩm',
                    'Kết quả tìm kiếm sẽ hiển thị danh sách sản phẩm phù hợp.\n\n'
                        '  • Bạn có thể nhấn nút "Mua" ngay tại danh sách.\n'
                        '  • Hoặc nhấn vào sản phẩm để xem đầy đủ thông tin chi tiết, sau đó nhấn "Mua ngay".\n\n'
                        'Sau khi nhấn "Mua", ứng dụng sẽ tự động đưa bạn đến giỏ hàng.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang2.png'),
                  const SizedBox(height: 12),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang3.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 4 — Giỏ hàng',
                    'Tại giỏ hàng, bạn có thể:\n\n'
                        '  • Quay lại tiếp tục tìm và thêm sản phẩm khác.\n'
                        '  • Hoặc nhấn nút "Thanh Toán" để tiến hành đặt hàng ngay.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang4.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 5 — Chọn địa chỉ nhận hàng',
                    'Tại màn hình thanh toán, bước đầu tiên là chọn địa chỉ nhận hàng.\n\n'
                        'Nếu chưa có địa chỉ nào, nhấn nút "+ Thêm mới" để tạo địa chỉ.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang5.png'),
                  const SizedBox(height: 12),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang6.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 5.1 — Tạo địa chỉ tại Nhật Bản',
                    'Chọn quốc gia "Nhật Bản" và điền đầy đủ thông tin:\n\n'
                        '  • Tên địa chỉ (ví dụ: Nhà riêng, Văn phòng...)\n'
                        '  • Mã bưu điện: nhập đúng mã, ứng dụng sẽ tự động điền tỉnh/thành phố tương ứng.\n'
                        '  • Số nhà / Địa chỉ chi tiết\n'
                        '  • Tên tòa nhà (nếu có)\n'
                        '  • Số phòng (nếu có)\n'
                        '  • Số điện thoại liên lạc',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang7.1.png'),
                  const SizedBox(height: 12),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang7.2.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 5.2 — Tạo địa chỉ tại Việt Nam',
                    'Chọn quốc gia "Việt Nam" và điền đầy đủ thông tin:\n\n'
                        '  • Tên địa chỉ (ví dụ: Nhà riêng, Văn phòng...)\n'
                        '  • Tỉnh / Thành phố\n'
                        '  • Quận / Huyện\n'
                        '  • Phường / Xã\n'
                        '  • Địa chỉ chi tiết (số nhà, tên đường...)\n'
                        '  • Mã bưu điện\n'
                        '  • Tên tòa nhà (nếu có)\n'
                        '  • Số phòng (nếu có)\n'
                        '  • Số điện thoại liên lạc',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang8.1.png'),
                  const SizedBox(height: 12),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang8.2.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 6 — Hoàn tất thông tin đặt hàng',
                    'Sau khi chọn địa chỉ, địa chỉ đó sẽ được áp dụng cho đơn hàng này.\n\n'
                        '📝 Ghi chú: Nếu bạn có yêu cầu về thời gian giao hàng hoặc lưu ý đặc biệt, hãy điền vào phần ghi chú.\n\n'
                        '🏷️ Mã giảm giá: Nhập mã và nhấn "Áp dụng" để kiểm tra mã có còn hiệu lực không.\n\n'
                        '⭐ Điểm thưởng (Point): Nếu có điểm tích lũy, bạn có thể dùng để giảm trực tiếp vào đơn hàng.\n\n'
                        'Bạn có thể chỉnh sửa địa chỉ bất kỳ lúc nào tại: Trang cá nhân → Địa chỉ → Chỉnh sửa.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang9.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 7 — Chọn phương thức thanh toán',
                    'Với địa chỉ tại Nhật Bản, có 3 phương thức:\n'
                        '  1. Chuyển khoản ngân hàng\n'
                        '  2. Daibiki (代引き) — Thanh toán tiền mặt khi nhận hàng\n'
                        '  3. Stripe — Thanh toán bằng thẻ quốc tế (Visa, Mastercard, AmEx, JCB...)\n\n'
                        'Với địa chỉ tại Việt Nam, có 3 phương thức:\n'
                        '  1. Chuyển khoản ngân hàng toàn bộ\n'
                        '  2. Cọc 1 triệu — Thanh toán phần còn lại khi nhận hàng\n'
                        '  3. Stripe — Thanh toán bằng thẻ quốc tế\n\n'
                        'Chọn phương thức phù hợp rồi nhấn "Đặt hàng" để hoàn tất.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanmuahang/hdmuahang10.png'),
                  _buildStepDivider(),
                  _buildStep(
                    'Bước 8 — Sau khi đặt hàng',
                    '💳 Nếu chọn chuyển khoản / Daibiki / Cọc 1 triệu:\n'
                        'Màn hình tiếp theo sẽ hiển thị thông tin số tài khoản để thanh toán và ô upload hóa đơn.\n'
                        'Sau khi chuyển khoản, vui lòng gửi kèm hóa đơn qua tin nhắn CSKH để được xác nhận nhanh nhất.\n\n'
                        'Bạn cũng có thể xem lại thông tin thanh toán và upload hóa đơn tại:\n'
                        'Trang cá nhân → Đơn hàng → Chờ xác nhận → Chọn đơn hàng.\n\n'
                        '💳 Nếu chọn thanh toán qua Stripe:\n'
                        'Điền thông tin thẻ và nhấn "Pay" để thanh toán trực tiếp ngay trong ứng dụng.',
                  ),
                  const SizedBox(height: 16),
                  _buildImage('assets/images/huongdanmuahang/hdmuahnag11.png'),
                  _buildStepDivider(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      '✅ Sau khi đơn hàng được xác nhận, chúng tôi sẽ chuẩn bị và giao hàng đến bạn trong thời gian sớm nhất.\n\n'
                      '💬 Nếu có bất kỳ thắc mắc nào, bạn có thể liên hệ với chúng tôi qua phòng chat CSKH — luôn sẵn sàng hỗ trợ 24/7.\n\n'
                      '🙏 Rất mong nhận được sự ủng hộ từ quý khách!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildExpandableSection(
              index: 2,
              number: 3,
              title: 'HƯỚNG DẪN CHUYỂN TIỀN QUA CÂY ATM',
              child: _buildVideoPlayer(2),
            ),
            const SizedBox(height: 12),
            _buildExpandableSection(
              index: 3,
              number: 4,
              title: 'HƯỚNG DẪN CHUYỂN TIỀN QUA APP YUUCHO',
              child: _buildVideoPlayer(3),
            ),
            const SizedBox(height: 12),
            _buildExpandableSection(
              index: 4,
              number: 5,
              title: 'HƯỚNG DẪN THÁO MẮT TẠI NHÀ',
              child: _buildVideoPlayer(4),
            ),
            const SizedBox(height: 12),
            _buildExpandableSection(
              index: 5,
              number: 6,
              title: 'HƯỚNG DẪN ĐI ĐẾN CỬA HÀNG',
              child: _buildVideoPlayer(5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required int index,
    required int number,
    required String title,
    required Widget child,
  }) {
    final isExpanded = _expandedIndex == index;
    return Container(
      width: double.infinity,
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
        children: [
          // Header (always visible, tappable)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onSectionTap(index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$number',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content (collapsible)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(int index) {
    final controller = _videoControllers[index];
    if (controller == null || !controller.value.isInitialized) return;
    controller.pause();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenVideoPlayer(
          controller: controller,
          onMuteToggle: () => _toggleMute(index),
          isMuted: _isMuted[index] ?? false,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _togglePlayPause(int index) {
    final controller = _videoControllers[index];
    if (controller == null) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  Widget _buildVideoPlayer(int index) {
    final controller = _videoControllers[index];
    final muted = _isMuted[index] ?? false;

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          // Video + overlay controls
          GestureDetector(
            onTap: () => _togglePlayPause(index),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
                // Play/Pause overlay (show when paused)
                if (!controller.value.isPlaying)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                // Mute button
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () => _toggleMute(index),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        muted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                // Fullscreen button
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: () => _openFullScreen(index),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Progress bar (seekable)
          VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.only(top: 4),
            colors: const VideoProgressColors(
              playedColor: AppColors.primary,
              bufferedColor: Color(0x40000000),
              backgroundColor: Color(0x20000000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(height: 1.5, color: AppColors.primary.withValues(alpha: 0.35)),
          const SizedBox(height: 4),
          Container(height: 1.5, color: AppColors.primary.withValues(alpha: 0.15)),
        ],
      ),
    );
  }

  Widget _buildStep(String stepTitle, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              stepTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        assetPath,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (_, __, ___) => Container(
          height: 200,
          color: AppColors.backgroundGrey,
          child: const Center(
            child: Icon(Icons.image, size: 48, color: AppColors.greyLight),
          ),
        ),
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onMuteToggle;
  final bool isMuted;

  const _FullScreenVideoPlayer({
    required this.controller,
    required this.onMuteToggle,
    required this.isMuted,
  });

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late bool _muted;

  @override
  void initState() {
    super.initState();
    _muted = widget.isMuted;
    widget.controller.addListener(_onChanged);
    widget.controller.play();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      widget.controller.setVolume(_muted ? 0.0 : 1.0);
    });
    widget.onMuteToggle();
  }

  void _togglePlayPause() {
    setState(() {
      widget.controller.value.isPlaying
          ? widget.controller.pause()
          : widget.controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          // Play/Pause overlay
          if (!controller.value.isPlaying)
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () {
                widget.controller.pause();
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),
          // Mute button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          // Progress bar
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.primary,
                bufferedColor: Color(0x60FFFFFF),
                backgroundColor: Color(0x30FFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
