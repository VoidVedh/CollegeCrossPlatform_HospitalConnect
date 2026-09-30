import 'package:flutter/material.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/screens/appointments/appointments_screen.dart';
import 'package:hospital_connect/screens/billing/billing_screen.dart';
import 'package:hospital_connect/screens/dashboard/dashboard_screen.dart';
import 'package:hospital_connect/screens/doctors/doctors_screen.dart';
import 'package:hospital_connect/screens/records/records_screen.dart';
import 'package:provider/provider.dart';

/// App navigation shell featuring a 5-tab Material 3 NavigationBar.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  /// Programmatically switch the active tab in the nearest [AppShell].
  static bool selectTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    if (state != null) {
      state.selectTab(index);
      return true;
    }
    return false;
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  late final List<Widget> _screens = <Widget>[
    DashboardScreen(onSelectTab: selectTab),
    const DoctorsScreen(),
    const AppointmentsScreen(),
    const RecordsScreen(),
    const BillingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void selectTab(int index) {
    if (_currentIndex != index && mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unpaidCount = context.select<BillProvider, int>(
      (p) => p.unpaidBillsCount,
    );

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: selectTab,
        destinations: <NavigationDestination>[
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services_rounded),
            label: 'Doctors',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Appointments',
          ),
          const NavigationDestination(
            icon: Icon(Icons.folder_shared_outlined),
            selectedIcon: Icon(Icons.folder_shared_rounded),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unpaidCount > 0,
              label: Text('$unpaidCount'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: unpaidCount > 0,
              label: Text('$unpaidCount'),
              child: const Icon(Icons.receipt_long_rounded),
            ),
            label: 'Bills',
          ),
        ],
      ),
    );
  }
}
