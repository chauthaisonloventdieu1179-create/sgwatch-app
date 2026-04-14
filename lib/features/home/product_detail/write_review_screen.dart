import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgwatch_app/app/config/env.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/home/data/models/review_model.dart';
import 'package:sgwatch_app/features/home/product_detail/product_detail_viewmodel.dart';

class WriteReviewScreen extends StatefulWidget {
  final int productId;
  final String productName;
  final ProductDetailViewModel viewModel;
  final ReviewModel? existingReview; // null = create, non-null = edit

  const WriteReviewScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.viewModel,
    this.existingReview,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _picker = ImagePicker();

  int _rating = 5;
  List<String> _existingImages = []; // URLs of old images to keep
  List<File> _newImages = []; // New images picked from gallery/camera
  bool _isSubmitting = false;
  bool _imagesTouched = false; // true khi user xóa/thêm ảnh cũ

  bool get _isEditing => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final r = widget.existingReview!;
      _rating = r.rating;
      _titleController.text = r.title ?? '';
      _contentController.text = r.comment ?? '';
      _existingImages = List.from(r.imageUrls);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Sửa đánh giá' : 'Viết đánh giá',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.primary),
                  onPressed: _onDelete,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Star rating
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Đánh giá của bạn',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            i < _rating ? Icons.star : Icons.star_border,
                            size: 40,
                            color: Colors.amber,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _ratingLabel(_rating),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề đánh giá *',
                  hintStyle:
                      TextStyle(fontSize: 14, color: AppColors.greyPlaceholder),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.black),
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm... *',
                  hintStyle:
                      TextStyle(fontSize: 14, color: AppColors.greyPlaceholder),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                    fontSize: 14, color: AppColors.black, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            // Images
            _buildImageSection(),
            const SizedBox(height: 30),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: AppColors.greyLight,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Cập nhật đánh giá' : 'Gửi đánh giá',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hình ảnh (tùy chọn)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // Existing images (from server)
              ..._existingImages.asMap().entries.map((entry) {
                final url = _buildImageUrl(entry.value);
                return _buildImageTile(
                  child: Image.network(url, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                    return const Icon(Icons.broken_image,
                        color: AppColors.grey);
                  }),
                  onRemove: () {
                    setState(() {
                      _existingImages.removeAt(entry.key);
                      _imagesTouched = true;
                    });
                  },
                );
              }),
              // New images (local files)
              ..._newImages.asMap().entries.map((entry) {
                return _buildImageTile(
                  child: Image.file(entry.value, fit: BoxFit.cover),
                  onRemove: () {
                    setState(() => _newImages.removeAt(entry.key));
                  },
                );
              }),
              // Add button
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyLight, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 28, color: AppColors.grey),
                      SizedBox(height: 4),
                      Text(
                        'Thêm ảnh',
                        style: TextStyle(fontSize: 10, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(width: 80, height: 80, child: child),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickMultiImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _newImages.add(File(picked.path));
        _imagesTouched = true;
      });
    }
  }

  Future<void> _pickMultiImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _newImages.addAll(picked.map((x) => File(x.path)));
        _imagesTouched = true;
      });
    }
  }

  Future<void> _onSubmit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề đánh giá.')),
      );
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    bool success;
    if (_isEditing) {
      success = await widget.viewModel.updateReview(
        reviewId: widget.existingReview!.id,
        rating: _rating,
        title: title,
        content: content,
        // null = Case 5 (không đụng ảnh), [] = Case 3 (xóa hết), [...] = Case 1/2/4
        existingImages: _imagesTouched ? _existingImages : null,
        newImagePaths:
            _newImages.isEmpty ? null : _newImages.map((f) => f.path).toList(),
      );
    } else {
      success = await widget.viewModel.createReview(
        rating: _rating,
        title: title,
        content: content,
        imagePaths:
            _newImages.isEmpty ? null : _newImages.map((f) => f.path).toList(),
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEditing ? 'Đã cập nhật đánh giá' : 'Đã gửi đánh giá'),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể gửi đánh giá. Thử lại sau.')),
      );
    }
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn có chắc muốn xóa đánh giá này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isSubmitting = true);
    final success =
        await widget.viewModel.deleteReview(widget.existingReview!.id);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa đánh giá')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xóa đánh giá. Thử lại sau.')),
      );
    }
  }

  String _buildImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${Env.baseURL}/storage/$path';
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Tệ';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Tuyệt vời';
      default:
        return '';
    }
  }
}
