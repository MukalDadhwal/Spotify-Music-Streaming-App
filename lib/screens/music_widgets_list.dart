import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:spotify/widgets/sliverappbar+sliverlist.dart';

import '../providers/audio_provider.dart';
import '../models/music_model.dart';
import '../widgets/app_drawer.dart';

class MusicList extends StatefulWidget {
  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  @override
  Widget build(BuildContext context) {
    final audioData = Provider.of<Audio>(context, listen: false);
    return FutureBuilder(
      future: audioData.fetchAndSetMusic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: JumpingText(
              'Loading...',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          if (snapshot.error != null) {
            return Container(
              child: Center(
                child: Text('Error Occured While Fetching the data!'),
              ),
            );
          } else {
            List<MusicObject> list = audioData.getMusicObjects;
            final width = MediaQuery.of(context).size.width;
            final sizeLessThan700 = width <= 700.0;
            return (sizeLessThan700)
                ? SliverSet(
                    playlist: list,
                    audioProvider: audioData,
                  )
                : SideMenu(
                    playlist: list,
                    audioProvider: audioData,
                  );
          }
        }
      },
    );
  }
}
