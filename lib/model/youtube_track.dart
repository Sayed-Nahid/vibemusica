class YoutubeTrack {
  final String id;
  final String title;
  final String artist;
  const YoutubeTrack({
    required this.id,
    required this.title,
    required this.artist,
  });
  String get artwork => 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
}
