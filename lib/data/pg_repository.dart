import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils.dart';
import 'models.dart';

abstract class PgRepository {
  Future<List<Room>> rooms();
  Future<List<Bed>> beds();
  Future<List<Tenant>> tenants();
  Future<List<RentRecord>> rents();
  Future<List<MeterReading>> readings();
  Future<List<Complaint>> complaints();
  Future<List<MenuDay>> menu();

  Future<void> markRentPaid(String rentId);
  Future<void> saveReading(MeterReading reading);
  Future<void> addComplaint(Complaint complaint);
  Future<void> updateComplaint(String id, ComplaintStatus status);
  Future<void> addTenant(Tenant tenant);
  Future<void> updateTenant(Tenant tenant);
  Future<void> deleteTenant(String tenantId);
  Future<void> deleteReading(String roomId, String month);
  Future<void> editComplaint(
    String id,
    String title,
    String description,
  );
  Future<void> deleteComplaint(String id);
  Future<void> setRentPaid(String rentId, bool paid);
  Future<void> updateRentAmount(String rentId, double amount);
  Future<void> deleteRent(String rentId);
  Future<void> createRentFor(String tenantId);
}

class InMemoryPgRepository implements PgRepository {
  InMemoryPgRepository() {
    for (final number in ['101', '102', '103', '104']) {
      _rooms.add(Room(id: 'r$number', number: number));

      for (final label in ['A', 'B', 'C']) {
        _beds.add(
          Bed(
            id: 'b$number$label',
            roomId: 'r$number',
            label: label,
          ),
        );
      }
    }
  }

  final _rooms = <Room>[];
  final _beds = <Bed>[];
  final _tenants = <Tenant>[];
  final _rents = <RentRecord>[];
  final _readings = <MeterReading>[];
  final _complaints = <Complaint>[];

  static const _menu = [
    MenuDay(
      'Monday',
      'Poha, Tea',
      'Dal, Rice, Roti, Sabzi',
      'Paneer, Roti, Rice',
    ),
    MenuDay(
      'Tuesday',
      'Idli, Sambar',
      'Rajma, Rice, Roti',
      'Egg Curry / Chole, Roti',
    ),
    MenuDay(
      'Wednesday',
      'Aloo Paratha, Curd',
      'Dal Fry, Rice, Roti',
      'Mix Veg, Roti, Rice',
    ),
    MenuDay(
      'Thursday',
      'Upma, Tea',
      'Kadhi, Rice, Roti',
      'Dal Tadka, Roti, Rice',
    ),
    MenuDay(
      'Friday',
      'Bread Omelette / Jam',
      'Chole, Rice, Roti',
      'Veg Biryani, Raita',
    ),
    MenuDay(
      'Saturday',
      'Puri, Sabzi',
      'Dal, Rice, Roti, Sabzi',
      'Chicken / Paneer, Roti',
    ),
    MenuDay(
      'Sunday',
      'Dosa, Chutney',
      'Special Thali',
      'Fried Rice, Manchurian',
    ),
  ];

  Future<T> _wait<T>(T value) => Future.delayed(
        const Duration(milliseconds: 150),
        () => value,
      );

  @override
  Future<List<Room>> rooms() => _wait(List.of(_rooms));

  @override
  Future<List<Bed>> beds() => _wait(List.of(_beds));

  @override
  Future<List<Tenant>> tenants() => _wait(List.of(_tenants));

  @override
  Future<List<RentRecord>> rents() => _wait(List.of(_rents));

  @override
  Future<List<MeterReading>> readings() => _wait(List.of(_readings));

  @override
  Future<List<Complaint>> complaints() => _wait(List.of(_complaints));

  @override
  Future<List<MenuDay>> menu() => _wait(List.of(_menu));

  @override
  Future<void> markRentPaid(String rentId) async {
    _rents.firstWhere((r) => r.id == rentId).paidOn = DateTime.now();
  }

  @override
  Future<void> saveReading(MeterReading reading) async {
    _readings.removeWhere(
      (r) => r.roomId == reading.roomId && r.month == reading.month,
    );
    _readings.add(reading);
  }

  @override
  Future<void> addComplaint(Complaint complaint) async {
    _complaints.insert(0, complaint);
  }

  @override
  Future<void> updateComplaint(
    String id,
    ComplaintStatus status,
  ) async {
    _complaints.firstWhere((c) => c.id == id).status = status;
  }

  @override
  Future<void> addTenant(Tenant tenant) async {
    _tenants.add(tenant);
    _beds.firstWhere((b) => b.id == tenant.bedId).tenantId = tenant.id;
    await createRentFor(tenant.id);
  }

  @override
  Future<void> updateTenant(Tenant tenant) async {
    final index = _tenants.indexWhere((t) => t.id == tenant.id);
    if (index < 0) return;

    final old = _tenants[index];

    if (old.bedId != tenant.bedId) {
      _beds.firstWhere((b) => b.id == old.bedId).tenantId = null;
      _beds.firstWhere((b) => b.id == tenant.bedId).tenantId = tenant.id;
    }

    _tenants[index] = tenant;

    final key = monthKey(DateTime.now());
    for (final rent in _rents) {
      if (rent.tenantId == tenant.id && rent.month == key && !rent.paid) {
        rent.amount = tenant.monthlyRent;
      }
    }
  }

  @override
  Future<void> deleteTenant(String tenantId) async {
    final tenant = _tenants.firstWhere((t) => t.id == tenantId);
    _beds.firstWhere((b) => b.id == tenant.bedId).tenantId = null;

    _tenants.removeWhere((t) => t.id == tenantId);
    _rents.removeWhere((r) => r.tenantId == tenantId);
    _complaints.removeWhere((c) => c.tenantId == tenantId);
  }

