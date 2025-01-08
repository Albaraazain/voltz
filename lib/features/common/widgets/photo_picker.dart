import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class PhotoPicker extends StatelessWidget {
  final List<String> selectedPhotos;
  final Function(List<String>) onPhotosSelected;

  const PhotoPicker({
    super.key,
    required this.selectedPhotos,
    required this.onPhotosSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Add Photo Button
          GestureDetector(
            onTap: () {
              // TODO: Implement photo picking
            },
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.accent,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Photo',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Selected Photos
          ...selectedPhotos.map((photo) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      image: DecorationImage(
                        image: NetworkImage(photo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        final newPhotos = List<String>.from(selectedPhotos)
                          ..remove(photo);
                        onPhotosSelected(newPhotos);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}