import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/pg_controller.dart';
import '../../core/insta_loader.dart';
import '../../core/widgets.dart';

class ShellTab {
  const ShellTab(
    this.label,
    this.icon,
    this.page, {
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final Widget page;
}

class RoleShell extends StatefulWidget {
  const RoleShell({
    super.key,
    required this.title,
    required this.tabs,
  });

  final String title;
  final List<ShellTab> tabs;

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _index = 0;

  Future<void> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Log out?'),
        content: const Text(
          'You will need to verify with an OTP to sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (result == true) Get.find<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final pg = Get.find<PgController>();
    final name = auth.user.value?.name ?? widget.title;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.tabs[_index].label),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: pg.refreshAll,
          ),
          PopupMenuButton<String>(
            tooltip: 'Account',
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              if (value == 'logout') _confirmLogout();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout),
                  title: Text('Log out'),
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 4),
              child: InitialsAvatar(name, size: 38),
            ),
          ),
        ],
      ),
      body: Obx(
        () => pg.loading.value && pg.tenants.isEmpty && pg.beds.isEmpty
            ? const Center(child: InstaLoader(size: 36))
            : IndexedStack(
                index: _index,
                children: widget.tabs.map((tab) => tab.page).toList(),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
        },
        destinations: widget.tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(
                  tab.selectedIcon ?? tab.icon,
                  color: scheme.primary,
                ),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
