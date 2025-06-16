import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:family_travel_app/features/plan/presentation/plan_board_screen.dart';
import 'package:family_travel_app/features/expense/presentation/expense_tab_screen.dart';
import 'package:family_travel_app/features/memory/presentation/memory_gallery_screen.dart';

class HomeShell extends HookConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);

    // TODO: Replace with actual planId from user's active family/plan
    const String dummyPlanId = 'dummy_plan_id'; 

    final List<Widget> screens = [
      const Center(child: Text('Home Screen')), // TODO: Replace with actual Home Screen
      PlanBoardScreen(planId: dummyPlanId),
      ExpenseTabScreen(planId: dummyPlanId),
      MemoryGalleryScreen(planId: dummyPlanId), // Added MemoryGalleryScreen
      const Center(child: Text('Profile Screen')), // TODO: Replace with actual Profile Screen
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex.value,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Expense',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'Memory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex.value,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          selectedIndex.value = index;
          // TODO: Navigate using GoRouter if needed for deep linking or persistent state
          // Example navigation based on index
          if (index == 1) {
            context.go('/plan/$dummyPlanId');
          } else if (index == 2) {
            context.go('/plan/$dummyPlanId/expense');
          } else if (index == 3) { // Added navigation for Memory tab
            context.go('/plan/$dummyPlanId/memory');
          }
        },
      ),
    );
  }
}


