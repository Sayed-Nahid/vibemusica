class YoutubeTrack {
  final String id;
  final String title;
  final String artist;
  final String? localPath;
  const YoutubeTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.localPath,
  });
  String get artwork => 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
  YoutubeTrack withLocalPath(String path) =>
      YoutubeTrack(id: id, title: title, artist: artist, localPath: path);
  Map<String, String> toJson() => {'id': id, 'title': title, 'artist': artist};
  factory YoutubeTrack.fromJson(Map<String, dynamic> json) => YoutubeTrack(
    id: json['id'] as String,
    title: json['title'] as String,
    artist: json['artist'] as String,
  );
}
