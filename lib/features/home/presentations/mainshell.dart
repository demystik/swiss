import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Mainshell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const Mainshell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: navigationShell, bottomNavigationBar: BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index){
        navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
      },
      items: const[
        BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: "Home"),
        BottomNavigationBarItem(icon: Icon(LucideIcons.bike), label: "delivery"),
        BottomNavigationBarItem(icon: Icon(LucideIcons.personStanding), label: "profile"),
      ]),);
  }
}