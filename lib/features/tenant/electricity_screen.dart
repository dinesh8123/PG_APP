import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/pg_controller.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';

class ElectricityScreen extends StatelessWidget {
  const ElectricityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pg = Get.find<PgController>();
    final auth = Get.find<AuthController>();

    return Obx(() {
      final tenant = pg.tenantById(auth.user.value?.tenantId ?? '');
      if (tenant == null) return const EmptyState('Tenant not found');

      final months = pg.readings
          .where((reading) => reading.roomId == tenant.roomId)
          .map((reading) => reading.month)
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (months.isEmpty) {
        return const EmptyState(
          'No meter reading entered yet.',
          icon: Icons.bolt_outlined,
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          for (final month in months)
            _BillCard(
              month: month,
              bill: pg.billFor(tenant, month)!,
            ),
        ],
      );
    });
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.month, required this.bill});

  final String month;
  final ElectricityBill bill;

  @override
  Widget build(BuildContext context) {
    final reading = bill.reading;

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: kHeroGradient,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    monthLabel(month),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Your share',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      rupee(bill.share),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                row('Previous reading', '${reading.previous}'),
                row('Current reading', '${reading.current}'),
                row('Units used', '${reading.units}'),
                row('Rate per unit', rupee(PgController.unitRate)),
                const Divider(height: 20),
                row('Room total', rupee(bill.total)),
                row('People in room', '${bill.occupants}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
