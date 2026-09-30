import 'package:flutter/material.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/providers/patient_profile_provider.dart';
import 'package:hospital_connect/screens/appointments/appointments_screen.dart';
import 'package:hospital_connect/screens/billing/billing_screen.dart';
import 'package:hospital_connect/screens/dashboard/dashboard_screen.dart';
import 'package:hospital_connect/screens/doctors/doctors_screen.dart';
import 'package:hospital_connect/screens/onboarding/onboarding_modal.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstRunOnboarding();
    });
  }

  void _checkFirstRunOnboarding() {
    final profile = Provider.of<PatientProfileProvider?>(context, listen: false);
    if (profile != null && !profile.hasSeenOnboarding && mounted) {
      OnboardingModal.show(context);
    }
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
    final isWideScreen = MediaQuery.of(context).size.width >= 720;

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: selectTab,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Icon(
                  Icons.local_hospital_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Home'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.medical_services_outlined),
                  selectedIcon: Icon(Icons.medical_services_rounded),
                  label: Text('Doctors'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Appointments'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.folder_shared_outlined),
                  selectedIcon: Icon(Icons.folder_shared_rounded),
                  label: Text('Records'),
                ),
                NavigationRailDestination(
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
                  label: const Text('Bills'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

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
