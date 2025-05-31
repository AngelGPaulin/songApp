import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song_model.dart';
import '../secrets/constants.dart';

class LastFmService {
  final String _apiKey = lastFmApiKey;

  Future<List<SongModel>> fetchTopSongs() async {
    final url =
        'https://ws.audioscrobbler.com/2.0/?method=chart.gettoptracks&api_key=$_apiKey&format=json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener canciones');
    }

    final data = jsonDecode(response.body);
    final tracks = data['tracks']['track'] as List;

    List<SongModel> songs = [];

    for (final track in tracks) {
      final title = track['name'];
      final artist = track['artist']['name'];

      final iTunesData = await _fetchiTunesData(title, artist);

      songs.add(
        SongModel(
          title: title,
          artist: artist,
          albumCover: iTunesData['cover'] ?? '',
          previewUrl: iTunesData['preview'] ?? '',
        ),
      );
    }

    return songs;
  }

  Future<Map<String, String>> _fetchiTunesData(
    String title,
    String artist,
  ) async {
    final query = Uri.encodeComponent('$title $artist');
    final url =
        'https://itunes.apple.com/search?term=$query&entity=song&limit=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['resultCount'] > 0) {
        final result = data['results'][0];
        return {
          'cover': result['artworkUrl100'] ?? '',
          'preview': result['previewUrl'] ?? '',
        };
      }
    }

    return {'cover': '', 'preview': ''};
  }
}
