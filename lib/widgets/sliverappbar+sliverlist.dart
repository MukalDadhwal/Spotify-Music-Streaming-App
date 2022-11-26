import 'package:flutter/material.dart';

import '../models/music_model.dart';
import './music_player_web.dart';
import './music_player_mobile.dart';
import '../widgets/music_widget.dart';
import '../providers/audio_provider.dart';

class SliverSet extends StatefulWidget {
  final List<MusicObject> playlist;
  final Audio audioProvider;

  const SliverSet({
    @required this.playlist,
    @required this.audioProvider,
  });

  @override
  State<SliverSet> createState() => _SliverSetState();
}

class _SliverSetState extends State<SliverSet> {
  var _scrollController = ScrollController();

  void _showMusicPlayer(
    BuildContext context,
    List<MusicObject> songPlaylist,
    double screenHeight,
    double screenWidth,
  ) {
    if (screenWidth < 700) {
      showModalBottomSheet(
        context: context,
        clipBehavior: Clip.antiAlias,
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (_) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              child: MusicPlayerMobile(songPlayList: songPlaylist),
              onTap: () {},
              behavior: HitTestBehavior.opaque,
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        clipBehavior: Clip.antiAlias,
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.22,
        ),
        builder: (_) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              child: MusicPlayerWeb(songPlayList: songPlaylist),
              onTap: () {},
              behavior: HitTestBehavior.opaque,
            ),
          );
        },
      );
    }
  }

  Widget _buildTitle(BuildContext context, List<MusicObject> playlist,
      double height, bool shrinked) {
    final width = MediaQuery.of(context).size.width;
    // on device size greater than 700
    if (width > 700) {
      return shrinked
          ? Text(
              'Spotify Music',
              style: TextStyle(
                fontFamily: 'Raleway',
              ),
            )
          : Container(
              child: IconButton(
                icon: Icon(
                  Icons.play_circle_fill_sharp,
                  size: 30,
                ),
                onPressed: () =>
                    _showMusicPlayer(context, playlist, height, width),
                tooltip: 'Play',
              ),
            );
    }
    // device size less than or equal to 700
    return Text(
      'Spotify Music',
      style: TextStyle(fontFamily: 'Raleway'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final sizeLessThan700 = width <= 700.0;
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          titleSpacing: 0.0,
          expandedHeight: height * 0.35,
          pinned: true,
          flexibleSpace: LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              final paddingTop = MediaQuery.of(context).padding.top;
              final shrinked =
                  constraints.biggest.height == paddingTop + kToolbarHeight;
              return FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 45, bottom: 16),
                centerTitle: false,
                title: _buildTitle(context, widget.playlist, height, shrinked),
              );
            },
          ),
          actions: [
            sizeLessThan700
                ? IconButton(
                    onPressed: () => _showMusicPlayer(
                      context,
                      widget.playlist,
                      height,
                      width,
                    ),
                    icon: Icon(Icons.playlist_play_rounded),
                    iconSize: 30,
                  )
                : Container()
          ],
          leading: width <= 700
              ? IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                )
              : Container(
                  width: 0,
                  height: 0,
                ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final atLastIndex = widget.playlist.length - 1 == index;
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: atLastIndex ? Colors.white : Colors.grey.shade300,
                      width: 0.5,
                    ),
                  ),
                ),
                child: MusicWidget(
                  id: widget.playlist[index].id,
                  duration: widget.playlist[index].duration,
                  title: widget.playlist[index].title,
                  webAudioUrl: widget.playlist[index].audioUrl,
                  webimageUrl: widget.playlist[index].thumbNailUrl,
                  index: index,
                  audioProvider: widget.audioProvider,
                ),
              );
            },
            childCount: widget.playlist.length,
          ),
        )
      ],
    );
  }
}
