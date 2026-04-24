import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/admin/data/datasources/admin_datasource.dart';
import 'package:sgwatch_app/features/admin/data/models/admin_blog_model.dart';

class AdminBlogScreen extends StatefulWidget {
  const AdminBlogScreen({super.key});

  @override
  State<AdminBlogScreen> createState() => _AdminBlogScreenState();
}

class _AdminBlogScreenState extends State<AdminBlogScreen> {
  final _ds = AdminDatasource(ApiClient());
  List<AdminBlogPostModel> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _ds.getPosts();
      if (mounted) setState(() => _posts = posts);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openForm({AdminBlogPostModel? post}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _BlogFormSheet(
        post: post,
        datasource: _ds,
        onSaved: _loadPosts,
      ),
    );
  }

  Future<void> _confirmDelete(AdminBlogPostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bài viết'),
        content: Text('Bạn có chắc muốn xóa "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _ds.deletePost(post.id);
      await _loadPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa bài viết')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi xóa bài viết')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý Blog',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.white),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Chưa có bài viết nào.',
                        style: TextStyle(color: AppColors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm bài viết'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadPosts,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildPostCard(_posts[i]),
                  ),
                ),
    );
  }

  Widget _buildPostCard(AdminBlogPostModel post) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: post.mediaUrl!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 160,
                  color: AppColors.backgroundGrey,
                  child: const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.greyLight),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: AppColors.backgroundGrey,
                  child: const Center(
                    child: Icon(Icons.image, size: 40, color: AppColors.greyLight),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: post.isActive
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: post.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                      child: Text(
                        post.isActive ? 'Hiển thị' : 'Ẩn',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: post.isActive
                              ? Colors.green.shade700
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                if (post.description != null &&
                    post.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    post.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (post.link != null && post.link!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    post.link!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _openForm(post: post),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Sửa', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _confirmDelete(post),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Xóa', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blog Form Bottom Sheet ──────────────────────────────────────────────────

class _BlogFormSheet extends StatefulWidget {
  final AdminBlogPostModel? post;
  final AdminDatasource datasource;
  final VoidCallback onSaved;

  const _BlogFormSheet({
    this.post,
    required this.datasource,
    required this.onSaved,
  });

  @override
  State<_BlogFormSheet> createState() => _BlogFormSheetState();
}

class _BlogFormSheetState extends State<_BlogFormSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  bool _isActive = true;
  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.post;
    if (p != null) {
      _titleCtrl.text = p.title;
      _descCtrl.text = p.description ?? '';
      _linkCtrl.text = p.link ?? '';
      _isActive = p.isActive;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề')),
      );
      return;
    }
    if (widget.post == null && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final map = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'is_active': _isActive ? '1' : '0',
      };
      if (_descCtrl.text.isNotEmpty) map['description'] = _descCtrl.text.trim();
      if (_linkCtrl.text.isNotEmpty) map['link'] = _linkCtrl.text.trim();
      if (_imageFile != null) {
        map['media'] = await MultipartFile.fromFile(
          _imageFile!.path,
          filename: _imageFile!.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(map);
      if (widget.post != null) {
        await widget.datasource.updatePost(widget.post!.id, formData);
      } else {
        await widget.datasource.createPost(formData);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.post != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? 'Cập nhật bài viết' : 'Thêm bài viết mới',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.greyLight),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : widget.post?.mediaUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: widget.post!.mediaUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 160,
                                placeholder: (_, __) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.greyLight,
                                  ),
                                ),
                                errorWidget: (_, __, ___) => const Center(
                                  child: Icon(Icons.image,
                                      size: 40, color: AppColors.greyLight),
                                ),
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 40, color: AppColors.grey),
                                  SizedBox(height: 8),
                                  Text('Nhấn để chọn ảnh',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.grey)),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 14),
              // Title
              const Text('Tiêu đề *',
                  style: TextStyle(fontSize: 13, color: AppColors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nhập tiêu đề bài viết',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              // Description
              const Text('Mô tả',
                  style: TextStyle(fontSize: 13, color: AppColors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Nhập mô tả (tùy chọn)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              // Link
              const Text('Link',
                  style: TextStyle(fontSize: 13, color: AppColors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: _linkCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nhập link (tùy chọn)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              // is_active
              Row(
                children: [
                  const Text('Hiển thị',
                      style: TextStyle(fontSize: 13, color: AppColors.black)),
                  const Spacer(),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white),
                            )
                          : Text(isEdit ? 'Cập nhật' : 'Lưu'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
