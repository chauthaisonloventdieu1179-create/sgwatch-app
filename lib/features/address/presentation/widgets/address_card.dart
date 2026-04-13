import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:sgwatch_app/features/address/data/models/address_model.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;

  const AddressCard({
    super.key,
    required this.address,
    this.onTap,
    this.onDelete,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final countryLabel = address.isJp ? 'Nhật Bản' : 'Việt Nam';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Location icon
            const Icon(
              Icons.location_on,
              size: 24,
              color: AppColors.black,
            ),
            const SizedBox(width: 12),
            // Label + country badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      countryLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Selected checkmark or delete button
            if (selected)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.check_circle,
                  size: 24,
                  color: AppColors.primary,
                ),
              )
            else
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.delete_outline,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
