import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pg_app/controllers/auth_controller.dart';
import 'package:pg_app/controllers/pg_controller.dart';
import 'package:pg_app/core/theme.dart';
import 'package:pg_app/core/widgets.dart';
import 'package:pg_app/data/models.dart';
import 'package:pg_app/data/pg_repository.dart';
import 'package:pg_app/main.dart';

void main() {
  tearDown(() => Get.reset());

  testWidgets(
    'app follows the phone theme and has no theme/replay buttons',
    (tester) async {
      SharedPreferences.setMockInitialValues({});

      Get.put(PgController(InMemoryPgRepository()));
      Get.put(AuthController());

      tester.platformDispatcher.platformBrightnessTestValue =
          Brightness.dark;

      await tester.pumpWidget(const PgApp());
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      var context = tester.element(find.text('Welcome to your Haven'));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(find.byTooltip('Switch to light mode'), findsNothing);
      expect(find.text('Replay Splash'), findsNothing);

      tester.platformDispatcher.platformBrightnessTestValue =
          Brightness.light;
      await tester.pumpAndSettle();

      context = tester.element(find.text('Welcome to your Haven'));
      expect(Theme.of(context).brightness, Brightness.light);
      expect(tester.takeException(), isNull);

      tester.platformDispatcher.clearPlatformBrightnessTestValue();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test('data and login survive an app restart', () async {
    SharedPreferences.setMockInitialValues({});

    final repo = await PersistentPgRepository.open();
    await repo.addTenant(
      Tenant(
        id: 't1',
        name: 'Asha',
        phone: '9876543210',
        roomId: 'r101',
        bedId: 'b101A',
        monthlyRent: 6000,
        deposit: 12000,
      ),
    );

    Get.put(PgController(repo));
    await Get.find<PgController>().loadInitial();
    final auth = Get.put(AuthController());
    expect(auth.login(Role.tenant, '9876543210', '1234'), isNull);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Simulate closing the app and opening it again.
    Get.reset();

    final reopened = await PersistentPgRepository.open();
    expect((await reopened.tenants()).single.name, 'Asha');
    expect((await reopened.rents()).length, 1);
    expect((await reopened.beds()).firstWhere((b) => b.id == 'b101A').vacant,
        false);

    final pg = Get.put(PgController(reopened));
    await pg.loadInitial();
    final auth2 = Get.put(AuthController());
    await auth2.restore();
    expect(auth2.user.value?.name, 'Asha');
    expect(auth2.user.value?.role, Role.tenant);

    auth2.logout();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final auth3 = AuthController();
    await auth3.restore();
    expect(auth3.user.value, isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'shared card uses theme surface: dark=$dark',
      (tester) async {
        final theme = buildTheme(dark: dark);

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: AppCard(child: Text('Card content')),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(AppCard),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(
          (container.decoration! as BoxDecoration).color,
          theme.colorScheme.surface,
        );
      },
    );
  }
}
