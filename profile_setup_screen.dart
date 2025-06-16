import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:family_travel_app/core/firestore_service.dart';
import 'package:family_travel_app/features/auth/data/user_model.dart';

enum TravelStyle {
  car,
  train,
  air,
}

class ProfileSetupScreen extends HookConsumerWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayNameController = useTextEditingController();
    final familySize = useState(1);
    final childrenAges = useState<List<int>>([]);
    final travelStyle = useState<TravelStyle?>(null);

    final formKey = useMemoized(() => GlobalKey<FormState>(), []);

    final isFormValid = useListenableSelector(formKey.currentState, () {
      return formKey.currentState?.validate() ?? false;
    });

    void _addChildAge() {
      childrenAges.value = [...childrenAges.value, 0];
    }

    void _updateChildAge(int index, int age) {
      final updatedAges = List<int>.from(childrenAges.value);
      updatedAges[index] = age;
      childrenAges.value = updatedAges;
    }

    void _removeChildAge(int index) {
      final updatedAges = List<int>.from(childrenAges.value);
      updatedAges.removeAt(index);
      childrenAges.value = updatedAges;
    }

    Future<void> _saveProfile() async {
      if (formKey.currentState?.validate() ?? false) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          // Handle error: user not logged in
          return;
        }

        final firestoreService = ref.read(firestoreServiceProvider);
        final String familyId = const Uuid().v4(); // Generate a new family ID

        // Create or join family
        // TODO: Implement deep link parsing for invite=fid to join existing family
        final family = Family(
          id: familyId,
          ownerUid: currentUser.uid,
          members: [currentUser.uid],
          createdAt: DateTime.now(),
        );
        await firestoreService.setDocument(
          'families',
          family.id,
          family.toJson(),
        );

        // Create user profile
        final appUser = AppUser(
          uid: currentUser.uid,
          familyId: family.id,
          displayName: displayNameController.text,
          photoURL: currentUser.photoURL,
          familySize: familySize.value,
          childrenAges: childrenAges.value,
          travelStyle: travelStyle.value ?? TravelStyle.car, // Default to car if not selected
          createdAt: DateTime.now(),
        );
        await firestoreService.setDocument(
          'users',
          appUser.uid,
          appUser.toJson(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!'))
        );
        context.go('/'); // Navigate to home after profile setup
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Your Profile')),
      body: Form(
        key: formKey,
        onChanged: () {
          formKey.currentState?.validate();
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your display name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: const Text('Family Size'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (familySize.value > 1) {
                        familySize.value--;
                      }
                    },
                  ),
                  Text('${familySize.value}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      familySize.value++;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Children Ages (optional)'),
            Wrap(
              spacing: 8.0,
              children: [
                ...childrenAges.value.asMap().entries.map((entry) {
                  final index = entry.key;
                  final age = entry.value;
                  return Chip(
                    label: Text('$age'),
                    onDeleted: () => _removeChildAge(index),
                  );
                }).toList(),
                ActionChip(
                  avatar: const Icon(Icons.add),
                  label: const Text('Add Child Age'),
                  onPressed: _addChildAge,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text('Travel Style'),
            Column(
              children: TravelStyle.values.map((style) {
                return RadioListTile<TravelStyle>(
                  title: Text(style.toString().split('.').last.toUpperCase()),
                  value: style,
                  groupValue: travelStyle.value,
                  onChanged: (TravelStyle? value) {
                    travelStyle.value = value;
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isFormValid ? _saveProfile : null,
        label: const Text('Save & Continue'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}


