import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/pg_controller.dart';
import '../../core/insta_loader.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class RentScreen extends StatelessWidget {
  const RentScreen({super.key});

  Future<void> _pay(
    BuildContext context,
    PgController pg,
    RentRecord record,
  ) async {
    final paid = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => _PaySheet(amount: record.amount),
    );

    if (paid == true) {
      await pg.payRent(record.id);
      toast(
        'Payment successful',
        '${rupee(record.amount)} received (demo)',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pg = Get.find<PgController>();
    final auth = Get.find<AuthController>();
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final tenant = pg.tenantById(auth.user.value?.tenantId ?? '');
      if (tenant == null) return const EmptyState('Tenant not found');

      final records = pg.rents
          .where((rent) => rent.tenantId == tenant.id)
          .toList()
        ..sort((a, b) => b.month.compareTo(a.month));

      final current = records.firstWhereOrNull(
        (rent) => rent.month == pg.month,
      );
      final room = pg.roomById(tenant.roomId);

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          HeroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${greeting()}, ${tenant.name.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Room ${room?.number ?? '-'}  \u2022  '
                  'Deposit ${rupee(tenant.deposit)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                if (current != null) ...[
                  Row(
                    children: [
                      Text(
                        '${monthLabel(current.month)} rent',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          current.paid ? 'PAID' : 'DUE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rupee(current.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    current.paid
                        ? 'Paid on ${dateLabel(current.paidOn!)}'
                        : 'Due by ${dateLabel(current.dueDate)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                  if (!current.paid) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: kPrimaryDark,
                        ),
                        icon: const Icon(Icons.lock_outline, size: 18),
                        label: Text('Pay ${rupee(current.amount)}'),
                        onPressed: () => _pay(context, pg, current),
                      ),
                    ),
                  ],
                ] else
                  Text(
                    'No rent entry for this month yet.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),
          ),
          const SectionTitle('Payment history'),
          if (records.isEmpty)
            AppCard(
              child: Text(
                'No payments yet.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          ...records.map(
            (rent) => AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (rent.paid ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      rent.paid ? Icons.check_rounded : Icons.schedule,
                      color: rent.paid ? Colors.green : Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthLabel(rent.month),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          rent.paid
                              ? 'Paid on ${dateLabel(rent.paidOn!)}'
                              : 'Due ${dateLabel(rent.dueDate)}',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      rent.paid
                          ? const StatusPill('PAID', Colors.green)
                          : StatusPill('DUE', Colors.orange.shade800),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _PaySheet extends StatefulWidget {
  const _PaySheet({required this.amount});

  final double amount;

  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  int _method = 0;
  bool _processing = false;

  static const _methods = [
    (
      Icons.account_balance_wallet_outlined,
      'UPI',
      'GPay, PhonePe, Paytm',
    ),
    (Icons.credit_card, 'Card', 'Credit or debit card'),
    (
      Icons.account_balance_outlined,
      'Net banking',
      'All major banks',
    ),
  ];

  Future<void> _go() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose payment method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < _methods.length; index++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      _method == index ? scheme.primary : scheme.outlineVariant,
                  width: _method == index ? 1.8 : 1,
                ),
              ),
              child: ListTile(
                onTap:
                    _processing ? null : () => setState(() => _method = index),
                leading: Icon(
                  _methods[index].$1,
                  color: scheme.primary,
                ),
                title: Text(
                  _methods[index].$2,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_methods[index].$3),
                trailing: Icon(
                  _method == index
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _method == index
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _processing ? null : _go,
            child: _processing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: InstaLoader(
                          size: 20,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Processing...'),
                    ],
                  )
                : Text('Pay ${rupee(widget.amount)}'),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Demo payment - no money is charged',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
