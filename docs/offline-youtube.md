# Offline YouTube playlists

In Songs → Playlists, tap +, paste a public or unlisted playlist link, and choose
**Add & download**. Existing playlists have **Download all / Download missing**.
Keep the app open during downloading. Downloads continue when navigating between
app screens, but are not scheduled background jobs and do not survive process
termination. Completed files survive restarts; partial files are discarded.

Downloaded tracks play from local files. **Play downloaded** queues only files
that are present, in playlist order. The native audio queue supplies playback,
seeking, and next/previous controls. Playlist titles and track metadata are cached
for offline browsing. Artwork may still require a connection; it has a fallback.
Use **Refresh** to fetch playlist changes from YouTube.

Audio is saved as M4A (preferred) or WebM, without transcoding. Files live under
`youtube_audio` in application support storage, not the public device Music
folder. They are shared by video ID across imported playlists. **Remove download**
deletes that track's local file for all playlists and stops an active downloaded
queue containing it. Removing a saved playlist does not delete its audio files.
Uninstalling the app removes its private downloads.

## Implementation

- `YoutubePlaylistsViewModel`: saved links and offline track metadata.
- `YoutubeDownloadService`: sequential queue, progress, cancellation, availability,
  and per-track retry. Already downloaded files are skipped.
- `YoutubeDownloadPlugin` / `NativeYoutubeDownloader`: Android yt-dlp runtime,
  bundled Python/QuickJS/FFmpeg, extractor updates, progress events, cancellation,
  temporary files, and native audio validation before publishing completed files.
- `AudioFileDownloader`: direct Dart transfer fallback for non-Android targets.
- `MainPlayerViewModel.playDownloadedYoutube`: local-file audio queue.

Android uses yt-dlp on the device and needs no backend or separate user-installed
runtime. This increases the APK size. The extractor checks for an update on its
first use in a process; temporary update failures use the bundled version.
Downloading still depends on YouTube exposing downloadable audio. Private,
restricted, deleted, or blocked tracks may fail; errors are reported per track,
and incomplete files never become playable.

## Verification

Run:

```sh
flutter test --no-pub test/audio_file_downloader_test.dart test/youtube_download_service_test.dart test/youtube_playlists_test.dart test/youtube_playlist_reader_test.dart
```

The opt-in Android device test downloads the first two tracks, reloads the saved
file index, and verifies local playback and next-track behavior:

```sh
flutter test integration_test/offline_youtube_test.dart -d DEVICE_ID --dart-define=YOUTUBE_TEST_PLAYLIST=PLAYLIST_ID
```

Restore the normal app after a device test with `flutter build apk --debug` and
`adb -s DEVICE_ID install -r build/app/outputs/flutter-apk/app-debug.apk`.

On a device: import a playlist, download tracks, cancel midway, retry missing
tracks, restart in airplane mode, open the playlist, play/seek/skip downloaded
tracks, then remove a downloaded file. Check that incomplete tracks never show
as downloaded. Live YouTube extraction is not covered by the automated tests.
