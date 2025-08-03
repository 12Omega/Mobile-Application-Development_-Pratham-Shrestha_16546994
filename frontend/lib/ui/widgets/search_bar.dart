import 'package:flutter/material.dart';
import 'package:parkease/ui/shared/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onSearch;
  final VoidCallback? onFilterPressed;
  final bool showFilterButton;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
    this.onFilterPressed,
    this.showFilterButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.search,
              onSubmitted: onSearch,
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
              },
              color: Colors.grey[600],
            ),
          if (showFilterButton)
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: onFilterPressed,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
