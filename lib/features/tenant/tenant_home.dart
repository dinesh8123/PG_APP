import 'package:flutter/material.dart';

import '../shell/role_shell.dart';
import 'complaints_screen.dart';
import 'electricity_screen.dart';
import 'menu_screen.dart';
import 'rent_screen.dart';

class TenantHome extends StatelessWidget {
  const TenantHome({super.key});

  @override
  Widget build(BuildContext context) => const RoleShell(
        title: 'Tenant',
        tabs: [
          ShellTab(
            'Rent',
            Icons.payments_outlined,
            RentScreen(),
            selectedIcon: Icons.payments,
          ),
          ShellTab(
            'Bijli',
            Icons.bolt_outlined,
            ElectricityScreen(),
            selectedIcon: Icons.bolt,
          ),
          ShellTab(
            'Complaints',
            Icons.report_problem_outlined,
            ComplaintsScreen(),
            selectedIcon: Icons.report_problem,
          ),
          ShellTab(
            'Menu',
            Icons.restaurant_menu_outlined,
            MenuScreen(),
            selectedIcon: Icons.restaurant_menu,
          ),
        ],
      );
}
