import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pg_controller.dart';
import '../../core/utils.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class MeterReadingScreen extends StatefulWidget {
  const MeterReadingScreen({super.key});

  @override
  State<MeterReadingScreen> createState() => _MeterReadingScreenState();
}

class _MeterReadingScreenState extends State<MeterReadingScreen> {
  final pg = Get.find<PgController>();
  final _current = TextEditingController();
  String? _roomId;

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final roomId = _roomId;
    final value = int.tryParse(_current.text.trim());

    if (roomId == null || value == null) {
      toast(
        'Missing data',
        'Select a room and enter the reading',
        error: true,
      );
      return;
    }

    final previous = pg.lastClosing(roomId);

    if (value < previous) {
      toast(
        'Invalid reading',
        'Current reading cannot be below $previous',
        error: true,
      );
      return;
    }

    await pg.saveReading(
      MeterReading(
        roomId: roomId,
        month: pg.month,
        previous: previous,
        current: value,
      ),
    );

    _current.clear();
    toast('Saved', '${value - previous} units recorded');
  }

  Future<void> _edit(MeterReading reading) async {
    final previousController = TextEditingController(
      text: '${reading.previous}',
    );
    final currentController = TextEditingController(
      text: '${reading.current}',
    );
    final room = pg.roomById(reading.roomId)?.number ?? '-';

    final result = await showModalBottomSheet<MeterReading>(
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
            Text(
              'Edit reading \u2022 Room $room',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              monthLabel(reading.month),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: previousController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Previous',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: currentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Current',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final previous = int.tryParse(
                  previousController.text.trim(),
                );
                final current = int.tryParse(
                  currentController.text.trim(),
                );

                if (previous == null || current == null || current < previous) {
                  toast(
                    'Invalid reading',
                    'Current must be at least the previous value',
                    error: true,
                  );
                  return;
                }

                Navigator.pop(
                  ctx,
                  MeterReading(
                    roomId: reading.roomId,
                    month: reading.month,
                    previous: previous,
                    current: current,
                  ),
                );
              },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await pg.saveReading(result);
      toast('Updated', '${result.units} units recorded');
    }
  }

  Future<void> _delete(MeterReading reading) async {
    final room = pg.roomById(reading.roomId)?.number ?? '-';

    final confirmed = await confirmDelete(
      context,
      title: 'Delete reading?',
      message: 'Room $room reading for '
          '${monthLabel(reading.month)} will be removed.',
    );

    if (confirmed) {
      await pg.deleteReading(reading.roomId, reading.month);
      toast('Deleted', 'Reading removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final previous = _roomId == null ? null : pg.lastClosing(_roomId!);

      final all = [...pg.readings]..sort((a, b) {
          final monthComparison = b.month.compareTo(a.month);
          return monthComparison != 0
              ? monthComparison
              : a.roomId.compareTo(b.roomId);
        });

      final doneThisMonth =
          all.where((reading) => reading.month == pg.month).length;

      String? lastMonth;

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'New reading \u2022 ${monthLabel(pg.month)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _roomId,
                  decoration: const InputDecoration(labelText: 'Room'),
                  items: pg.rooms
                      .map(
                        (room) => DropdownMenuItem(
                          value: room.id,
                          child: Text('Room ${room.number}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _roomId = value);
                  },
                ),
                if (previous != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Previous reading: $previous',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _current,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current reading',
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save reading'),
                ),
              ],
            ),
          ),
          SectionTitle(
            'Readings',
            trailing: Text(
              '$doneThisMonth/${pg.rooms.length} this month',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          if (all.isEmpty)
            AppCard(
              child: Text(
                'No readings entered yet.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          for (final reading in all) ...[
            if (reading.month != lastMonth)
              Padding(
                padding: const EdgeInsets.only(
                  top: 6,
                  bottom: 8,
                  left: 4,
                ),
                child: Text(
                  monthLabel(lastMonth = reading.month),
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            AppCard(
              padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pg.roomById(reading.roomId)?.number ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room '
                          '${pg.roomById(reading.roomId)?.number ?? '-'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${reading.previous} \u2192 ${reading.current}',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${reading.units} units',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  PopupMenuButton<RowAction>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (action) {
                      if (action == RowAction.edit) {
                        _edit(reading);
                      } else {
                        _delete(reading);
                      }
                    },
                    itemBuilder: (_) => rowActionItems(),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}
