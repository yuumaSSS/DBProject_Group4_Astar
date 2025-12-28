import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav.dart';

class MainWrapper extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const MainWrapper({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  @override
  void initState() {
    super.initState();
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF0F111A) : Colors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          reverseDuration: Duration.zero,
          switchInCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(widget.navigationShell.currentIndex),
            child: widget.children[widget.navigationShell.currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomNav(
                  label: "Orders",
                  imgPath: "assets/images/icons/orders.png",
                  activeImgPath: "assets/images/icons/orders_c.png",
                  isSelected: widget.navigationShell.currentIndex == 0,
                  onTap: () {
                    _goBranch(0);
                  },
                ),
                BottomNav(
                  label: "Manage",
                  imgPath: "assets/images/icons/manage.png",
                  activeImgPath: "assets/images/icons/manage_c.png",
                  isSelected: widget.navigationShell.currentIndex == 1,
                  onTap: () {
                    _goBranch(1);
                  },
                ),
                BottomNav(
                  label: "About",
                  imgPath: "assets/images/icons/about.png",
                  activeImgPath: "assets/images/icons/about_c.png",
                  isSelected: widget.navigationShell.currentIndex == 2,
                  onTap: () {
                    _goBranch(2);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
