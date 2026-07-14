import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

class Mainshell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const Mainshell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            activeIcon: HeroIcon(
              HeroIcons.home,
              style: HeroIconStyle.solid,
            ),
            icon: HeroIcon(HeroIcons.home, style: HeroIconStyle.outline),
            label: "Home",
          ),
          BottomNavigationBarItem(
             activeIcon: HeroIcon(
              HeroIcons.cube,
              style: HeroIconStyle.solid,
            ),
            icon: HeroIcon(HeroIcons.cube, style: HeroIconStyle.outline),
            label: "delivery",
          ),
          BottomNavigationBarItem(
            activeIcon: HeroIcon(
              HeroIcons.userCircle,
              style: HeroIconStyle.solid,
            ),
            icon: HeroIcon(HeroIcons.userCircle, style: HeroIconStyle.outline),
            label: "profile",
          ),
        ],
      ),
    );
  }
}
