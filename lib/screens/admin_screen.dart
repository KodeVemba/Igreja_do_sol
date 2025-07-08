import 'package:flutter/material.dart';
import 'package:church/models/admin_assigment_manager.dart';
import 'package:church/models/admin_create_celebration.dart';
import 'package:church/models/admin_manager_reader.dart';
import 'package:church/models/admin_monitor_stats.dart';

class MyAdminPage extends StatefulWidget {
  const MyAdminPage({super.key});

  @override
  State<MyAdminPage> createState() => _MyAdminPageState();
}

class _MyAdminPageState extends State<MyAdminPage> {
  int selectedTabIndex = 0;

  final List<Widget> _tabs = [
    CreateCelebrationTab(),
    ManageAssignmentsTab(),
    ManageReadersTab(),
    MonitorStatsTab(),
  ];

  final List<String> _tabTitles = [
    'Create Celebration',
    'Manage Assignments',
    'Manage Readers',
    'Monitor Stats',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[selectedTabIndex]),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _tabs[selectedTabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Celebration'),
          NavigationDestination(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          NavigationDestination(icon: Icon(Icons.people), label: 'Readers'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
