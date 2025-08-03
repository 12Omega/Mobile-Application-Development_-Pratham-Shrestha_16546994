import 'package:flutter/material.dart';

class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String screenName;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    required this.screenName,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  late DateTime _startTime;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // Mark as loaded after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
        
        final loadTime = DateTime.now().difference(_startTime).inMilliseconds;
        debugPrint('${widget.screenName} loaded in ${loadTime}ms');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // Show loading indicator if not loaded yet
        if (!_isLoaded)
          Container(
            color: Colors.white.withValues(alpha: 0.8),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Optimizing performance...'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}