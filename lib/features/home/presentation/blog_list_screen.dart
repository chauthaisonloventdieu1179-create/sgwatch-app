import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/network/api_client.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/home/data/datasources/product_remote_datasource.dart';
import 'package:sgwatch_app/features/home/data/models/post_model.dart';
import 'package:sgwatch_app/features/home/presentation/banner_webview_screen.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final _datasource = ProductRemoteDatasource(ApiClient());

  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final posts = await _datasource.getPosts();
      if (mounted) setState(() => _posts = posts);
    } catch (e) {
      if (mounted) setState(() => _error = 'Không thể tải bài viết.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openPost(PostModel post) {
    final link = post.link;
    if (link != null && link.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BannerWebViewScreen(url: link),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.arrow_back_ios, size: 20, color: AppColors.black),
            ),
          ),
          const Expanded(
            child: Text(
              'Blog',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPosts,
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

    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có bài viết nào.',
          style: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadPosts,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _buildPostCard(_posts[index]),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return GestureDetector(
      onTap: () => _openPost(post),
      child: Container(
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
            if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: post.mediaUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 180,
                    color: AppColors.backgroundGrey,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.greyLight,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.backgroundGrey,
                    child: const Center(
                      child: Icon(Icons.image, size: 48, color: AppColors.greyLight),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  if (post.description != null && post.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      post.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (post.link != null && post.link!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Đọc thêm',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.primary),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
