import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islamic_library_flutter/data/models/playlist_model.dart';
import 'dart:convert';

class FavoritesNotifier extends Notifier<Map<String, List<dynamic>>> {
  @override
  Map<String, List<dynamic>> build() {
    _loadFavorites();
    return {'reciters': [], 'surahs': [], 'playlists': []};
  }

  final _box = Hive.box('favorites');

  void _loadFavorites() {
    final recitersJson = _box.get('reciters', defaultValue: '[]');
    final surahsJson = _box.get('surahs', defaultValue: '[]');
    final playlistsJson = _box.get('playlists', defaultValue: '[]');

    state = {
      'reciters': jsonDecode(recitersJson),
      'surahs': jsonDecode(surahsJson),
      'playlists': jsonDecode(playlistsJson),
    };
  }

  void toggleFavoriteReciter(dynamic reciter) {
    final list = List<dynamic>.from(state['reciters']!);
    final index = list.indexWhere((item) => item['id'] == reciter.id);

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add(reciter.toJson());
    }

    state = {...state, 'reciters': list};
    _box.put('reciters', jsonEncode(list));
  }

  void toggleFavoriteSurah(dynamic surah, dynamic reciter, {String? url}) {
    final list = List<dynamic>.from(state['surahs']!);
    final itemKey = '${surah.number}_${reciter.id}';
    final index = list.indexWhere(
      (item) => '${item['surah_number']}_${item['reciter_id']}' == itemKey,
    );

    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'surah_number': surah.number,
        'surah_name': surah.name,
        'reciter_id': reciter.id,
        'reciter_name': reciter.name,
        'url': url, // Save the URL
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }

    state = {...state, 'surahs': list};
    _box.put('surahs', jsonEncode(list));
  }

  bool isFavoriteReciter(String id) {
    return state['reciters']!.any((item) => item['id'].toString() == id);
  }

  bool isFavoriteSurah(int surahNumber, String reciterId) {
    final itemKey = '${surahNumber}_$reciterId';
    return state['surahs']!.any(
      (item) => '${item['surah_number']}_${item['reciter_id']}' == itemKey,
    );
  }

  // --- Playlist Methods ---

  void createPlaylist(String name, {String? icon}) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: icon ?? '⭐',
      items: [],
    );

    playlists.add(newPlaylist.toJson());
    state = {...state, 'playlists': playlists};
    _savePlaylists();
  }

  void deletePlaylist(String id) {
    final playlists = List<dynamic>.from(state['playlists']!);
    playlists.removeWhere((p) => p['id'] == id);
    state = {...state, 'playlists': playlists};
    _savePlaylists();
  }

  void updatePlaylist(Playlist updatedPlaylist) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final index = playlists.indexWhere((p) => p['id'] == updatedPlaylist.id);
    if (index >= 0) {
      playlists[index] = updatedPlaylist.toJson();
      state = {...state, 'playlists': playlists};
      _savePlaylists();
    }
  }

  void addToPlaylist(
    String playlistId,
    dynamic surah,
    dynamic reciter,
    String url,
  ) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final index = playlists.indexWhere((p) => p['id'] == playlistId);

    if (index >= 0) {
      final playlist = Playlist.fromJson(playlists[index]);
      final newItem = PlaylistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        surahNumber: surah.number,
        surahName: surah.name,
        reciterId: reciter.id,
        reciterName: reciter.name,
        url: url,
        order: playlist.items.length,
      );

      final updatedItems = [...playlist.items, newItem];
      playlists[index] = playlist.copyWith(items: updatedItems).toJson();
      state = {...state, 'playlists': playlists};
      _savePlaylists();
    }
  }

  void removeFromPlaylist(String playlistId, String itemId) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final pIndex = playlists.indexWhere((p) => p['id'] == playlistId);

    if (pIndex >= 0) {
      final playlist = Playlist.fromJson(playlists[pIndex]);
      final updatedItems = playlist.items.where((i) => i.id != itemId).toList();

      // Re-order remaining items
      for (int i = 0; i < updatedItems.length; i++) {
        updatedItems[i] = updatedItems[i].copyWith(order: i);
      }

      playlists[pIndex] = playlist.copyWith(items: updatedItems).toJson();
      state = {...state, 'playlists': playlists};
      _savePlaylists();
    }
  }

  void reorderPlaylistItems(String playlistId, int oldIndex, int newIndex) {
    final playlists = List<dynamic>.from(state['playlists']!);
    final pIndex = playlists.indexWhere((p) => p['id'] == playlistId);

    if (pIndex >= 0) {
      final playlist = Playlist.fromJson(playlists[pIndex]);
      final items = List<PlaylistItem>.from(playlist.items);

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      // Update order property
      for (int i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(order: i);
      }

      playlists[pIndex] = playlist.copyWith(items: items).toJson();
      state = {...state, 'playlists': playlists};
      _savePlaylists();
    }
  }

  void _savePlaylists() {
    _box.put('playlists', jsonEncode(state['playlists']));
  }

  String exportPlaylist(String id) {
    final playlists = state['playlists']!;
    final playlist = playlists.firstWhere((p) => p['id'] == id);
    return base64Encode(utf8.encode(jsonEncode(playlist)));
  }

  void importPlaylist(String base64Data) {
    try {
      final decoded = utf8.decode(base64Decode(base64Data));
      final Map<String, dynamic> json = jsonDecode(decoded);

      // Reset ID to avoid conflicts
      json['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      json['name'] = '${json['name']} (Imported)';

      final playlists = List<dynamic>.from(state['playlists']!);
      playlists.add(json);

      state = {...state, 'playlists': playlists};
      _savePlaylists();
    } catch (e) {
      debugPrint('Error importing playlist: $e');
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Map<String, List<dynamic>>>(() {
      return FavoritesNotifier();
    });
