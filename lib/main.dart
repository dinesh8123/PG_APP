import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/pg_controller.dart';
import 'core/theme.dart';
import 'data/models.dart';
import 'data/pg_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/manager/manager_home.dart';
import 'features/owner/owner_home.dart';
import 'features/splash/splash_screen.dart';
import 'features/tenant/tenant_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Data is stored on the phone, so it is still there after the app is
  // closed and reopened. It is only removed on uninstall / clear storage.
  final repo = await PersistentPgRepository.open();
  Get.put<PgRepository>(repo);

  final pg = Get.put(PgController(repo));
  await pg.loadInitial();

  // Keep the user logged in until they tap "Log out".
  final auth = Get.put(AuthController());
  await auth.restore();

  runApp(const PgApp());
}

class PgApp extends StatefulWidget {
  const PgApp({super.key});

  @override
  State<PgApp> createState() => _PgAppState();
}

class _PgAppState extends State<PgApp> {
  bool _splashDone = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(splashDuration, () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _screenFor(Role? role) {
    switch (role) {
      case Role.tenant:
        return const TenantHome(key: ValueKey('tenant'));
      case Role.manager:
        return const ManagerHome(key: ValueKey('manager'));
      case Role.owner:
        return const OwnerHome(key: ValueKey('owner'));
      case null:
        return const LoginScreen(key: ValueKey('login'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'PG App',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      darkTheme: buildTheme(dark: true),
      // Follows the phone's own light / dark setting automatically.
      themeMode: ThemeMode.system,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        child: !_splashDone
            ? const SplashScreen(key: ValueKey('splash'))
            : Obx(
                () => AnimatedSwitcher(
                  key: const ValueKey('app'),
                  duration: const Duration(milliseconds: 400),
                  child: _screenFor(auth.user.value?.role),
                ),
              ),
      ),
    );
  }
}
