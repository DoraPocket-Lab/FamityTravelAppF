import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:family_travel_app/features/plan/data/plan_model.dart';
import 'package:family_travel_app/features/plan/data/item_model.dart';
import 'package:family_travel_app/features/plan/controller/plan_notifier.dart';
import 'package:family_travel_app/features/plan/presentation/widgets/activity_card.dart';

class PlanBoardScreen extends HookConsumerWidget {
  final String planId;

  const PlanBoardScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planItemsAsync = ref.watch(currentPlanItemsProvider(planId));
    final planNotifier = ref.read(planNotifierProvider(planId).notifier);

    final pageController = usePageController();
    final selectedDay = useState<DateTime?>(null);

    // TODO: Get plan details to determine start and end dates
    // For now, using dummy dates
    final dummyStartDate = DateTime.now().subtract(const Duration(days: 2));
    final dummyEndDate = DateTime.now().add(const Duration(days: 5));

    final daysInPlan = List<DateTime>.generate(
      dummyEndDate.difference(dummyStartDate).inDays + 1,
      (index) => DateTime(
        dummyStartDate.year,
        dummyStartDate.month,
        dummyStartDate.day + index,
      ),
    );

    useEffect(() {
      if (daysInPlan.isNotEmpty) {
        selectedDay.value = daysInPlan.first;
      }
      return null;
    }, [daysInPlan]);

    void _onReorder(int oldIndex, int newIndex, List<Item> currentItems) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final Item item = currentItems.removeAt(oldIndex);
      currentItems.insert(newIndex, item);

      // Update sortIndex for all items in the current day
      final reorderedItems = currentItems.map((e) => e.copyWith(sortIndex: currentItems.indexOf(e))).toList();
      planNotifier.reorderItems(planId, reorderedItems);
    }

    void _showAddItemBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          final titleController = TextEditingController();
          final startTimeController = TextEditingController();
          final endTimeController = TextEditingController();
          final noteController = TextEditingController();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Activity Title'),
                ),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(labelText: 'Start Time (HH:MM)'),
                  keyboardType: TextInputType.datetime,
                ),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(labelText: 'End Time (HH:MM, optional)'),
                  keyboardType: TextInputType.datetime,
                ),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text;
                    final startTime = DateTime.tryParse('2024-01-01 ${startTimeController.text}'); // Dummy date
                    final endTime = endTimeController.text.isNotEmpty ? DateTime.tryParse('2024-01-01 ${endTimeController.text}') : null; // Dummy date

                    if (title.isNotEmpty && startTime != null) {
                      final newItem = Item(
                        id: const Uuid().v4(),
                        planId: planId,
                        day: selectedDay.value!,
                        startTime: startTime,
                        endTime: endTime,
                        title: title,
                        note: noteController.text.isEmpty ? null : noteController.text,
                        sortIndex: 0, // Will be updated by reorderItems
                        createdBy: 'TODO_CURRENT_USER_UID', // TODO: Get current user UID
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      planNotifier.createItem(planId, newItem);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a title and valid start time.')),
                      );
                    }
                  },
                  child: const Text('Add Activity'),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Board')), // TODO: Display plan title
      body: Column(
        children: [
          SizedBox(
            height: 60.0, // Height for the day selector
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: daysInPlan.length,
              itemBuilder: (context, index) {
                final day = daysInPlan[index];
                final isSelected = selectedDay.value?.day == day.day &&
                                   selectedDay.value?.month == day.month &&
                                   selectedDay.value?.year == day.year;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text('${day.month}/${day.day}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        selectedDay.value = day;
                        pageController.jumpToPage(index);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: daysInPlan.length,
              onPageChanged: (index) {
                selectedDay.value = daysInPlan[index];
              },
              itemBuilder: (context, pageIndex) {
                final currentDay = daysInPlan[pageIndex];
                return planItemsAsync.when(
                  data: (items) {
                    final itemsForDay = items
                        .where((item) =>
                            item.day.year == currentDay.year &&
                            item.day.month == currentDay.month &&
                            item.day.day == currentDay.day)
                        .toList();
                    return ReorderableListView.builder(
                      itemCount: itemsForDay.length,
                      itemBuilder: (context, index) {
                        final item = itemsForDay[index];
                        return ActivityCard(key: ValueKey(item.id), item: item);
                      },
                      onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, itemsForDay),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}


