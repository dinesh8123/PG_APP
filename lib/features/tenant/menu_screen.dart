import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pg_controller.dart';
import '../../core/widgets.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pg = Get.find<PgController>();
    final todayIndex = DateTime.now().weekday - 1;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (pg.menu.isEmpty) {
        return const EmptyState(
          'Menu not available yet.',
          icon: Icons.restaurant_menu,
        );
      }

      Widget meal(
        IconData icon,
        String label,
        String food,
      ) =>
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 10),
                SizedBox(
                  width: 76,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    food,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: pg.menu.length,
        itemBuilder: (_, index) {
          final day = pg.menu[index];
          final today = index == todayIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border:
                  today ? Border.all(color: scheme.primary, width: 1.8) : null,
            ),
            child: AppCard(
              margin: EdgeInsets.zero,
              color: today ? scheme.primaryContainer : scheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        day.day,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (today) ...[
                        const SizedBox(width: 8),
                        StatusPill('TODAY', scheme.primary),
                      ],
                    ],
                  ),
                  meal(
                    Icons.free_breakfast_outlined,
                    'Breakfast',
                    day.breakfast,
                  ),
                  meal(Icons.lunch_dining_outlined, 'Lunch', day.lunch),
                  meal(
                    Icons.dinner_dining_outlined,
                    'Dinner',
                    day.dinner,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
