import 'package:json_annotation/json_annotation.dart';

part 'playlist_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Playlist {
  final String id;
  final String name;
  final String? icon; // emoji or icon name
  final List<PlaylistItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    this.icon,
    List<PlaylistItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : items = items ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Playlist copyWith({
    String? name,
    String? icon,
    List<PlaylistItem>? items,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}

@JsonSerializable()
class PlaylistItem {
  final String id;
  final int surahNumber;
  final String surahName;
  final int reciterId;
  final String reciterName;
  final String url;
  final int order;

  PlaylistItem({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.reciterId,
    required this.reciterName,
    required this.url,
    required this.order,
  });

  PlaylistItem copyWith({int? order}) {
    return PlaylistItem(
      id: id,
      surahNumber: surahNumber,
      surahName: surahName,
      reciterId: reciterId,
      reciterName: reciterName,
      url: url,
      order: order ?? this.order,
    );
  }

  factory PlaylistItem.fromJson(Map<String, dynamic> json) =>
      _$PlaylistItemFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistItemToJson(this);
}
