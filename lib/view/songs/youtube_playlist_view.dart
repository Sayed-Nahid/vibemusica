import '../../common/youtube_playlist_reader.dart';
import '../../common/youtube_download_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/youtube_track.dart';
import '../../view_model/main_player_view_model.dart';
import '../../view_model/youtube_playlists_view_model.dart';
import '../player/main_player_view.dart';

class YoutubePlaylistView extends StatefulWidget {
  final Map<String, String> playlist;
  final bool downloadOnOpen;
  const YoutubePlaylistView({
    super.key,
    required this.playlist,
    this.downloadOnOpen = false,
  });
  @override
  State<YoutubePlaylistView> createState() => _YoutubePlaylistViewState();
}

class _YoutubePlaylistViewState extends State<YoutubePlaylistView> {
  late Future<List<YoutubeTrack>> _tracks;
  final downloads = Get.isRegistered<YoutubeDownloadService>()
      ? Get.find<YoutubeDownloadService>()
      : Get.put(YoutubeDownloadService(), permanent: true);

  @override
  void initState() {
    super.initState();
    _tracks = _load(autoDownload: widget.downloadOnOpen);
  }

  Future<List<YoutubeTrack>> _load({
    bool refresh = false,
    bool autoDownload = false,
  }) async {
    await downloads.ready;
    final tracks = await Get.find<YoutubePlaylistsViewModel>().tracks(
      widget.playlist['id']!,
      refresh: refresh,
    );
    if (autoDownload && mounted) downloads.downloadAll(tracks);
    return tracks;
  }

  void _reload() => setState(() {
    _tracks = _load(refresh: true);
  });

  Future<void> _play(List<YoutubeTrack> tracks, String id) async {
    final saved = await downloads.downloaded(tracks);
    final index = saved.indexWhere((t) => t.id == id);
    if (!mounted) return;
    if (index < 0) {
      Get.snackbar(
        'Download required',
        'Download this track before playing it.',
      );
      return;
    }
    Get.find<MainPlayerViewModel>().playDownloadedYoutube(saved, index);
    Get.to(() => const MainPlayerView());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff181322),
    appBar: AppBar(
      title: Text(widget.playlist['title']!),
      actions: [
        IconButton(
          tooltip: 'Refresh playlist from YouTube',
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<List<YoutubeTrack>>(
      future: _tracks,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: _reload,
              child: Text(
                snapshot.error is YoutubePlaylistLoadException
                    ? '${snapshot.error} Tap to retry.'
                    : 'Could not load playlist. Tap to retry.',
              ),
            ),
          );
        }
        final tracks = snapshot.data ?? [];
        if (tracks.isEmpty) {
          return const Center(child: Text('No available tracks.'));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Obx(() {
                final count = tracks
                    .where((t) => downloads.files.containsKey(t.id))
                    .length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$count / ${tracks.length} downloaded'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              downloads.busy.value || count == tracks.length
                              ? null
                              : () => downloads.downloadAll(tracks),
                          icon: const Icon(Icons.download),
                          label: Text(
                            count == 0 ? 'Download all' : 'Download missing',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: count == 0
                              ? null
                              : () => _play(
                                  tracks,
                                  tracks
                                      .firstWhere(
                                        (t) =>
                                            downloads.files.containsKey(t.id),
                                      )
                                      .id,
                                ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play downloaded'),
                        ),
                        if (downloads.busy.value)
                          TextButton(
                            onPressed: downloads.cancel,
                            child: const Text('Cancel download'),
                          ),
                      ],
                    ),
                    if (downloads.busy.value) ...[
                      Text(
                        downloads.total.value == 0
                            ? 'Preparing downloads…'
                            : 'Downloading ${downloads.finished.value + 1} of ${downloads.total.value} • ${(downloads.progress.value * 100).round()}%',
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: downloads.progress.value),
                      const Text(
                        'Keep the app open until downloads finish.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                    if (downloads.summary.value.isNotEmpty)
                      Text(
                        downloads.summary.value,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                );
              }),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, i) => Obx(() {
                  final track = tracks[i];
                  final saved = downloads.files.containsKey(track.id);
                  final active = downloads.activeId.value == track.id;
                  final error = downloads.errors[track.id];
                  return ListTile(
                    leading: Icon(
                      saved ? Icons.offline_pin : Icons.music_note,
                      color: saved ? Colors.greenAccent : Colors.white70,
                    ),
                    title: Text(
                      track.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      active
                          ? 'Downloading ${(downloads.progress.value * 100).round()}%'
                          : error ??
                                '${track.artist} • ${saved ? "Saved offline" : "Not downloaded"}',
                      style: TextStyle(
                        color: error == null
                            ? Colors.white70
                            : Colors.orangeAccent,
                      ),
                    ),
                    trailing: saved
                        ? PopupMenuButton<String>(
                            enabled: !downloads.busy.value,
                            onSelected: (_) async {
                              final player = Get.find<MainPlayerViewModel>();
                              // Release the native file queue before deleting a file it uses.
                              await player.releaseDownloadedTrack(track.id);
                              await downloads.remove(track.id);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'remove',
                                child: Text('Remove download'),
                              ),
                            ],
                          )
                        : IconButton(
                            tooltip: 'Download track',
                            onPressed: downloads.busy.value
                                ? null
                                : () => downloads.downloadAll([track]),
                            icon: Icon(
                              active ? Icons.hourglass_top : Icons.download,
                            ),
                          ),
                    onTap: saved
                        ? () => _play(tracks, track.id)
                        : downloads.busy.value
                        ? null
                        : () => downloads.downloadAll([track]),
                  );
                }),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> showYoutubePlaylistImport(
  BuildContext context,
  YoutubePlaylistsViewModel vm,
) async {
  final input = TextEditingController();
  vm.error.value = '';
  Map<String, String>? imported;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Add YouTube playlist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: input,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Paste a playlist link',
            ),
            keyboardType: TextInputType.url,
          ),
          Obx(
            () => vm.error.value.isEmpty
                ? const SizedBox.shrink()
                : Text(vm.error.value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        Obx(
          () => TextButton(
            onPressed: vm.busy.value
                ? null
                : () async {
                    final added = await vm.add(input.text);
                    if (added && dialogContext.mounted) {
                      final id = Uri.tryParse(
                        input.text.trim(),
                      )?.queryParameters['list'];
                      imported = vm.playlists.firstWhereOrNull(
                        (p) => p['id'] == id,
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
            child: Text(vm.busy.value ? 'Importing…' : 'Add & download'),
          ),
        ),
      ],
    ),
  );
  // The dialog's route may still be animating out when its future completes.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  input.dispose();
  if (imported != null && context.mounted) {
    Get.to(
      () => YoutubePlaylistView(playlist: imported!, downloadOnOpen: true),
    );
  }
}
