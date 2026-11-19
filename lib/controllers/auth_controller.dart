import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import 'pg_controller.dart';

class AppUser {
  AppUser(
    this.role,
    this.name, {
    this.tenantId,
    this.phone = '',
  });

  final Role role;
  final String name;
  final String? tenantId;
  final String phone;

  bool get isStaff => role == Role.manager || role == Role.owner;
}

class AuthController extends GetxController {
  static const testPhone = '123456789';
  static const testOtp = '1234';

  static const _sessionKey = 'pg_app_session_v1';

  final user = Rxn<AppUser>();

  /// Restores the saved login so the user stays signed in after the app
  /// is closed. Call once at startup, after [PgController] has loaded.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_sessionKey);
    if (raw == null || raw.length < 4) return;

    final role = Role.values.firstWhereOrNull((r) => r.name == raw[0]);
    if (role == null) return;

    final tenantId = raw[3].isEmpty ? null : raw[3];

    // A tenant removed by the manager should not stay logged in.
    if (role == Role.tenant &&
        Get.find<PgController>().tenantById(tenantId ?? '') == null) {
      await prefs.remove(_sessionKey);
      return;
    }

    user.value = AppUser(
      role,
      raw[1],
      phone: raw[2],
      tenantId: tenantId,
    );
  }

  Future<void> _saveSession(AppUser? u) async {
    final prefs = await SharedPreferences.getInstance();
    if (u == null) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setStringList(
        _sessionKey,
        [u.role.name, u.name, u.phone, u.tenantId ?? ''],
      );
    }
  }

  String? checkNumber(Role role, String phone) {
    if (phone.isEmpty) return 'Enter your mobile number';

    final isTest = phone == testPhone;

    switch (role) {
      case Role.tenant:
        final tenants = Get.find<PgController>().tenants;

        if (isTest) {
          return tenants.isEmpty
              ? 'No tenants yet. Login as Manager and add one first'
              : null;
        }

        if (phone.length != 10) {
          return 'Enter a valid 10-digit number';
        }

        return tenants.any((t) => t.phone == phone)
            ? null
            : 'No tenant found with this number';

      case Role.manager:
      case Role.owner:
        return isTest ? null : 'This number is not registered (use $testPhone)';
    }
  }

  String? login(Role role, String phone, String otp) {
    final err = checkNumber(role, phone);
    if (err != null) return err;

    if (otp != testOtp) {
      return 'Incorrect OTP. Please try again';
    }

    switch (role) {
      case Role.tenant:
        final tenants = Get.find<PgController>().tenants;
        final tenant = phone == testPhone
            ? tenants.first
            : tenants.firstWhere((t) => t.phone == phone);

        user.value = AppUser(
          Role.tenant,
          tenant.name,
          tenantId: tenant.id,
          phone: tenant.phone,
        );
        _saveSession(user.value);
        return null;

      case Role.manager:
        user.value = AppUser(
          Role.manager,
          'Manager',
          phone: phone,
        );
        _saveSession(user.value);
        return null;

      case Role.owner:
        user.value = AppUser(
          Role.owner,
          'Owner',
          phone: phone,
        );
        _saveSession(user.value);
        return null;
    }
  }

  void logout() {
    user.value = null;
    _saveSession(null);
  }
}
