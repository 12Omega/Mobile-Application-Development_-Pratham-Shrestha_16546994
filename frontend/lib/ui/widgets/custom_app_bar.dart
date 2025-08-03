import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parkease/ui/shared/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color:
              foregroundColor ?? Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      centerTitle: true,
      elevation: elevation,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: foregroundColor,
      leading: showBackButton
          ? leading ??
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: onBackPressed ?? () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // Fallback navigation - go to home if can't pop
                    context.go('/home');
                  }
                },
                color: foregroundColor ?? AppTheme.primaryColor,
              )
          : leading,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null
      ? kToolbarHeight + bottom!.preferredSize.height
      : kToolbarHeight);
}
