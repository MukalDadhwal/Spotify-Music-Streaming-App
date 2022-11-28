import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/music_model.dart';
import '../models/http_exception.dart';

class Audio with ChangeNotifier {
  List<MusicObject> musicObjects = [];

  List<MusicObject> get getMusicObjects {
    return [...musicObjects];
  }

  Future<void> fetchAndSetMusic() async {
    String path = 'files/';

    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();
    List<Reference> refs = result.items;

    var metadata =
        await Future.wait(refs.map((ref) => ref.getMetadata()).toList());
    final List<MusicObject> loadedMusicObjects = [];

    await Future.forEach(
      metadata,
      (item) async {
        String downloadUrl = await FirebaseStorage.instance
            .ref(
              'files/${item.customMetadata['id']}.mp4',
            )
            .getDownloadURL();
        loadedMusicObjects.add(
          MusicObject(
            id: item.customMetadata['id'],
            title: item.customMetadata['title'],
            duration: int.parse(
              item.customMetadata['duration'],
            ),
            thumbNailUrl: item.customMetadata['thumbnailUrl'],
            author: item.customMetadata['author'],
            audioUrl: downloadUrl,
          ),
        );
      },
    );

    musicObjects = loadedMusicObjects;
    notifyListeners();
  }

  Future<void> uploadFile(File file, String id, String title,
      String thumbnailUrl, int duration, String videoAuthor) async {
    try {
      if (await file.exists()) {
        final fileName = basename(file.path);
        final SettableMetadata metadata = SettableMetadata(
          customMetadata: <String, String>{
            'id': id,
            'title': title,
            'thumbnailUrl': thumbnailUrl,
            'duration': duration.toString(),
            'author': videoAuthor,
          },
        );
        final storageReff =
            FirebaseStorage.instance.ref().child('files/$fileName');

        storageReff.putFile(file, metadata);
      }
    } catch (_) {
      throw HttpException('Something went wrong file uploading to the server');
    }
    notifyListeners();
  }

  Future<void> removeFileFromDatabase(String url) async {
    try {
      final reff = FirebaseStorage.instance.refFromURL(url);
      await reff.delete();
    } catch (_) {
      throw HttpException('Error Deleting the File');
    }
    notifyListeners();
  }
}
