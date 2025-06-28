import 'package:flutter/material.dart';

/// A wrapper widget that prevents Windows system alert sounds when clicking on empty areas.
/// 
/// This widget solves a specific issue where GoRouter's StatefulShellRoute.indexedStack
/// creates non-dismissible ModalBarriers that play Windows system alert sounds when
/// users click on transparent/empty areas around page content.
/// 
/// **Usage:**
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return AntiAlertSoundGestureOnEmptyAreas(
///     child: Column(
///       children: [
///         // Your page content here
///       ],
///     ),
///   );
/// }
/// ```
/// 
/// **How it works:**
/// - Uses a GestureDetector with HitTestBehavior.opaque to capture all tap events
/// - Provides an empty onTap callback that "consumes" the click event
/// - Prevents clicks from propagating to underlying ModalBarriers
/// - Does NOT interfere with interactive widgets inside (buttons, text fields, etc.)
/// 
/// **When to use:**
/// - Any page that uses GoRouter without a Scaffold wrapper
/// - Pages where users might click on empty areas around content
/// - When you experience Windows system alert sounds on click
/// 
/// **Visual indicator:**
/// - In debug mode, shows a very subtle red tint to indicate the widget is active
/// - In release mode, completely transparent
class AntiAlertSoundGestureOnEmptyAreas extends StatelessWidget {
  /// The child widget to wrap and protect from alert sounds
  final Widget child;
  
  /// Whether to show a visual debug indicator (only in debug mode)
  final bool showDebugIndicator;

  const AntiAlertSoundGestureOnEmptyAreas({
    super.key,
    required this.child,
    this.showDebugIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // CRITICAL: opaque behavior ensures ALL clicks are captured,
      // including clicks on transparent areas
      behavior: HitTestBehavior.opaque,
      
      // Empty callback that "consumes" the click event,
      // preventing it from reaching underlying ModalBarriers
      onTap: () {},
      
      child: Container(
        // Visual debug indicator (only in debug mode if enabled)
        color: _getDebugColor(),
        child: child,
      ),
    );
  }
  
  Color? _getDebugColor() {
    // Only show debug color in debug mode and if explicitly enabled
    bool inDebugMode = false;
    assert(() {
      inDebugMode = true;
      return true;
    }());
    
    if (inDebugMode && showDebugIndicator) {
      return Colors.red.withOpacity(0.05); // Very subtle red tint
    }
    
    return null; // Completely transparent in release mode
  }
}