import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}