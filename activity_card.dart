
import 'package:flutter/material.dart';
import 'package:family_travel_app/features/plan/data/item_model.dart';

class ActivityCard extends StatelessWidget {
  final Item item;

  const ActivityCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              '${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')} - ${item.endTime != null ? '${item.endTime!.hour.toString().padLeft(2, '0')}:${item.endTime!.minute.toString().padLeft(2, '0')}' : 'Ongoing'}'
            ),
            if (item.note != null && item.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(item.note!),
              ),
            // TODO: Add location display if available
          ],
        ),
      ),
    );
  }
}


