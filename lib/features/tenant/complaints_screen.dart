import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/pg_controller.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

Color statusColor(ComplaintStatus status) => switch (status) {
      ComplaintStatus.open => Colors.red,
      ComplaintStatus.inProgress => Colors.orange,
      ComplaintStatus.resolved => Colors.green,
    };

String statusText(ComplaintStatus status) => switch (status) {
      ComplaintStatus.open => 'OPEN',
      ComplaintStatus.inProgress => 'IN PROGRESS',
      ComplaintStatus.resolved => 'RESOLVED',
    };

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pg = Get.find<PgController>();
    final auth = Get.find<AuthController>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New complaint'),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _ComplaintForm(
            tenantId: auth.user.value!.tenantId!,
          ),
        ),
      ),
      body: Obx(() {
        final mine = pg.complaints
            .where(
              (complaint) => complaint.tenantId == auth.user.value?.tenantId,
            )
            .toList();

        if (mine.isEmpty) {
          return const EmptyState(
            'No complaints raised.',
            icon: Icons.check_circle_outline,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
          itemCount: mine.length,
          itemBuilder: (_, index) {
            final complaint = mine[index];

            return AppCard(
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
                      StatusPill(
                        statusText(complaint.status),
                        statusColor(complaint.status),
                      ),
                    ],
                  ),
                  if (complaint.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      complaint.description,
                      style: const TextStyle(height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    dateLabel(complaint.createdAt),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

class _ComplaintForm extends StatefulWidget {
  const _ComplaintForm({required this.tenantId});

  final String tenantId;

  @override
  State<_ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<_ComplaintForm> {
  final _title = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Raise a complaint',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title (e.g. AC, Wi-Fi)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Details'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              if (_title.text.trim().isEmpty) return;

              await Get.find<PgController>().raiseComplaint(
                widget.tenantId,
                _title.text.trim(),
                _description.text.trim(),
              );

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
