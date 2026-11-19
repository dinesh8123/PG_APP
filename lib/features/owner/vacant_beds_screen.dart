import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pg_controller.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../manager/add_tenant_screen.dart';

class VacantBedsScreen extends StatelessWidget {
  const VacantBedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pg = Get.find<PgController>();
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final vacant = pg.vacantBeds;

      final averageRent = pg.tenants.isEmpty
          ? 0.0
          : pg.tenants.fold<double>(
                0,
                (sum, tenant) => sum + tenant.monthlyRent,
              ) /
              pg.tenants.length;

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.45,
                  child: StatCard(
                    label: 'Vacant of ${pg.beds.length} beds',
                    value: '${vacant.length}',
                    icon: Icons.bed_outlined,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.45,
                  child: StatCard(
                    label: 'Monthly rent at risk',
                    value: rupee(vacant.length * averageRent),
                    icon: Icons.trending_down,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _legend(context, Colors.green, 'Occupied'),
              const SizedBox(width: 16),
              _legend(context, Colors.red.shade400, 'Vacant'),
            ],
          ),
          const SizedBox(height: 8),
          if (pg.rooms.isEmpty)
            const EmptyState(
              'No rooms set up.',
              icon: Icons.meeting_room_outlined,
            ),
          for (final room in pg.rooms)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Room ${room.number}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${pg.occupantsIn(room.id)}/'
                        '${pg.beds.where((bed) => bed.roomId == room.id).length}'
                        ' occupied',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final bed in pg.beds.where(
                        (bed) => bed.roomId == room.id,
                      ))
                        _BedChip(bedId: bed.id),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _legend(
    BuildContext context,
    Color color,
    String text,
  ) =>
      Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
}

class _BedChip extends StatelessWidget {
  const _BedChip({required this.bedId});

  final String bedId;

  @override
  Widget build(BuildContext context) {
    final pg = Get.find<PgController>();
    final bed = pg.beds.firstWhere((bed) => bed.id == bedId);
    final tenant = bed.vacant ? null : pg.tenantById(bed.tenantId!);

    final color = readableAccent(
      context,
      bed.vacant ? Colors.red.shade400 : Colors.green.shade600,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (bed.vacant) {
          Get.to(() => TenantFormScreen(presetBedId: bed.id));
        } else if (tenant != null) {
          Get.to(() => TenantFormScreen(tenant: tenant));
        }
      },
      child: Container(
        width: 98,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(
              bed.vacant ? Icons.bed_outlined : Icons.bed,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              'Bed ${bed.label}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 12,
              ),
            ),
            Text(
              bed.vacant ? 'Vacant' : tenant?.name.split(' ').first ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
