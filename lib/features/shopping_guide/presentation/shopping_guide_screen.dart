import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';

class ShoppingGuideScreen extends StatelessWidget {
  const ShoppingGuideScreen({super.key});

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
          'Hướng dẫn mua hàng',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          'Nội dung đang được cập nhật...',
          style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.6),
        ),
      ),
    );
  }
}
