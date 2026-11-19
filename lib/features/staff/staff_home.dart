import 'package:flutter/material.dart';

import '../manager/complaint_list_screen.dart';
import '../manager/meter_reading_screen.dart';
import '../owner/finance_screen.dart';
import '../owner/vacant_beds_screen.dart';
import '../shell/role_shell.dart';
import 'tenants_screen.dart';

class StaffHome extends StatelessWidget {
  const StaffHome({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => RoleShell(
        title: title,
        tabs: const [
          ShellTab(
            'Dashboard',
            Icons.dashboard_outlined,
            FinanceScreen(),
            selectedIcon: Icons.dashboard,
          ),
          ShellTab(
            'Beds',
            Icons.bed_outlined,
            VacantBedsScreen(),
            selectedIcon: Icons.bed,
          ),
          ShellTab(
            'Tenants',
            Icons.people_outline,
            TenantsScreen(),
            selectedIcon: Icons.people,
          ),
          ShellTab(
            'Meter',
            Icons.bolt_outlined,
            MeterReadingScreen(),
            selectedIcon: Icons.bolt,
          ),
          ShellTab(
            'Complaints',
            Icons.report_problem_outlined,
            ComplaintListScreen(),
            selectedIcon: Icons.report_problem,
          ),
        ],
      );
}
