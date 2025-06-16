
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:family_travel_app/features/memory/data/memory_model.dart';
import 'package:family_travel_app/features/memory/data/memory_repository.dart';
import 'package:family_travel_app/features/memory/data/memory_sync_service.dart';
import 'package:family_travel_app/features/auth/data/auth_repository.dart'; // For current user UID

class MediaPickerBottomSheet extends ConsumerStatefulWidget {
  final String planId;

  const MediaPickerBottomSheet({super.key, required this.planId});

  @override
  ConsumerState<MediaPickerBottomSheet> createState() => _MediaPickerBottomSheetState();
}

class _MediaPickerBottomSheetState extends ConsumerState<MediaPickerBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedFiles = [];
  bool _isLoading = false;
  final TextEditingController _captionController = TextEditingController();

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    List<XFile>? pickedFiles;
    if (isVideo) {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        pickedFiles = [video];
      }
    } else {
      pickedFiles = await _picker.pickMultiImage();
    }

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(pickedFiles);
      });
    }
  }

  Future<void> _uploadMemories() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final memoryRepository = ref.read(memoryRepositoryProvider);
    final memorySyncService = ref.read(memorySyncServiceProvider);
    final currentUser = ref.read(authStateProvider).value; // Get current user

    if (currentUser == null) {
      // TODO: Handle user not logged in
      return;
    }

    final List<LocalFile> localFiles = _selectedFiles.map((xFile) {
      final type = xFile.path.endsWith(".mp4") ? MemoryType.video : MemoryType.image;
      return LocalFile(
        path: xFile.path,
        type: type,
        caption: _captionController.text.isEmpty ? null : _captionController.text,
      );
    }).toList();

    try {
      // Queue for offline sync
      for (final localFile in localFiles) {
        final pendingDraft = PendingMemoryDraft(
          id: localFile.localId,
          planId: widget.planId,
          localPath: localFile.path,
          type: localFile.type,
          caption: localFile.caption,
          userId: currentUser.uid,
        );
        await memorySyncService.queueMemory(pendingDraft);
      }

      // TODO: Show local thumbs immediately with shimmer upload progress

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // TODO: Show error to user
      print("Error queuing memories: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Add New Memories',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              labelText: 'Caption (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick Photos'),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
                icon: const Icon(Icons.video_library),
                label: const Text('Pick Video'),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          if (_selectedFiles.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = _selectedFiles[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.file(File(file.path), width: 100, height: 100, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          const SizedBox(height: 16.0),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _selectedFiles.isEmpty ? null : _uploadMemories,
                  child: const Text('Upload Selected'),
                ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}


