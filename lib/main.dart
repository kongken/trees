import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/forest_provider.dart';
import 'theme/app_theme.dart';
import 'screens/forest_page.dart';
import 'screens/today_page.dart';
import 'screens/stats_page.dart';
import 'screens/profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForestProvider()..initialize(),
      child: MaterialApp(
        title: 'Life Forest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ForestPage(),
    TodayPage(),
    StatsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ForestProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.leafGreen),
                  SizedBox(height: 16),
                  Text(
                    '正在加载你的森林...',
                    style: TextStyle(
                      color: AppTheme.forestGreen,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.park_outlined),
                activeIcon: Icon(Icons.park),
                label: '森林',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wb_sunny_outlined),
                activeIcon: Icon(Icons.wb_sunny),
                label: '今日',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: '统计',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '我',
              ),
            ],
          ),
        );
      },
    );
  }
}
