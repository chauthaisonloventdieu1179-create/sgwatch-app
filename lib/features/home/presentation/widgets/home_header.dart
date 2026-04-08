import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';

class HomeHeader extends StatefulWidget {
  final int cartItemCount;
  final ValueChanged<String>? onSearchSubmit;
  final VoidCallback? onCartTap;
  final VoidCallback? onMenuTap;

  const HomeHeader({
    super.key,
    this.cartItemCount = 0,
    this.onSearchSubmit,
    this.onCartTap,
    this.onMenuTap,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final query = _controller.text.trim();
    widget.onSearchSubmit?.call(query);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onMenuTap,
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.menu, color: AppColors.black, size: 26),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.greyPlaceholder, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm sản phẩm',
                        hintStyle: TextStyle(
                          color: AppColors.greyPlaceholder,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: widget.onCartTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 26,
                      color: AppColors.black,
                    ),
                  ),
                  if (widget.cartItemCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${widget.cartItemCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