  @override
  Future<void> deleteReading(String roomId, String month) async {
    _readings.removeWhere(
      (r) => r.roomId == roomId && r.month == month,
    );
  }

  @override
  Future<void> editComplaint(
    String id,
    String title,
    String description,
  ) async {
    final complaint = _complaints.firstWhere((c) => c.id == id);
    complaint.title = title;
    complaint.description = description;
  }

  @override
  Future<void> deleteComplaint(String id) async {
    _complaints.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> setRentPaid(String rentId, bool paid) async {
    _rents.firstWhere((r) => r.id == rentId).paidOn =
        paid ? DateTime.now() : null;
  }

  @override
  Future<void> updateRentAmount(String rentId, double amount) async {
    _rents.firstWhere((r) => r.id == rentId).amount = amount;
  }

  @override
  Future<void> deleteRent(String rentId) async {
    _rents.removeWhere((r) => r.id == rentId);
  }

  @override
  Future<void> createRentFor(String tenantId) async {
    final tenant = _tenants.firstWhere((t) => t.id == tenantId);
    final now = DateTime.now();
    final key = monthKey(now);

    if (_rents.any(
      (r) => r.tenantId == tenantId && r.month == key,
    )) {
      return;
    }

    _rents.add(
      RentRecord(
        id: 'rent_${tenantId}_$key',
        tenantId: tenantId,
        month: key,
        amount: tenant.monthlyRent,
        dueDate: DateTime(now.year, now.month, 5),
      ),
    );
  }
}

/// Same behaviour as [InMemoryPgRepository], but every change is written to
/// the phone's local storage, so data survives closing the app, swiping it
/// away, or restarting the phone. It is removed only when the app is
/// uninstalled or its storage is cleared in phone settings.
class PersistentPgRepository extends InMemoryPgRepository {
  PersistentPgRepository._(this._prefs);

  static const storageKey = 'pg_app_data_v1';

  final SharedPreferences _prefs;

  static Future<PersistentPgRepository> open() async {
    final repo = PersistentPgRepository._(
      await SharedPreferences.getInstance(),
    );
    repo._load();
    return repo;
  }

  void _load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;

      List<T> read<T>(
        String key,
        T Function(Map<String, dynamic>) fromJson,
      ) =>
          ((data[key] as List?) ?? const [])
              .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();

      final rooms = read('rooms', Room.fromJson);
      final beds = read('beds', Bed.fromJson);

      // Keep the default rooms/beds if nothing valid was stored.
      if (rooms.isNotEmpty && beds.isNotEmpty) {
        _rooms
          ..clear()
          ..addAll(rooms);
        _beds
          ..clear()
          ..addAll(beds);
      }

      _tenants
        ..clear()
        ..addAll(read('tenants', Tenant.fromJson));
      _rents
        ..clear()
        ..addAll(read('rents', RentRecord.fromJson));
      _readings
        ..clear()
        ..addAll(read('readings', MeterReading.fromJson));
      _complaints
        ..clear()
        ..addAll(read('complaints', Complaint.fromJson));
    } catch (_) {
      // Corrupt data: start fresh rather than crash on launch.
    }
  }

  Future<void> _save() => _prefs.setString(
        storageKey,
        jsonEncode({
          'rooms': _rooms.map((e) => e.toJson()).toList(),
          'beds': _beds.map((e) => e.toJson()).toList(),
          'tenants': _tenants.map((e) => e.toJson()).toList(),
          'rents': _rents.map((e) => e.toJson()).toList(),
          'readings': _readings.map((e) => e.toJson()).toList(),
          'complaints': _complaints.map((e) => e.toJson()).toList(),
        }),
      );

  @override
  Future<void> markRentPaid(String rentId) async {
    await super.markRentPaid(rentId);
    await _save();
  }

  @override
  Future<void> saveReading(MeterReading reading) async {
    await super.saveReading(reading);
    await _save();
  }

  @override
  Future<void> addComplaint(Complaint complaint) async {
    await super.addComplaint(complaint);
    await _save();
  }

  @override
  Future<void> updateComplaint(String id, ComplaintStatus status) async {
    await super.updateComplaint(id, status);
    await _save();
  }

  @override
  Future<void> addTenant(Tenant tenant) async {
    await super.addTenant(tenant);
    await _save();
  }

  @override
  Future<void> updateTenant(Tenant tenant) async {
    await super.updateTenant(tenant);
    await _save();
  }

  @override
  Future<void> deleteTenant(String tenantId) async {
    await super.deleteTenant(tenantId);
    await _save();
  }

  @override
  Future<void> deleteReading(String roomId, String month) async {
    await super.deleteReading(roomId, month);
    await _save();
  }

  @override
  Future<void> editComplaint(
    String id,
    String title,
    String description,
  ) async {
    await super.editComplaint(id, title, description);
    await _save();
  }

  @override
  Future<void> deleteComplaint(String id) async {
    await super.deleteComplaint(id);
    await _save();
  }

  @override
  Future<void> setRentPaid(String rentId, bool paid) async {
    await super.setRentPaid(rentId, paid);
    await _save();
  }

  @override
  Future<void> updateRentAmount(String rentId, double amount) async {
    await super.updateRentAmount(rentId, amount);
    await _save();
  }

  @override
  Future<void> deleteRent(String rentId) async {
    await super.deleteRent(rentId);
    await _save();
  }

  @override
  Future<void> createRentFor(String tenantId) async {
    await super.createRentFor(tenantId);
    await _save();
  }
}
