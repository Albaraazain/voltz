import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? Colors.transparent : AppColors.accent,
      foregroundColor: isOutlined ? AppColors.accent : AppColors.surface,
      elevation: isOutlined ? 0 : 1,
      padding: padding,
      minimumSize: Size(width ?? double.infinity, height),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        side: isOutlined
            ? const BorderSide(color: AppColors.accent, width: 2)
            : BorderSide.none,
      ),
      textStyle: AppTextStyles.button,
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                strokeWidth: 2,
              ),
            )
          : DefaultTextStyle(
              style: AppTextStyles.button.copyWith(
                color: isOutlined ? AppColors.accent : AppColors.surface,
              ),
              child: child,
            ),
    );
  }
}
