import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pg_controller.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../manager/add_tenant_screen.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final pg = Get.find<PgController>();
  String _query = '';

  Future<void> _delete(Tenant tenant) async {
    final confirmed = await confirmDelete(
      context,
      title: 'Delete ${tenant.name}?',
      message: 'The bed becomes vacant and this tenant\'s rent entries '
          'and complaints are removed.',
    );

    if (confirmed) {
      await pg.deleteTenant(tenant.id);
      toast('Deleted', '${tenant.name} removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add tenant'),
        onPressed: () => Get.to(() => const TenantFormScreen()),
      ),
      body: Obx(() {
        final list = pg.tenants
            .where(
              (tenant) =>
                  tenant.name.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                  tenant.phone.contains(_query),
            )
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                onChanged: (value) {
                  setState(() => _query = value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search by name or number',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: pg.tenants.isEmpty
                  ? const EmptyState(
                      'No tenants yet.\n'
                      'Tap "Add tenant" to create the first one.',
                      icon: Icons.people_outline,
                    )
                  : list.isEmpty
                      ? const EmptyState(
                          'No match found.',
                          icon: Icons.search_off,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            96,
                          ),
                          itemCount: list.length,
                          itemBuilder: (_, index) {
                            final tenant = list[index];
                            final room = pg.roomById(tenant.roomId);
                            final bed = pg.beds.firstWhereOrNull(
                              (bed) => bed.id == tenant.bedId,
                            );

                            return AppCard(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                4,
                                12,
                              ),
                              onTap: () => Get.to(
                                () => TenantFormScreen(tenant: tenant),
                              ),
                              child: Row(
                                children: [
                                  InitialsAvatar(
                                    tenant.name,
                                    size: 48,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tenant.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Room ${room?.number ?? '-'}'
                                          ' \u2022 Bed ${bed?.label ?? '-'}'
                                          '  \u2022  +91 ${tenant.phone}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${rupee(tenant.monthlyRent)}'
                                          '/month  \u2022  '
                                          'Deposit ${rupee(tenant.deposit)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<RowAction>(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    onSelected: (action) {
                                      if (action == RowAction.edit) {
                                        Get.to(
                                          () => TenantFormScreen(
                                            tenant: tenant,
                                          ),
                                        );
                                      } else {
                                        _delete(tenant);
                                      }
                                    },
                                    itemBuilder: (_) => rowActionItems(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      }),
    );
  }
}
