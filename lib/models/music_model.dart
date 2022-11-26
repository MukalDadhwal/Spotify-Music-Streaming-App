class MusicObject {
  String id;
  String audioUrl;
  String title;
  String thumbNailUrl;
  String author;
  int duration;

  MusicObject({
    this.id,
    this.title,
    this.thumbNailUrl,
    this.duration,
    this.author,
    this.audioUrl = '',
  });
}
