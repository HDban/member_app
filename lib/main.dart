import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/export_screen.dart';

void main() {
  runApp(const MemberApp());
}

class MemberApp extends StatelessWidget {
  const MemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '会员管理',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RankingScreen(),
    const ExportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people),
            label: '会员',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: '排名',
          ),
          NavigationDestination(
            icon: Icon(Icons.download),
            label: '导出',
          ),
        ],
      ),
    );
  }
}
