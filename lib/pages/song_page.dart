import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../secrets/constants.dart';

class SongPage extends StatefulWidget {
  final SongModel song;

  const SongPage({super.key, required this.song});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  String _artistBio = '';
  bool _loading = true;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _fetchArtistBio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _fetchArtistBio() async {
    final artist = Uri.encodeComponent(widget.song.artist);
    final url =
        'https://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=$artist&api_key=$lastFmApiKey&format=json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary = data['artist']['bio']['summary'] ?? '';
        setState(() {
          _artistBio = summary;
          _loading = false;
        });
      } else {
        setState(() {
          _artistBio = 'No se pudo obtener la biografía.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _artistBio = 'Error al cargar información.';
        _loading = false;
      });
    }
  }

  void _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(widget.song.previewUrl));
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;

    return Scaffold(
      appBar: AppBar(title: Text(song.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (song.albumCover.isNotEmpty)
              Image.network(song.albumCover, height: 200),
            const SizedBox(height: 16),
            Text(
              song.artist,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (song.previewUrl.isNotEmpty)
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 48,
                onPressed: _togglePlayback,
              ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : Text(_artistBio, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
