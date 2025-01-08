import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

enum ButtonType { primary, secondary }

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final ButtonType type;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.type = ButtonType.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: type == ButtonType.primary
                ? AppColors.accent
                : Colors.transparent,
            border: type == ButtonType.secondary
                ? Border.all(color: AppColors.accent)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        type == ButtonType.primary
                            ? AppColors.surface
                            : AppColors.accent,
                      ),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: type == ButtonType.primary
                          ? AppColors.surface
                          : AppColors.accent,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
