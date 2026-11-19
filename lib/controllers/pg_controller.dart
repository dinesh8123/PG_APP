import 'package:get/get.dart';

import '../core/utils.dart';
import '../data/models.dart';
import '../data/pg_repository.dart';

class ElectricityBill {
  ElectricityBill(this.reading, this.occupants, this.rate);

  final MeterReading reading;
  final int occupants;
  final double rate;

  double get total => reading.units * rate;

  double get share => occupants == 0 ? 0 : total / occupants;
}

class PgController extends GetxController {
  PgController(this._repo);

  final PgRepository _repo;

  static const double unitRate = 8;

  final rooms = <Room>[].obs;
  final beds = <Bed>[].obs;
  final tenants = <Tenant>[].obs;
  final rents = <RentRecord>[].obs;
  final readings = <MeterReading>[].obs;
  final complaints = <Complaint>[].obs;
  final menu = <MenuDay>[].obs;
  final loading = true.obs;

  String get month => monthKey(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  /// Loads everything once; used at startup so saved data is ready
  /// before the first screen is drawn.
  Future<void> loadInitial() => refreshAll();

  Future<void> refreshAll() async {
    loading.value = true;
    rooms.assignAll(await _repo.rooms());
    beds.assignAll(await _repo.beds());
    tenants.assignAll(await _repo.tenants());
    rents.assignAll(await _repo.rents());
    readings.assignAll(await _repo.readings());
    complaints.assignAll(await _repo.complaints());
    menu.assignAll(await _repo.menu());
    loading.value = false;
  }

  Tenant? tenantById(String id) => tenants.firstWhereOrNull((t) => t.id == id);

  Room? roomById(String id) => rooms.firstWhereOrNull((r) => r.id == id);

  int occupantsIn(String roomId) =>
      tenants.where((t) => t.roomId == roomId).length;

  List<Bed> get vacantBeds => beds.where((b) => b.vacant).toList();

  MeterReading? readingFor(String roomId, String month) =>
      readings.firstWhereOrNull(
        (r) => r.roomId == roomId && r.month == month,
      );

  int lastClosing(String roomId) {
    final list = readings.where((r) => r.roomId == roomId).toList()
      ..sort((a, b) => b.month.compareTo(a.month));

    final previous = list.firstWhereOrNull((r) => r.month != month);
    return previous?.current ?? 0;
  }

  ElectricityBill? billFor(Tenant tenant, String month) {
    final reading = readingFor(tenant.roomId, month);
    if (reading == null) return null;

    return ElectricityBill(
      reading,
      occupantsIn(tenant.roomId),
      unitRate,
    );
  }

  Future<void> payRent(String rentId) async {
    await _repo.markRentPaid(rentId);
    await refreshAll();
  }

  Future<void> saveReading(MeterReading reading) async {
    await _repo.saveReading(reading);
    await refreshAll();
  }

  Future<void> raiseComplaint(
    String tenantId,
    String title,
    String description,
  ) async {
    await _repo.addComplaint(
      Complaint(
        id: 'c${DateTime.now().millisecondsSinceEpoch}',
        tenantId: tenantId,
        title: title,
        description: description,
        createdAt: DateTime.now(),
      ),
    );
    await refreshAll();
  }

  Future<void> setComplaintStatus(
    String id,
    ComplaintStatus status,
  ) async {
    await _repo.updateComplaint(id, status);
    await refreshAll();
  }

  Future<void> addTenant(Tenant tenant) async {
    await _repo.addTenant(tenant);
    await refreshAll();
  }

  Future<void> updateTenant(Tenant tenant) async {
    await _repo.updateTenant(tenant);
    await refreshAll();
  }

  Future<void> deleteTenant(String id) async {
    await _repo.deleteTenant(id);
    await refreshAll();
  }

  Future<void> deleteReading(String roomId, String month) async {
    await _repo.deleteReading(roomId, month);
    await refreshAll();
  }

  Future<void> editComplaint(
    String id,
    String title,
    String description,
  ) async {
    await _repo.editComplaint(id, title, description);
    await refreshAll();
  }

  Future<void> deleteComplaint(String id) async {
    await _repo.deleteComplaint(id);
    await refreshAll();
  }

  Future<void> setRentPaid(String id, bool paid) async {
    await _repo.setRentPaid(id, paid);
    await refreshAll();
  }

  Future<void> updateRentAmount(String id, double amount) async {
    await _repo.updateRentAmount(id, amount);
    await refreshAll();
  }

  Future<void> deleteRent(String id) async {
    await _repo.deleteRent(id);
    await refreshAll();
  }

  List<Tenant> get tenantsWithoutRent => tenants
      .where(
        (t) => !rents.any(
          (r) => r.tenantId == t.id && r.month == month,
        ),
      )
      .toList();

  Future<void> createMissingRents() async {
    for (final tenant in tenantsWithoutRent) {
      await _repo.createRentFor(tenant.id);
    }
    await refreshAll();
  }
}
