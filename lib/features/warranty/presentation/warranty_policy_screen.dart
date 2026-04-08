import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';

class WarrantyPolicyScreen extends StatelessWidget {
  const WarrantyPolicyScreen({super.key});

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
          'Chính sách bảo hành',
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
                  colors: [Color(0xFFDF3526), Color(0xFFB72A1E)],
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
                      Icons.verified_user,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CHÍNH SÁCH BẢO HÀNH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'TẠI SGWATCH',
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

            // Section 1: Thời gian bảo hành
            _buildSection(
              icon: Icons.access_time_filled,
              iconColor: const Color(0xFF2196F3),
              title: '1. THỜI GIAN BẢO HÀNH',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightBox(
                    icon: Icons.shield,
                    text: 'Bảo hành lên đến 06 năm',
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletItem(
                    '12 - 24 tháng đầu (tùy sản phẩm) tại hãng.',
                  ),
                  const SizedBox(height: 8),
                  _buildBulletItem(
                    'Sau hết thời gian bảo hành tại hãng, SGWATCH hỗ trợ bảo hành thêm 04 năm tại Nhật – Việt.',
                  ),
                ],
              ),
            ),

            // Section 2: Lưu ý và cách thức bảo hành
            _buildSection(
              icon: Icons.info_outline,
              iconColor: const Color(0xFFFF9800),
              title: '2. LƯU Ý VÀ CÁCH THỨC BẢO HÀNH',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lưu ý sub-header
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'LƯU Ý',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _buildCheckItem('Áp dụng thay pin miễn phí cho khách hàng.'),
                  const SizedBox(height: 8),
                  _buildCheckItem(
                    'Áp dụng đánh bóng làm mới, vệ sinh máy miễn phí lần đầu.',
                  ),
                  const SizedBox(height: 8),
                  _buildCheckItem(
                    'Quý khách cần có sổ, thẻ bảo hành hãng, hóa đơn điện tử khi mua trên app SGWATCH kể từ tháng 4/2026.',
                  ),
                  const SizedBox(height: 20),

                  // Cách thức bảo hành sub-header
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'CÁCH THỨC BẢO HÀNH',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _buildBulletItem(
                    'Tất cả đồng hồ sẽ được SGWATCH mang lên bảo hành trực tiếp tại hãng (Citizen, Seiko, Orient…), và chỉ bảo hành lỗi do nhà sản xuất.',
                  ),
                  const SizedBox(height: 8),
                  _buildBulletItem(
                    'Chỉ bảo hành miễn phí cho các hư hỏng về máy và linh kiện bên trong của đồng hồ được xác định là do lỗi của nhà sản xuất. Chỉ bảo hành thay thế mới cho những linh kiện bên trong của đồng hồ, không đổi bằng một chiếc đồng hồ khác.',
                  ),
                  const SizedBox(height: 16),

                  // Không bảo hành
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFFE0B2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 18, color: Color(0xFFFF9800)),
                            SizedBox(width: 6),
                            Text(
                              'Không bảo hành',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildExcludeItem(
                          'Phần bên ngoài của đồng hồ như: vỏ đồng hồ, mặt kính, dây đồng hồ, khóa đồng hồ, trừ trường hợp lỗi kỹ thuật do nhà sản xuất thông báo.',
                        ),
                        const SizedBox(height: 8),
                        _buildExcludeItem(
                          'Những hậu quả gián tiếp của việc sử dụng không đúng cách như: đeo đồng hồ khi xông hơi, tắm nước nóng, đồng hồ tiếp xúc với các loại nước hoa, mỹ phẩm hay các loại hóa chất, axit, chất tẩy rửa có độ ăn mòn cao…',
                        ),
                        const SizedBox(height: 8),
                        _buildExcludeItem(
                          'Những đồng hồ do khách hàng tự ý sửa chữa hoặc sửa chữa tại những nơi không phải là trung tâm bảo hành được hãng chỉ định.',
                        ),
                        const SizedBox(height: 8),
                        _buildExcludeItem(
                          'Đồng hồ bị hư hỏng do ảnh hưởng của thiên tai, hỏa hoạn, lũ lụt, tai nạn hoặc cố tình gây hư hỏng…',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildHighlightBox(
                    icon: Icons.swap_horiz,
                    text:
                        'Hỗ trợ đổi trả sản phẩm nếu phát hiện hàng lỗi do hãng sản xuất, không đúng thông tin tư vấn, ship nhầm mẫu.',
                    color: const Color(0xFF2196F3),
                  ),
                ],
              ),
            ),

            // Section 3: Thời gian xử lý bảo hành
            _buildSection(
              icon: Icons.schedule,
              iconColor: const Color(0xFF9C27B0),
              title: '3. THỜI GIAN XỬ LÝ BẢO HÀNH',
              child: Column(
                children: [
                  _buildTimeCard(
                    icon: Icons.business,
                    label: 'Tại hãng',
                    time: '15 ngày',
                    note: '(có thể nhanh hoặc chậm hơn tùy trường hợp)',
                  ),
                  const SizedBox(height: 12),
                  _buildTimeCard(
                    icon: Icons.store,
                    label: 'Tại SGWATCH',
                    time: '7 - 15 ngày',
                    note: '(có thể nhanh hoặc chậm hơn tùy trường hợp)',
                  ),
                ],
              ),
            ),

            // Section 4: Cam kết từ SGWATCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF8F7), Color(0xFFFFEDEB)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cam Kết Từ SGWATCH',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SGWATCH luôn là đơn vị tiên phong trong lĩnh vực đồng hồ tại Nhật Bản, là đơn vị đầu tiên và duy nhất có áp dụng bảo hành 2 đầu Nhật Việt cho khách hàng, thay pin miễn phí, lau giọn máy đánh bóng làm mới miễn phí.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.black,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'SGWATCH luôn cố gắng mang đến trải nghiệm mua hàng tốt nhất, lấy chất lượng và sự hài lòng của khách hàng đặt lên hàng đầu. Chúng tôi cam kết mang lại dịch vụ bảo hành nhanh chóng và tiện lợi nhất.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.black,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Trân trọng,',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'SGWATCH',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
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

  // ── Bullet item ───────────────────────────────────────────
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

  // ── Check item (positive) ─────────────────────────────────
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

  // ── Exclude item (negative) ───────────────────────────────
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

  // ── Time card ─────────────────────────────────────────────
  static Widget _buildTimeCard({
    required IconData icon,
    required String label,
    required String time,
    required String note,
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
            child: Icon(icon, size: 22, color: AppColors.primary),
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
                  time,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
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
