import 'package:flutter/material.dart';
import 'package:parkease/ui/shared/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (isOutlined ? Colors.transparent : AppTheme.primaryColor);
    final txtColor =
        textColor ?? (isOutlined ? AppTheme.primaryColor : Colors.white);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(txtColor),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: txtColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 0,
              ),
              child: _buildButtonContent(txtColor),
            ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
