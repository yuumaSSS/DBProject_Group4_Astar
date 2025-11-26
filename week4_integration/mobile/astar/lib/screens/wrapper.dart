import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav.dart';

class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true, 
        bottom: false,
        child: navigationShell,
      ),
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        
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
                  label: "Stock",
                  imgPath: "assets/images/icons/stock.png",
                  activeImgPath: "assets/images/icons/stock_c.png",
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _goBranch(0),
                ),
                
                BottomNav(
                  label: "Manage",
                  imgPath: "assets/images/icons/manage.png",
                  activeImgPath: "assets/images/icons/manage_c.png",
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _goBranch(1),
                ),

                BottomNav(
                  label: "About",
                  imgPath: "assets/images/icons/about.png",
                  activeImgPath: "assets/images/icons/about_c.png",
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _goBranch(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}