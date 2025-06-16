import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'package:family_travel_app/features/memory/data/memory_model.dart';
import 'package:family_travel_app/features/memory/data/memory_repository.dart';

class MemoryViewer extends ConsumerStatefulWidget {
  final String planId;
  final String memoryId;

  const MemoryViewer({super.key, required this.planId, required this.memoryId});

  @override
  ConsumerState<MemoryViewer> createState() => _MemoryViewerState();
}

class _MemoryViewerState extends ConsumerState<MemoryViewer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final memory = await ref.read(memoryRepositoryProvider).watchMemories(widget.planId).first.then(
      (memories) => memories.firstWhere((m) => m.id == widget.memoryId),
    );

    if (memory.type == MemoryType.video) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(memory.mediaUrl));
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoryAsync = ref.watch(memoryRepositoryProvider).watchMemories(widget.planId).map(
      (memories) => memories.firstWhere((m) => m.id == widget.memoryId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Viewer'),
      ),
      body: Center(
        child: memoryAsync.when(
          data: (memory) {
            if (memory.type == MemoryType.image) {
              return Hero(
                tag: memory.id,
                child: PhotoView(
                  imageProvider: NetworkImage(memory.mediaUrl),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
              );
            } else if (memory.type == MemoryType.video) {
              return _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                  ? Hero(
                      tag: memory.id,
                      child: Chewie(
                        controller: _chewieController!,
                      ),
                    )
                  : const CircularProgressIndicator();
            }
            return const Text('Unsupported media type');
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }
}


