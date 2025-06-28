import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/presentation/shared/widgets/appbar.dart';

class HomeShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({
    super.key,
    required this.navigationShell,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  late PageController _pageController;
  bool _isPageViewScrolling = false;

  static const int _numberOfTabs = 4;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.navigationShell.currentIndex);
  }

  @override
  void didUpdateWidget(HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _syncPageController();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncPageController() {
    if (!_isPageViewScrolling && _pageController.hasClients) {
      _pageController.animateToPage(
        widget.navigationShell.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTabTapped(int index) {
    if (_isPageViewScrolling) return;

    final isCurrentTab = widget.navigationShell.currentIndex == index;

    widget.navigationShell.goBranch(
      index,
      initialLocation: isCurrentTab,
    );

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    if (widget.navigationShell.currentIndex == index) return;

    _isPageViewScrolling = true;

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        widget.navigationShell.goBranch(index);
        _isPageViewScrolling = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YaffuuAppBar(
        leftChildren: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              context.push('/output-files');
            },
            tooltip: 'Output Files',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _numberOfTabs,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Offstage(
                offstage: widget.navigationShell.currentIndex != index,
                child: _buildPageWrapper(widget.navigationShell),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageWrapper(Widget child) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

extension HomeShellNavigation on BuildContext {
  void navigateToShellTab(int index) {
    final shellState = findAncestorStateOfType<_HomeShellState>();
    shellState?._onTabTapped(index);
  }
}
