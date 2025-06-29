import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A [SingleChildScrollView] that adds extra padding when scrollable or scrolled, with optional size transition.
class SingleChildScrollViewWithPadding extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;
  /// The axis along which the scroll view scrolls.
  final Axis scrollDirection;
  /// Whether the scroll view scrolls in the reading direction.
  final bool reverse;
  /// The amount of space by which to inset the child.
  final EdgeInsetsGeometry? padding;
  /// Extra padding to add when scrollable or scrolled.
  final EdgeInsetsGeometry scrollPadding;
  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;
  /// An object that can be used to control the position to which this scroll view is scrolled.
  final ScrollController? controller;
  /// Determines the way that drag start behavior is handled.
  final DragStartBehavior dragStartBehavior;
  /// The content will be clipped (or not) according to this option.
  final Clip clipBehavior;
  /// Restoration ID to save and restore scroll offset.
  final String? restorationId;
  /// Defines how this scroll view dismisses the keyboard.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  /// Duration for the size transition animation.
  final Duration? sizeTransitionDuration;
  /// Curve for the size transition animation.
  final Curve sizeTransitionCurve;

  const SingleChildScrollViewWithPadding({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.scrollPadding = const EdgeInsets.fromLTRB(0, 0, 16, 0),
    this.physics,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.sizeTransitionDuration,
    this.sizeTransitionCurve = Curves.easeInOut,
  });

  @override
  State<SingleChildScrollViewWithPadding> createState() =>
      _SingleChildScrollViewWithPaddingState();
}

class _SingleChildScrollViewWithPaddingState
    extends State<SingleChildScrollViewWithPadding> {
  late ScrollController _scrollController;
  bool _isScrollable = false;
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollable();
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    final hasScrolled = _scrollController.offset > 0;
    if (hasScrolled != _hasScrolled) {
      setState(() {
        _hasScrolled = hasScrolled;
      });
    }
  }

  void _checkScrollable() {
    if (_scrollController.hasClients) {
      final isScrollable = _scrollController.position.maxScrollExtent > 0;
      if (isScrollable != _isScrollable) {
        setState(() {
          _isScrollable = isScrollable;
        });
      }
    }
  }

  bool _onScrollMetricsChanged(ScrollMetricsNotification notification) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollable();
    });
    return false;
  }

  EdgeInsetsGeometry get _effectivePadding {
    final basePadding = widget.padding ?? EdgeInsets.zero;

    if (!_isScrollable) {
      return basePadding;
    }

    if (_hasScrolled || _isScrollable) {
      return basePadding.add(widget.scrollPadding);
    }

    return basePadding;
  }

  @override
  Widget build(BuildContext context) {
    final basePadding = widget.padding ?? EdgeInsets.zero;
    
    Widget child = widget.child;
    
    if (widget.sizeTransitionDuration != null) {
      child = AnimatedContainer(
        duration: widget.sizeTransitionDuration!,
        curve: widget.sizeTransitionCurve,
        padding: _effectivePadding.subtract(basePadding),
        child: widget.child,
      );
    }

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _onScrollMetricsChanged,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        padding: widget.sizeTransitionDuration != null ? basePadding : _effectivePadding,
        physics: widget.physics,
        dragStartBehavior: widget.dragStartBehavior,
        clipBehavior: widget.clipBehavior,
        restorationId: widget.restorationId,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        child: child,
      ),
    );
  }
}