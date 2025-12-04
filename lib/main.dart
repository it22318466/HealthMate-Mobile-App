import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/logic/auth_controller.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/goals/data/repositories/goal_repository.dart';
import 'features/goals/data/datasources/goal_dao.dart';
import 'features/goals/logic/goal_controller.dart';
import 'features/goals/presentation/screens/goals_screen.dart';
import 'features/health_record/data/repositories/health_record_repository.dart';
import 'features/health_record/logic/health_record_controller.dart';
import 'features/health_record/presentation/screens/dashboard_screen.dart';
import 'features/health_record/presentation/screens/record_form_screen.dart';
import 'features/health_record/presentation/screens/record_list_screen.dart';
import 'features/insights/presentation/screens/insights_screen.dart';
import 'features/medication/data/repositories/medication_repository.dart';
import 'features/medication/data/datasources/medication_dao.dart';
import 'features/medication/logic/medication_controller.dart';
import 'features/medication/presentation/screens/medication_form_screen.dart';
import 'features/medication/presentation/screens/medication_list_screen.dart';

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
        ChangeNotifierProxyProvider<AuthController, GoalController>(
          create: (_) => GoalController(GoalRepository(GoalDao())),
          update: (_, authController, goalController) {
            goalController ??= GoalController(GoalRepository(GoalDao()));
            goalController.syncUser(authController.currentUser);
            return goalController;
          },
        ),
        ChangeNotifierProxyProvider<AuthController, MedicationController>(
          create: (_) => MedicationController(MedicationRepository(MedicationDao())),
          update: (_, authController, medicationController) {
            medicationController ??= MedicationController(
              MedicationRepository(MedicationDao()),
            );
            medicationController.syncUser(authController.currentUser);
            return medicationController;
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

  final _screens = const [
    DashboardScreen(),
    RecordListScreen(),
    GoalsScreen(),
    MedicationListScreen(),
    InsightsScreen(),
  ];

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
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              context.read<AuthController>().logout();
              messenger.showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
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
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            selectedIcon: Icon(Icons.list),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Medications',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RecordFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add record'),
            )
          : _currentIndex == 3
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MedicationFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add medication'),
                )
              : null,
    );
  }
}
