import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:family_travel_app/features/memory/data/memory_model.dart';
import 'package:family_travel_app/features/memory/data/memory_repository.dart';
import 'package:family_travel_app/features/memory/presentation/widgets/media_picker_bottom_sheet.dart';
import 'package:family_travel_app/features/memory/presentation/memory_viewer.dart';
import 'package:family_travel_app/features/memory/data/memory_sync_service.dart';
import 'package:family_travel_app/features/memory/data/pending_memory_draft.dart';

class MemoryGalleryScreen extends ConsumerStatefulWidget {
  final String planId;

  const MemoryGalleryScreen({super.key, required this.planId});

  @override
  ConsumerState<MemoryGalleryScreen> createState() => _MemoryGalleryScreenState();
}

class _MemoryGalleryScreenState extends ConsumerState<MemoryGalleryScreen> {
  final PagingController<int, Memory> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final firestoreMemories = await ref.read(memoryRepositoryProvider).watchMemories(widget.planId, limit: 20).first;
      final pendingMemories = ref.read(memorySyncServiceProvider).getPendingMemories(widget.planId);

      // Merge and deduplicate memories. Prioritize Firestore memories.
      final allMemories = <Memory>[];
      final firestoreMemoryIds = firestoreMemories.map((m) => m.id).toSet();

      for (final pending in pendingMemories) {
        // Create a dummy Memory object for pending items
        final dummyMemory = Memory(
          id: pending.id, // Use pending.id as the unique identifier
          type: pending.type,
          mediaUrl: pending.localPath, // Use local path as mediaUrl for pending
          thumbUrl: pending.localPath, // Use local path as thumbUrl for pending
          width: 0, // Placeholder
          height: 0, // Placeholder
          caption: pending.caption,
          createdAt: DateTime.now(), // Placeholder
          createdBy: pending.userId,
          localId: pending.id, // Store localId for identification
        );
        allMemories.add(dummyMemory);
      }

      for (final firestoreMemory in firestoreMemories) {
        // If a Firestore memory has a localId, it means it was once a pending memory.
        // We should remove the corresponding pending memory if it exists.
        if (firestoreMemory.localId != null) {
          allMemories.removeWhere((m) => m.localId == firestoreMemory.localId);
        }
        allMemories.add(firestoreMemory);
      }

      // Sort by createdAt (newest first), with pending items appearing first if createdAt is similar
      allMemories.sort((a, b) {
        if (a.createdAt == null && b.createdAt != null) return -1;
        if (a.createdAt != null && b.createdAt == null) return 1;
        if (a.createdAt == null && b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!); // Newest first
      });

      _pagingController.appendLastPage(allMemories);
    } catch (error) {
      _pagingController.appendStatus(PagingStatus.noItemsFound);
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: PagedSliverGrid<int, Memory>(
          pagingController: _pagingController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Staggered layout
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          builderDelegate: PagedChildBuilderDelegate<Memory>(
            itemBuilder: (context, item, index) {
              final isPending = item.localId != null && item.mediaUrl == item.localId; // Check if it's a pending item
              return GestureDetector(
                onTap: () {
                  if (!isPending) {
                    context.push('/plan/${widget.planId}/memory/${item.id}');
                  } else {
                    // TODO: Implement cancel/retry swipe-actions on pending tiles
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Memory is still uploading...')), 
                    );
                  }
                },
                child: Hero(
                  tag: item.id,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (isPending)
                        Image.file(
                          File(item.localId!), // Use local path for pending items
                          fit: BoxFit.cover,
                          color: Colors.grey.withOpacity(0.5), // Shimmer effect
                          colorBlendMode: BlendMode.modulate,
                        ) 
                      else
                        CachedNetworkImage(
                          imageUrl: item.thumbUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      if (item.type == MemoryType.video)
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 48.0,
                          ),
                        ),
                      if (isPending)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                    ],
                  ),
                ),
              );
            },
            noItemsFoundIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/empty_state.json', // TODO: Add Lottie animation file
                    width: 200,
                    height: 200,
                    fit: BoxFit.fill,
                  ),
                  const Text('Add your first memory!'),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => MediaPickerBottomSheet(planId: widget.planId),
          );
        },
        label: const Text('Add Memory'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}


