import 'package:flutter/material.dart';
import '../services/app_updater.dart';
import 'tabs/beranda_tab.dart';
import 'tabs/layanan_tab.dart';
import 'tabs/profil_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Allows tabs to switch to another tab (e.g. Beranda -> Layanan).
  void _goTo(int i) => setState(() => _index = i);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppUpdater.maybePrompt(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      BerandaTab(onOpenLayanan: () => _goTo(1)),
      const LayananTab(),
      const ProfilTab(),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: 'Layanan'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
