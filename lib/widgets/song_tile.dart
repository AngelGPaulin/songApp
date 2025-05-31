import 'package:flutter/material.dart';
import '../models/song_model.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const SongTile({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading:
          song.albumCover.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.albumCover,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
              : const Icon(Icons.music_note, size: 40),
      title: Text(
        song.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(song.artist),
      onTap: onTap,
    );
  }
}
