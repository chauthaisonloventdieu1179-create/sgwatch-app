import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';

class LaptopWarrantyScreen extends StatelessWidget {
  const LaptopWarrantyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: const Color(0x0D000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bảo hành & HDSD Laptop',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.laptop_mac,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CAM KẾT - HƯỚNG DẪN SỬ DỤNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'VÀ BẢO HÀNH MÁY LAPTOP SG CPT',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Shop info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'SG COMPUTER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cảm ơn quý khách hàng đã ủng hộ và đồng hành cùng shop.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.black,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Section 1: Cam kết
            _buildSection(
              icon: Icons.handshake_outlined,
              iconColor: const Color(0xFF4CAF50),
              title: '1. CAM KẾT',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckItem(
                    'Tất cả sản phẩm shop bán ra đều Chính Hãng. Nguyên zin. Chưa qua sửa chữa.',
                  ),
                  const SizedBox(height: 10),
                  _buildCheckItem(
                    'Lỗi 1 Đổi 1 trong 7 ngày. (Mọi chi phí vận chuyển shop chịu 2 đầu)',
                  ),
                  const SizedBox(height: 10),
                  _buildHighlightBox(
                    icon: Icons.shield,
                    text: 'Bảo hành: 6-12 tháng phần cứng. Phần mềm 36 tháng. Pin 01 tháng.',
                    color: const Color(0xFF2196F3),
                  ),
                ],
              ),
            ),

            // Section 2: Lưu ý khi sử dụng - Hướng dẫn sử dụng
            _buildSection(
              icon: Icons.menu_book_outlined,
              iconColor: const Color(0xFFFF9800),
              title: '2. LƯU Ý KHI SỬ DỤNG - HƯỚNG DẪN SỬ DỤNG',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lưu ý đặc biệt
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE0B2)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFFF9800)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Đặt ngón tay Chính Giữa màn hình để lật máy lên. (Vì 2 bản lề 2 bên màn hình nên lúc lật màn lên sử dụng cần mở chính giữa máy) Tránh lật máy 2 cạnh màn hình làm hỏng bản lề, nặng có thể hỏng màn hình.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE65100),
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNumberedItem(
                    '1',
                    'Khi sử dụng thời gian dài nên sạc đầy pin và hạn chế vừa cắm sạc và vừa sử dụng để bảo vệ tuổi thọ pin dài hơn.',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberedItem(
                    '2',
                    'Khi sử dụng nên đặt máy trên mặt bàn cứng, thoáng khí để máy tản nhiệt tốt hơn. Tránh để những nơi ẩm ướt, chăn bông, đệm…!',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberedItem(
                    '3',
                    'Tránh xa nước và các chất ăn mòn ảnh hưởng đến hiệu năng và hỏng hóc máy.',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberedItem(
                    '4',
                    'Trong quá trình sử dụng tránh va đập, đè lên máy tránh hỏng màn hình và bo mạch của máy.',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberedItem(
                    '5',
                    'Trong trường hợp không thể khởi động máy hoặc hỏng hóc máy, vui lòng liên hệ ngay shop để được hỗ trợ kịp thời.',
                  ),
                ],
              ),
            ),

            // Section 3: Các trường hợp được bảo hành miễn phí
            _buildSection(
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF4CAF50),
              title: '3. CÁC TRƯỜNG HỢP ĐƯỢC BẢO HÀNH MIỄN PHÍ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckItem(
                    'Laptop có lỗi được xác định do nhà sản xuất, lỗi phần cứng thuộc phạm vi bảo hành.',
                  ),
                  const SizedBox(height: 10),
                  _buildCheckItem(
                    'Laptop còn trong thời hạn bảo hành. Laptop phải còn nguyên vẹn, không bị cấn móp va đập & chưa bị sửa chữa bởi các bên thứ ba.',
                  ),
                ],
              ),
            ),

            // Section 4: Các trường hợp từ chối bảo hành
            _buildSection(
              icon: Icons.cancel_outlined,
              iconColor: const Color(0xFFF44336),
              title: '4. CÁC TRƯỜNG HỢP TỪ CHỐI BẢO HÀNH',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE0B2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExcludeItem(
                      'Máy bị hư hỏng do thiên tai, tai nạn hoặc côn trùng phá hoại.',
                    ),
                    const SizedBox(height: 8),
                    _buildExcludeItem(
                      'Máy tiếp xúc với chất lỏng hoặc đổ chất lỏng vào máy hoặc được bảo quản/sử dụng trong môi trường ẩm ướt.',
                    ),
                    const SizedBox(height: 8),
                    _buildExcludeItem(
                      'Sử dụng sai điện áp theo quy định của nhà sản xuất.',
                    ),
                    const SizedBox(height: 8),
                    _buildExcludeItem(
                      'Sản phẩm bị sét đánh, cháy nổ, bị biến dạng, bị gỉ sét ăn mòn.',
                    ),
                    const SizedBox(height: 8),
                    _buildExcludeItem(
                      'Các lỗi phát sinh do virus tin học. Hoặc côn trùng và dị vật lọt vào máy.',
                    ),
                    const SizedBox(height: 8),
                    _buildExcludeItem(
                      'Dữ liệu bị mất do quá trình sử dụng/bảo hành không thuộc điều khoản bảo hành. Quý khách hàng nên sao lưu dữ liệu định kỳ và sao lưu dự phòng trước khi đem máy đi bảo hành.',
                    ),
                    const SizedBox(height: 8),
                    _buildExcludeItem(
                      'Tem bảo hành bị rách, bị sửa chữa, hoặc bị dán đè tem khác.',
                    ),
                    const SizedBox(height: 8),
                    _buildExcludeItem(
                      'Các hao mòn về kiểu dáng, vỏ thiết bị do tác động của quá trình sử dụng.',
                    ),
                    const SizedBox(height: 8),
                    _buildExcludeItem(
                      'Các lỗi về phần mềm chỉ được hỗ trợ khắc phục, không thuộc phạm vi bảo hành.',
                    ),
                  ],
                ),
              ),
            ),

            // Section 5: Thời hạn bảo hành
            _buildSection(
              icon: Icons.access_time_filled,
              iconColor: const Color(0xFF9C27B0),
              title: '5. THỜI HẠN BẢO HÀNH',
              child: Column(
                children: [
                  _buildWarrantyRow(
                    icon: Icons.memory,
                    label: 'Bảo hành phần Cứng',
                    value: '3 / 6 / 12 Tháng',
                    note: '(tùy sản phẩm)',
                  ),
                  const SizedBox(height: 12),
                  _buildWarrantyRow(
                    icon: Icons.code,
                    label: 'Bảo hành phần Mềm',
                    value: '12 Tháng',
                    note: null,
                  ),
                  const SizedBox(height: 12),
                  _buildWarrantyRow(
                    icon: Icons.battery_charging_full,
                    label: 'Bảo hành Pin + Touch bar',
                    value: '1 Tháng',
                    note: null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────
  static Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // ── Highlight box ─────────────────────────────────────────
  static Widget _buildHighlightBox({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Check item ────────────────────────────────────────────
  static Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Numbered item ─────────────────────────────────────────
  static Widget _buildNumberedItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Exclude item ──────────────────────────────────────────
  static Widget _buildExcludeItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.close, size: 14, color: Color(0xFFE65100)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5D4037),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Warranty row ──────────────────────────────────────────
  static Widget _buildWarrantyRow({
    required IconData icon,
    required String label,
    required String value,
    String? note,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF1565C0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                if (note != null)
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
