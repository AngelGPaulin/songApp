import 'package:flutter/material.dart';
import '../services/lastfm_service.dart';
import '../models/song_model.dart';
import '../widgets/song_tile.dart';
import 'song_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lastfm = LastFmService();

    return Scaffold(
      appBar: AppBar(title: const Text('Top Canciones')),
      body: FutureBuilder<List<SongModel>>(
        future: lastfm.fetchTopSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar canciones.'));
          }

          final songs = snapshot.data!;
          if (songs.isEmpty) {
            return const Center(child: Text('No hay canciones disponibles.'));
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SongPage(song: song)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
