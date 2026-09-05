import '../../common/youtube_playlist_reader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/youtube_track.dart';
import '../../view_model/main_player_view_model.dart';
import '../../view_model/youtube_playlists_view_model.dart';
import '../player/main_player_view.dart';

class YoutubePlaylistView extends StatefulWidget {
  final Map<String, String> playlist;
  const YoutubePlaylistView({super.key, required this.playlist});
  @override
  State<YoutubePlaylistView> createState() => _YoutubePlaylistViewState();
}

class _YoutubePlaylistViewState extends State<YoutubePlaylistView> {
  late Future<List<YoutubeTrack>> _tracks;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _tracks = Get.find<YoutubePlaylistsViewModel>().tracks(
      widget.playlist['id']!,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff181322),
    appBar: AppBar(
      title: Text(widget.playlist['title']!),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => setState(_reload),
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
              onPressed: () => setState(_reload),
              child: Text(
                snapshot.error is YoutubePlaylistLoadException
                    ? '${snapshot.error} Tap to retry.'
                    : 'Could not load playlist tracks from YouTube. Tap to retry.',
              ),
            ),
          );
        }
        final tracks = snapshot.data ?? [];
        if (tracks.isEmpty) {
          return const Center(
            child: Text(
              'No available tracks.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (context, i) => ListTile(
            leading: Image.network(
              tracks[i].artwork,
              width: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stack) =>
                  const Icon(Icons.music_note, color: Colors.white),
            ),
            title: Text(
              tracks[i].title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              tracks[i].artist,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.play_arrow, color: Colors.white),
            onTap: () {
              Get.find<MainPlayerViewModel>().playYoutube(tracks, i);
              Get.to(() => const MainPlayerView());
            },
          ),
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
                      Navigator.pop(dialogContext);
                    }
                  },
            child: Text(vm.busy.value ? 'Importing…' : 'Add'),
          ),
        ),
      ],
    ),
  );
  // The dialog's route may still be animating out when its future completes.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  input.dispose();
}
