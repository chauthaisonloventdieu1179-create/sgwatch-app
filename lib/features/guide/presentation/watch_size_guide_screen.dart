import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';

class WatchSizeGuideScreen extends StatelessWidget {
  const WatchSizeGuideScreen({super.key});

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
          'Hướng dẫn chọn đồng hồ',
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
                  colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
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
                      Icons.watch,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'HƯỚNG DẪN CHỌN ĐỒNG HỒ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PHÙ HỢP CỔ TAY',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Xác định kích thước cổ tay
            _buildSection(
              icon: Icons.straighten,
              iconColor: const Color(0xFF2196F3),
              title: '1. XÁC ĐỊNH KÍCH THƯỚC CỔ TAY',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trước tiên, bạn cần biết cổ tay mình thuộc loại nào:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.black,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWristSizeCard(
                    label: 'Cổ tay nhỏ',
                    size: 'Dưới 15 cm',
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 8),
                  _buildWristSizeCard(
                    label: 'Cổ tay trung bình',
                    size: '15 – 17 cm',
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 8),
                  _buildWristSizeCard(
                    label: 'Cổ tay to',
                    size: 'Trên 17 cm',
                    color: const Color(0xFFFF9800),
                  ),
                  const SizedBox(height: 14),
                  _buildHighlightBox(
                    icon: Icons.tips_and_updates,
                    text:
                        'Cách đo đơn giản: dùng thước dây hoặc sợi dây quấn quanh cổ tay rồi đo lại.',
                    color: const Color(0xFF2196F3),
                  ),
                ],
              ),
            ),

            // Section 2: Chọn đường kính mặt đồng hồ
            _buildSection(
              icon: Icons.radio_button_checked,
              iconColor: const Color(0xFF9C27B0),
              title: '2. CHỌN ĐƯỜNG KÍNH MẶT ĐỒNG HỒ (CASE SIZE)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đây là yếu tố quan trọng nhất:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCaseSizeCard(
                    wrist: 'Cổ tay nhỏ (<15 cm)',
                    recommend: '34 – 38 mm',
                    note: 'Tránh đồng hồ quá to vì sẽ bị "nuốt tay"',
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 8),
                  _buildCaseSizeCard(
                    wrist: 'Cổ tay trung bình (15–17 cm)',
                    recommend: '38 – 42 mm',
                    note: 'Đây là size dễ đeo nhất',
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 8),
                  _buildCaseSizeCard(
                    wrist: 'Cổ tay to (>17 cm)',
                    recommend: '42 – 46 mm',
                    note: 'Tạo cảm giác mạnh mẽ, cân đối',
                    color: const Color(0xFFFF9800),
                  ),
                ],
              ),
            ),

            // Section 3: Chọn kiểu dáng theo cổ tay
            _buildSection(
              icon: Icons.style,
              iconColor: const Color(0xFFE91E63),
              title: '3. CHỌN KIỂU DÁNG THEO CỔ TAY',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStyleBlock(
                    title: 'Cổ tay nhỏ',
                    color: const Color(0xFF4CAF50),
                    items: [
                      'Ưu tiên: mặt tròn, đơn giản',
                      'Dây da hoặc kim loại nhỏ',
                      'Tránh đồng hồ thể thao quá hầm hố',
                    ],
                    isPositive: [true, true, false],
                  ),
                  const SizedBox(height: 12),
                  _buildStyleBlock(
                    title: 'Cổ tay trung bình',
                    color: const Color(0xFF2196F3),
                    items: [
                      'Hầu như đeo được mọi kiểu',
                      'Có thể thử cả dress watch và sport watch',
                    ],
                    isPositive: [true, true],
                  ),
                  const SizedBox(height: 12),
                  _buildStyleBlock(
                    title: 'Cổ tay to',
                    color: const Color(0xFFFF9800),
                    items: [
                      'Hợp đồng hồ Diver (lặn)',
                      'Chronograph (nhiều mặt số)',
                      'Dây kim loại hoặc cao su bản lớn sẽ đẹp hơn',
                    ],
                    isPositive: [true, true, true],
                  ),
                ],
              ),
            ),

            // Section 4: Màu sắc & phong cách
            _buildSection(
              icon: Icons.palette,
              iconColor: const Color(0xFFFF5722),
              title: '4. MÀU SẮC & PHONG CÁCH',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletItem(
                    'Da sáng / cổ tay nhỏ → nên chọn màu nhẹ: bạc, trắng, xanh',
                  ),
                  const SizedBox(height: 8),
                  _buildBulletItem(
                    'Da tối / cổ tay to → hợp màu mạnh: đen, vàng, xanh đậm',
                  ),
                ],
              ),
            ),

            // Section 5: Lỗi thường gặp
            _buildSection(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFFF9800),
              title: '5. MỘT SỐ LỖI THƯỜNG GẶP',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildErrorItem('Đeo đồng hồ quá to so với cổ tay'),
                  const SizedBox(height: 8),
                  _buildErrorItem('Dây lỏng hoặc quá chật'),
                  const SizedBox(height: 8),
                  _buildErrorItem('Lug (càng nối dây) dài vượt cổ tay'),
                  const SizedBox(height: 8),
                  _buildErrorItem('Chọn theo trend nhưng không hợp dáng tay'),
                ],
              ),
            ),

            // Section 6: Mẹo chọn nhanh
            _buildSection(
              icon: Icons.lightbulb_outline,
              iconColor: const Color(0xFFFFC107),
              title: '6. MẸO CHỌN NHANH',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightBox(
                    icon: Icons.visibility,
                    text: 'Nhìn tổng thể: đồng hồ không được "tràn" ra khỏi cổ tay. Khi nhìn từ trên xuống phải cân đối, gọn gàng.',
                    color: const Color(0xFFFFC107),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF3F8FF), Color(0xFFE3F2FD)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBBDEFB)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.watch, size: 36, color: Color(0xFF1976D2)),
                    SizedBox(height: 12),
                    Text(
                      'SGWATCH',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Mọi thắc mắc về kích thước hoặc chọn mẫu đồng hồ phù hợp, hãy liên hệ SGWATCH để được tư vấn miễn phí.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.black,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

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
                      fontSize: 15,
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

  static Widget _buildWristSizeCard({
    required String label,
    required String size,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            size,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCaseSizeCard({
    required String wrist,
    required String recommend,
    required String note,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wrist,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.arrow_forward, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                'Nên chọn: $recommend',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStyleBlock({
    required String title,
    required Color color,
    required List<String> items,
    required List<bool> isPositive,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(items.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i < items.length - 1 ? 6 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      isPositive[i] ? Icons.check_circle : Icons.cancel,
                      size: 14,
                      color: isPositive[i]
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static Widget _buildBulletItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: AppColors.grey),
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

  static Widget _buildErrorItem(String text) {
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
              fontSize: 13,
              color: AppColors.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

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
                fontWeight: FontWeight.w500,
                color: color,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
