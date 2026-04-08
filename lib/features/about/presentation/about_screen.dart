import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'Về chúng tôi',
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
            // ── GIỚI THIỆU DOANH NGHIỆP ──
            _buildSection(
              children: [
                _buildSectionTitle('GIỚI THIỆU DOANH NGHIỆP'),
                const SizedBox(height: 12),
                const Text(
                  'Được sáng lập bởi CEO Trần Toàn, SGWATCH là đơn vị tiên phong mang đồng hồ chính hãng nội địa Nhật đến gần hơn với khách hàng. Anh là người Việt đầu tiên trong lĩnh vực đồng hồ tại Nhật, công ty chuyên đồng hồ đầu tiên của người Việt tại Nhật Bản.',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'SGWATCH xuất phát điểm là đơn vị chuyên phân phối hệ thống sỉ, các điểm bán lẻ (giai đoạn năm 2017-2021).\n\n2021 ảnh hưởng đại dịch COVID, cũng là năm đánh dấu cột mốc phát triển mới của SGWATCH bắt đầu phát triển hệ thống các kênh truyền thông bán lẻ, công ty dần được biết nhiều thông qua các kênh truyền thông này.',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Năm 2026, hiện SGWATCH đang có trụ sở, chi nhánh tại 2 đầu Nhật Việt (Osaka, Hồ Chí Minh)',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 16),
                // 2 hình chi nhánh Nhật - Việt
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/image_cuahangnhat.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Chi nhánh Osaka, Nhật Bản',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.grey, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/image_cuahangvietnam2.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Chi nhánh Hồ Chí Minh, Việt Nam',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),

            // ── Ý NGHĨA THƯƠNG HIỆU ──
            _buildSection(
              children: [
                _buildSectionTitle('Ý NGHĨA THƯƠNG HIỆU "SGWATCH"'),
                const SizedBox(height: 12),
                _buildBulletItem('SG – Sài Gòn: Xuất phát điểm, nơi sinh sôi, tạo nguồn cảm hứng của CEO Trần Toàn trong lĩnh vực đồng hồ Nhật Bản.'),
                const Padding(
                  padding: EdgeInsets.only(left: 24, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngoài ra, "SG" còn có ý nghĩa:',
                        style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                      ),
                      SizedBox(height: 4),
                      Text('  • S – Style (Phong cách)', style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6)),
                      Text('  • G – Genuine (Chính hãng / chân thật)', style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6)),
                    ],
                  ),
                ),
                _buildBulletItem('Watch – Đồng hồ'),
                const SizedBox(height: 8),
                const Text(
                  'Ý nghĩa định hướng: mang đến những chiếc đồng hồ phong cách và chính hãng rõ nguồn gốc xuất xứ. Và quan trọng hơn là dù làm việc ở đâu, SGWATCH luôn hướng về nguồn cội. Đó là thông điệp của thương hiệu.',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
              ],
            ),

            // ── HÀNH TRÌNH HÌNH THÀNH VÀ PHÁT TRIỂN ──
            _buildSection(
              children: [
                _buildSectionTitle('HÀNH TRÌNH HÌNH THÀNH VÀ PHÁT TRIỂN'),
                const SizedBox(height: 12),
                const Text(
                  'Ngay từ những ngày chưa đặt chân đến Nhật Bản, CEO Trần Toàn đã có nền tảng từ gia đình trong lĩnh vực đồng hồ, đến Nhật Bản với mục tiêu, sự học hỏi, SGWATCH đã từng bước và tiên phong trong lĩnh vực đồng hồ nội địa Nhật chính hãng giá rẻ. SGWATCH phát triển theo tiêu chí "Chất lượng – Uy tín – Tận tâm", đặt lợi ích khách hàng làm trung tâm cho mọi hoạt động.',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Trải qua quá trình xây dựng và phát triển, SGWATCH đã từng bước mở rộng quy mô, đa dạng hóa sản phẩm và nâng cao chất lượng dịch vụ, trở thành điểm đến tin cậy của đông đảo khách hàng yêu thích đồng hồ.',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 16),
                // Hình ảnh khách đông
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/hinhanhkhachdong1.jpg', width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/hinhanhkhachdong3.jpg', width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/hinhanhkhachdong4.jpg', width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/hinhanhkhachdong5.jpg', width: double.infinity, fit: BoxFit.cover),
                ),
              ],
            ),

            // ── SẢN PHẨM VÀ DỊCH VỤ ──
            _buildSection(
              children: [
                _buildSectionTitle('Sản phẩm và dịch vụ'),
                const SizedBox(height: 12),
                const Text(
                  'SGWATCH cam kết sản phẩm:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletItem('Nguồn gốc rõ ràng, giá cả minh bạch'),
                _buildBulletItem('Chất lượng chính hãng'),
                _buildBulletItem('Lựa chọn các mẫu đồng hồ phù hợp với thị hiếu'),
                const SizedBox(height: 12),
                const Text(
                  'SGWATCH còn có các dịch vụ:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletItem('Bảo hành – bảo dưỡng 05 năm 2 đầu Nhật Việt'),
                _buildBulletItem('Spa vệ sinh miễn phí lần đầu, thay pin miễn phí trọn đời'),
                _buildBulletItem('Hỗ trợ khách hàng thu mua lên đời sản phẩm'),
              ],
            ),

            // ── TẦM NHÌN PHÁT TRIỂN ──
            _buildSection(
              children: [
                _buildSectionTitle('Tầm nhìn phát triển'),
                const SizedBox(height: 12),
                const Text(
                  'Với định hướng phát triển bền vững, SGWATCH đặt mục tiêu trở thành thương hiệu kinh doanh đồng hồ uy tín, được khách hàng tin tưởng và lựa chọn. Trong thời gian tới, SGWATCH sẽ tiếp tục:',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 8),
                _buildBulletItem('Mở rộng và đa dạng hóa các dòng sản phẩm đồng hồ'),
                _buildBulletItem('Phát triển mạnh các kênh bán hàng online và livestream'),
                _buildBulletItem('Nâng cao chất lượng dịch vụ, chăm sóc khách hàng, xây dựng đội ngũ nhân viên chuyên nghiệp từ tư vấn đến bảo hành'),
                const SizedBox(height: 12),
                const Text(
                  'SGWATCH mong muốn mang thương hiệu đến gần hơn với nhiều khách hàng và xây dựng một cộng đồng những người yêu thích đồng hồ.',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
              ],
            ),

            // ── GIÁ TRỊ CỐT LÕI ──
            _buildSection(
              children: [
                _buildSectionTitle('Giá trị cốt lõi'),
                const SizedBox(height: 12),
                _buildCoreValue(Icons.verified, 'Uy tín', 'Luôn đặt chữ tín lên hàng đầu'),
                _buildCoreValue(Icons.workspace_premium, 'Chất lượng', 'Cam kết sản phẩm chính hãng, rõ nguồn gốc xuất xứ'),
                _buildCoreValue(Icons.people, 'Khách hàng là trung tâm', 'Lắng nghe và thấu hiểu nhu cầu'),
                _buildCoreValue(Icons.trending_up, 'Phát triển bền vững', 'Không ngừng đổi mới và hoàn thiện'),
              ],
            ),

            // ── LỜI CẢM ƠN ──
            _buildSection(
              children: [
                const Text(
                  'SGWATCH xin chân thành cảm ơn Quý khách hàng đã tin tưởng và ủng hộ chúng tôi.',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sự đồng hành của Quý khách là động lực để SGWATCH không ngừng phát triển và mang đến những sản phẩm, dịch vụ tốt hơn mỗi ngày.',
                  style: TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Trân trọng!',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary, height: 1.6),
                ),
              ],
            ),

            // ── THÔNG TIN CÔNG TY ──
            _buildSection(
              children: [
                _buildSectionTitle('Thông tin công ty'),
                const SizedBox(height: 12),
                _buildInfoRow('Tên công ty', 'SGG合同会社'),
                _buildInfoRow('Trụ sở chính', '〒542-0072 大阪市中央区高津2-8-6 Bunraku Daiei Building 3F'),
                _buildInfoRow('Ngày thành lập', '21/09/2021'),
                _buildInfoRow('Giám đốc điều hành', 'Trần Toàn'),
                _buildInfoRow('Số lượng nhân viên', '15 người'),
                _buildInfoRow('Nội dung kinh doanh', 'Điện tử, Viễn thông'),
                _buildInfoRowTappable('Số điện thoại', '090-3978-1993', () => launchUrl(Uri.parse('tel:09039781993'))),
                _buildInfoRow('Fax', '06-6806-4663'),
                _buildInfoRowTappable('Email', 'Sggtrantoan@gmail.com', () => launchUrl(Uri.parse('mailto:Sggtrantoan@gmail.com'))),
                _buildInfoRow('Thời gian làm việc', '11h00 – 22h00'),
                const Divider(height: 24),
                const Text(
                  'Giấy phép kinh doanh đồ cũ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Mã số', '第3120003020278号'),
                _buildInfoRow('Được cấp bởi', 'Công an thành phố Osaka'),
                _buildInfoRow('Ngày cấp', '29/09/2021'),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  static Widget _buildSection({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  static Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.check_circle, size: 16, color: Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.black, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCoreValue(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: AppColors.grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.black, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoRowTappable(String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
