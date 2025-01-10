import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isOutlined;
  final bool isFullWidth;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            side: BorderSide(
              color: onPressed == null
                  ? AppColors.border
                  : (backgroundColor ?? AppColors.primary),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize:
                Size(isFullWidth ? double.infinity : (width ?? 0), height),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: textColor ?? AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize:
                Size(isFullWidth ? double.infinity : (width ?? 0), height),
          );

    final buttonChild = Text(
      text,
      style: AppTextStyles.buttonMedium.copyWith(
        color: isOutlined
            ? (textColor ?? AppColors.primary)
            : (textColor ?? AppColors.onPrimary),
      ),
    );

    return isOutlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: buttonChild,
          );
  }
}
