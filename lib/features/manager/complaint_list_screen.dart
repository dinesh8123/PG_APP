import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pg_controller.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../tenant/complaints_screen.dart' show statusColor, statusText;

class ComplaintListScreen extends StatefulWidget {
  const ComplaintListScreen({super.key});

  @override
  State<ComplaintListScreen> createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  final pg = Get.find<PgController>();
  ComplaintStatus? _filter;

  Future<void> _edit(Complaint complaint) async {
    final title = TextEditingController(text: complaint.title);
    final description = TextEditingController(
      text: complaint.description,
    );

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit complaint',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await pg.editComplaint(
        complaint.id,
        title.text.trim(),
        description.text.trim(),
      );
      toast('Updated', 'Complaint saved');
    }
  }

  Future<void> _delete(Complaint complaint) async {
    final confirmed = await confirmDelete(
      context,
      title: 'Delete complaint?',
      message: '"${complaint.title}" will be removed.',
    );

    if (confirmed) {
      await pg.deleteComplaint(complaint.id);
      toast('Deleted', 'Complaint removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            children: [
              _chip(
                'All',
                _filter == null,
                () => setState(() => _filter = null),
              ),
              for (final status in ComplaintStatus.values)
                _chip(
                  statusText(status),
                  _filter == status,
                  () => setState(() => _filter = status),
                ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final list = pg.complaints
                .where(
                  (complaint) => _filter == null || complaint.status == _filter,
                )
                .toList();

            if (list.isEmpty) {
              return const EmptyState(
                'No complaints here.',
                icon: Icons.check_circle_outline,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: list.length,
              itemBuilder: (_, index) {
                final complaint = list[index];
                final tenant = pg.tenantById(complaint.tenantId);
                final room = pg.roomById(tenant?.roomId ?? '');

                return AppCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 4, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              complaint.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          PopupMenuButton<RowAction>(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            onSelected: (action) {
                              if (action == RowAction.edit) {
                                _edit(complaint);
                              } else {
                                _delete(complaint);
                              }
                            },
                            itemBuilder: (_) => rowActionItems(),
                          ),
                        ],
                      ),
                      if (complaint.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 12,
                            bottom: 8,
                          ),
                          child: Text(
                            complaint.description,
                            style: TextStyle(
                              color: scheme.onSurface,
                              height: 1.35,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Room ${room?.number ?? '-'}'
                              ' \u2022 ${tenant?.name ?? '-'}'
                              ' \u2022 ${dateLabel(complaint.createdAt)}',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          PopupMenuButton<ComplaintStatus>(
                            tooltip: 'Change status',
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            onSelected: (status) => pg.setComplaintStatus(
                              complaint.id,
                              status,
                            ),
                            itemBuilder: (_) => ComplaintStatus.values
                                .map(
                                  (status) => PopupMenuItem(
                                    value: status,
                                    child: Text(statusText(status)),
                                  ),
                                )
                                .toList(),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StatusPill(
                                    statusText(complaint.status),
                                    statusColor(complaint.status),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 18,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _chip(
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: scheme.primary,
        backgroundColor: scheme.surface,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? scheme.onPrimary : scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
