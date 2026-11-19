import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/pg_controller.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  Future<void> _editAmount(
    BuildContext context,
    PgController pg,
    RentRecord rent,
  ) async {
    final controller = TextEditingController(
      text: rent.amount.toStringAsFixed(0),
    );

    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Edit rent amount'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '\u20B9 ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
            ),
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx, amount);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (value != null) {
      await pg.updateRentAmount(rent.id, value);
      toast('Updated', 'Rent changed to ${rupee(value)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pg = Get.find<PgController>();
    final auth = Get.find<AuthController>();
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final thisMonth =
          pg.rents.where((rent) => rent.month == pg.month).toList();

      final collected = thisMonth
          .where((rent) => rent.paid)
          .fold<double>(0, (sum, rent) => sum + rent.amount);

      final pending = thisMonth
          .where((rent) => !rent.paid)
          .fold<double>(0, (sum, rent) => sum + rent.amount);

      final deposits = pg.tenants.fold<double>(
        0,
        (sum, tenant) => sum + tenant.deposit,
      );

      final total = collected + pending;
      final progress = total == 0 ? 0.0 : collected / total;

      final sorted = [...thisMonth]..sort(
          (a, b) => (a.paid ? 1 : 0).compareTo(b.paid ? 1 : 0),
        );

      final occupied = pg.beds.length - pg.vacantBeds.length;
      final openComplaints = pg.complaints
          .where(
            (complaint) => complaint.status != ComplaintStatus.resolved,
          )
          .length;

      final missing = pg.tenantsWithoutRent;

      return RefreshIndicator(
        onRefresh: pg.refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            HeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${greeting()}, ${auth.user.value?.name ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    longDate(DateTime.now()),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Rent collected in ${monthLabel(pg.month)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rupee(collected),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).round()}% of '
                    '${rupee(total)} received  \u2022  '
                    '${thisMonth.where((rent) => rent.paid).length}'
                    '/${thisMonth.length} tenants paid',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.45,
              children: [
                StatCard(
                  label: 'Rent pending',
                  value: rupee(pending),
                  icon: Icons.hourglass_bottom,
                  color: Colors.orange.shade700,
                ),
                StatCard(
                  label: 'Deposits held',
                  value: rupee(deposits),
                  icon: Icons.savings_outlined,
                ),
                StatCard(
                  label: 'Beds occupied',
                  value: '$occupied / ${pg.beds.length}',
                  icon: Icons.bed_outlined,
                  color: Colors.blue.shade700,
                ),
                StatCard(
                  label: 'Open complaints',
                  value: '$openComplaints',
                  icon: Icons.report_problem_outlined,
                  color: Colors.red.shade600,
                ),
              ],
            ),
            if (missing.isNotEmpty) ...[
              const SizedBox(height: 16),
              AppCard(
                color: Colors.orange.shade50,
                margin: EdgeInsets.zero,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${missing.length} tenant(s) have no rent '
                        'entry for this month.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await pg.createMissingRents();
                        toast('Done', 'Rent entries created');
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            const SectionTitle('Tenant-wise rent'),
            if (sorted.isEmpty)
              AppCard(
                child: Text(
                  'No rent entries yet. Add a tenant to get started.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            ...sorted.map(
              (rent) => _RentRow(
                record: rent,
                onEditAmount: () => _editAmount(context, pg, rent),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RentRow extends StatelessWidget {
  const _RentRow({
    required this.record,
    required this.onEditAmount,
  });

  final RentRecord record;
  final VoidCallback onEditAmount;

  @override
  Widget build(BuildContext context) {
    final pg = Get.find<PgController>();
    final tenant = pg.tenantById(record.tenantId);
    final room = pg.roomById(tenant?.roomId ?? '');
    final rent = record;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      child: Row(
        children: [
          InitialsAvatar(tenant?.name ?? '-'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenant?.name ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Room ${room?.number ?? '-'}  \u2022  '
                  'Deposit ${rupee(tenant?.deposit ?? 0)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rupee(rent.amount),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              rent.paid
                  ? const StatusPill('PAID', Colors.green)
                  : StatusPill('PENDING', Colors.orange.shade800),
            ],
          ),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'toggle':
                  await pg.setRentPaid(rent.id, !rent.paid);
                  toast(
                    'Updated',
                    rent.paid ? 'Marked as pending' : 'Marked as paid',
                  );
                  break;

                case 'edit':
                  onEditAmount();
                  break;

                case 'delete':
                  final confirmed = await confirmDelete(
                    context,
                    title: 'Delete rent entry?',
                    message: '${tenant?.name ?? 'This'} rent for '
                        '${monthLabel(rent.month)} will be removed.',
                  );

                  if (confirmed) {
                    await pg.deleteRent(rent.id);
                    toast('Deleted', 'Rent entry removed');
                  }
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'toggle',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    rent.paid ? Icons.undo : Icons.check_circle_outline,
                  ),
                  title: Text(
                    rent.paid ? 'Mark as pending' : 'Mark as paid',
                  ),
                ),
              ),
              ...rowActionItems().map(
                (entry) => PopupMenuItem<String>(
                  value: (entry as PopupMenuItem<RowAction>).value!.name,
                  child: entry.child,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
