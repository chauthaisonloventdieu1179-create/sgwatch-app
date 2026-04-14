import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';

class BuybackPolicyScreen extends StatelessWidget {
  const BuybackPolicyScreen({super.key});

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
          'Chính sách thu mua lại',
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
                  colors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
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
                      Icons.recycling,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CHÍNH SÁCH THU MUA LẠI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ĐỒNG HỒ TẠI SGWATCH',
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

            // Intro
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: const Text(
                  'Nhằm mang đến sự an tâm và gia tăng giá trị lâu dài cho khách hàng, SGWATCH triển khai chính sách thu mua lại đồng hồ dành cho các sản phẩm đã được mua tại cửa hàng.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.black,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            // Section 1: Đối tượng áp dụng
            _buildSection(
              icon: Icons.people_outline,
              iconColor: const Color(0xFF2196F3),
              title: '1. ĐỐI TƯỢNG ÁP DỤNG',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckItem('Khách hàng đã mua đồng hồ trực tiếp tại SGWATCH'),
                  const SizedBox(height: 8),
                  _buildCheckItem(
                    'Có thông tin mua hàng lưu trữ hoặc giấy tờ liên quan (hóa đơn, thẻ bảo hành, tin nhắn xác nhận…)',
                  ),
                ],
              ),
            ),

            // Section 2: Điều kiện thu mua
            _buildSection(
              icon: Icons.checklist_outlined,
              iconColor: const Color(0xFF4CAF50),
              title: '2. ĐIỀU KIỆN THU MUA',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SGWATCH nhận thu mua lại đồng hồ khi đáp ứng các điều kiện sau:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCheckItem('Là sản phẩm chính hãng do SGWATCH cung cấp'),
                  const SizedBox(height: 8),
                  _buildCheckItem('Đồng hồ còn hoạt động bình thường'),
                  const SizedBox(height: 8),
                  _buildCheckItem(
                    'Không bị hư hỏng nặng, vào nước, thay thế linh kiện không rõ nguồn gốc',
                  ),
                  const SizedBox(height: 14),
                  _buildHighlightBox(
                    icon: Icons.star_outline,
                    text: 'Ưu tiên đồng hồ còn đầy đủ: hộp, sổ/thẻ bảo hành, phụ kiện đi kèm.',
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),

            // Section 3: Nguyên tắc định giá
            _buildSection(
              icon: Icons.price_check,
              iconColor: const Color(0xFFFF9800),
              title: '3. NGUYÊN TẮC ĐỊNH GIÁ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Giá thu mua sẽ dựa trên các yếu tố:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletItem('Tình trạng thực tế của đồng hồ (ngoại hình, máy móc)'),
                  const SizedBox(height: 8),
                  _buildBulletItem('Thời gian sử dụng'),
                  const SizedBox(height: 8),
                  _buildBulletItem('Giá thị trường hiện tại'),
                  const SizedBox(height: 8),
                  _buildBulletItem('Độ hiếm và giá trị thương hiệu'),
                  const SizedBox(height: 14),
                  _buildHighlightBox(
                    icon: Icons.verified_outlined,
                    text: 'SGWATCH cam kết: định giá minh bạch, báo giá nhanh chóng.',
                    color: const Color(0xFFFF9800),
                  ),
                ],
              ),
            ),

            // Section 4: Quy trình thu mua
            _buildSection(
              icon: Icons.account_tree_outlined,
              iconColor: const Color(0xFF9C27B0),
              title: '4. QUY TRÌNH THU MUA',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepCard(
                    step: '1',
                    title: 'Khách hàng gửi thông tin sản phẩm',
                    detail:
                        'Hình ảnh đồng hồ (trước, sau, dây, khóa…), tình trạng hiện tại, thông tin mua tại SGWATCH.',
                    color: const Color(0xFF9C27B0),
                  ),
                  const SizedBox(height: 10),
                  _buildStepCard(
                    step: '2',
                    title: 'SGWATCH thẩm định & báo giá sơ bộ',
                    detail: '',
                    color: const Color(0xFF9C27B0),
                  ),
                  const SizedBox(height: 10),
                  _buildStepCard(
                    step: '3',
                    title: 'Kiểm tra trực tiếp sản phẩm (nếu cần)',
                    detail: '',
                    color: const Color(0xFF9C27B0),
                  ),
                  const SizedBox(height: 10),
                  _buildStepCard(
                    step: '4',
                    title: 'Chốt giá & thanh toán',
                    detail: '',
                    color: const Color(0xFF9C27B0),
                  ),
                ],
              ),
            ),

            // Section 5: Hình thức thanh toán
            _buildSection(
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFF00BCD4),
              title: '5. HÌNH THỨC THANH TOÁN',
              child: _buildHighlightBox(
                icon: Icons.account_balance_wallet_outlined,
                text: 'Thanh toán tiền mặt hoặc chuyển khoản.',
                color: const Color(0xFF00BCD4),
              ),
            ),

            // Section 6: Quyền lợi khách hàng
            _buildSection(
              icon: Icons.card_giftcard,
              iconColor: const Color(0xFFE91E63),
              title: '6. QUYỀN LỢI KHÁCH HÀNG',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckItem(
                    'Được ưu tiên thu mua với giá tốt hơn thị trường',
                  ),
                  const SizedBox(height: 8),
                  _buildCheckItem('Hỗ trợ tư vấn nâng cấp đồng hồ phù hợp'),
                  const SizedBox(height: 8),
                  _buildCheckItem('Quy trình nhanh gọn – bảo mật thông tin'),
                ],
              ),
            ),

            // Section 7: Lưu ý
            _buildSection(
              icon: Icons.info_outline,
              iconColor: const Color(0xFFFF5722),
              title: '7. LƯU Ý',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                          'SGWATCH có quyền từ chối thu mua nếu sản phẩm không đạt yêu cầu',
                        ),
                        const SizedBox(height: 8),
                        _buildExcludeItem(
                          'Giá thu mua có thể thay đổi theo thời điểm thị trường',
                        ),
                        const SizedBox(height: 8),
                        _buildExcludeItem(
                          'Chính sách chỉ áp dụng cho sản phẩm đã mua tại SGWATCH',
                        ),
                      ],
                    ),
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
                    colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.handshake_outlined,
                        size: 24,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SGWATCH – ĐỒNG HÀNH GIÁ TRỊ THEO THỜI GIAN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF388E3C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Chúng tôi không chỉ bán đồng hồ, mà còn đồng hành cùng khách hàng trong suốt vòng đời sản phẩm.',
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

  static Widget _buildExcludeItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFFF9800)),
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

  static Widget _buildStepCard({
    required String step,
    required String title,
    required String detail,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              if (detail.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
