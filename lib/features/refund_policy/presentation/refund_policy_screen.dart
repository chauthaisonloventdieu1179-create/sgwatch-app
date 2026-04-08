import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: const Color(0x0D000000),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chính sách hoàn tiền',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 01
            _buildSectionHeader('01'),
            const SizedBox(height: 8),
            const Text(
              'SGWATCH có chế độ đổi trả hàng đối với các trường hợp sau đây:',
              style: TextStyle(
                  fontSize: 14, color: AppColors.black, height: 1.6),
            ),
            const SizedBox(height: 12),
            _buildBullet(
                '1. Hàng hoá bị hư hỏng trong quá trình vận chuyển.'),
            _buildBullet(
                '2. Hình ảnh, chất lượng sản phẩm không đúng với nội dung được ghi trên App.'),
            _buildBullet(
                '3. Các nguyên nhân khác được xác định do từ phía nhà cung cấp.'),
            const SizedBox(height: 12),
            const Text(
              'Thời gian tiếp nhận đổi trả hàng được áp dụng trong vòng 03 ngày sau khi nhận hàng. Nếu có nguyện vọng đổi trả hàng, xin vui lòng nhanh chóng liên hệ SGWATCH để được hỗ trợ kịp thời.',
              style: TextStyle(
                  fontSize: 14, color: AppColors.grey, height: 1.6),
            ),
            const SizedBox(height: 24),

            // Section 02
            _buildSectionHeader('02'),
            const SizedBox(height: 8),
            const Text(
              'Quy định về việc hoàn tiền:',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  height: 1.6),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thời gian hoàn tiền trong vòng 3 - 5 ngày làm việc kể từ khi tiếp nhận xử lý.\n\n'
              'Chỉ làm việc với khách trực tiếp mua hàng trên App, có mã đơn hàng.\n\n'
              'Hàng gửi lại Shop phải nguyên vẹn đầy đủ như ban đầu, chưa có dấu hiệu đã tháo mắt, qua sử dụng.',
              style: TextStyle(
                  fontSize: 14, color: AppColors.grey, height: 1.6),
            ),
            const SizedBox(height: 24),

            // Section 03
            _buildSectionHeader('03'),
            const SizedBox(height: 8),
            const Text(
              'Thông tin tiếp nhận khiếu nại',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  height: 1.6),
            ),
            const SizedBox(height: 12),
            _buildContactRow(Icons.phone, 'Hotline', '090-3978-1993', () {
              launchUrl(Uri.parse('tel:09039781993'));
            }),
            const SizedBox(height: 10),
            _buildContactRow(Icons.chat, 'Chat trực tiếp', 'CSKH trên App SGWATCH', null),
            const SizedBox(height: 10),
            _buildContactRow(Icons.email, 'Email', 'sggtrantoan@gmail.com', () {
              launchUrl(Uri.parse('mailto:sggtrantoan@gmail.com'));
            }),
            const SizedBox(height: 10),
            _buildContactRow(Icons.facebook, 'Fanpage Facebook', 'Bấm vào đây', () {
              launchUrl(Uri.parse('https://www.facebook.com/SGWatch.vn'),
                  mode: LaunchMode.externalApplication);
            }),
            const SizedBox(height: 10),
            _buildContactRow(Icons.message, 'Zalo', 'Bấm vào đây', () {
              launchUrl(Uri.parse('https://zalo.me/0903978199'),
                  mode: LaunchMode.externalApplication);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String number) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Text(
        text,
        style:
            const TextStyle(fontSize: 14, color: AppColors.grey, height: 1.6),
      ),
    );
  }

  Widget _buildContactRow(
      IconData icon, String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.black,
                fontWeight: FontWeight.w600),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: onTap != null ? AppColors.primary : AppColors.grey,
                decoration:
                    onTap != null ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
