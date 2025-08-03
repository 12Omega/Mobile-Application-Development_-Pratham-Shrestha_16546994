import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  // Build path with parameters
  String _buildPath(String routeName, Map<String, String>? params) {
    if (params == null || params.isEmpty) {
      return routeName;
    }

    String path = routeName;
    params.forEach((key, value) {
      path = path.replaceAll(':$key', value);
    });

    return path;
  }

  // Navigate to a named route
  void navigateTo(BuildContext context, String routeName,
      {Map<String, String>? params, Map<String, String>? queryParams}) {
    final path = _buildPath(routeName, params);
    context.go(path, extra: queryParams);
  }

  // Push a named route
  void pushTo(BuildContext context, String routeName,
      {Map<String, String>? params, Map<String, String>? queryParams}) {
    final path = _buildPath(routeName, params);
    context.push(path, extra: queryParams);
  }

  // Replace current route with a named route
  void replaceTo(BuildContext context, String routeName,
      {Map<String, String>? params, Map<String, String>? queryParams}) {
    final path = _buildPath(routeName, params);
    context.replace(path, extra: queryParams);
  }

  // Go back
  void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
