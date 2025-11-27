import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/logic/auth_controller.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/health_record/data/repositories/health_record_repository.dart';
import 'features/health_record/logic/health_record_controller.dart';
import 'features/health_record/presentation/screens/dashboard_screen.dart';
import 'features/health_record/presentation/screens/record_form_screen.dart';
import 'features/health_record/presentation/screens/record_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthMateApp());
}

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(AuthRepository())),
        ChangeNotifierProxyProvider<AuthController, HealthRecordController>(
          create: (_) => HealthRecordController(HealthRecordRepository()),
          update: (_, authController, healthController) {
            healthController ??= HealthRecordController(
              HealthRecordRepository(),
            );
            healthController.syncUser(authController.currentUser);
            return healthController;
          },
        ),
      ],
      child: MaterialApp(
        title: 'HealthMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final _screens = const [DashboardScreen(), RecordListScreen()];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.currentUser == null) {
      return const AuthScreen();
    }

    final greeting = auth.currentUser!.fullName.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $greeting'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Records'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const RecordFormScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add record'),
      ),
    );
  }
}
