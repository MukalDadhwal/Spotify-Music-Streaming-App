import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../models/music_model.dart';

class MusicPlayerWeb extends StatefulWidget {
  final List<MusicObject> songPlayList;

  const MusicPlayerWeb({@required this.songPlayList});

  @override
  State<MusicPlayerWeb> createState() => _MusicPlayerWebState();
}

class _MusicPlayerWebState extends State<MusicPlayerWeb> {
  Playlist _playlist;
  AssetsAudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _setPlayList();
    _player = AssetsAudioPlayer();
  }

  @override
  void dispose() async {
    super.dispose();
    await _player.stop();
    await _player.dispose();
  }

  Future<void> _startPlayer() async {
    await _player.open(
      _playlist,
      showNotification: true,
      autoStart: true,
    );
    await _player.setLoopMode(LoopMode.playlist);
  }

  void _setPlayList() {
    List<Audio> _songPlaylist = widget.songPlayList
        .map(
          (element) => Audio.network(
            element.audioUrl,
            metas: Metas(
              artist: element.author,
              title: element.title,
              id: element.id,
              image: MetasImage.network(element.thumbNailUrl),
              onImageLoadFail: MetasImage.asset('assets/images/music_icon.png'),
            ),
          ),
        )
        .toList();
    _playlist = Playlist(audios: _songPlaylist);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _startPlayer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.error != null) {
          return Center(child: Text('An unexpected error has occurred'));
        } else {
          return PlayerBody(player: _player);
        }
      },
    );
  }
}

class PlayerBody extends StatefulWidget {
  final AssetsAudioPlayer player;

  PlayerBody({@required this.player});

  @override
  State<PlayerBody> createState() => _PlayerBodyState();
}

class _PlayerBodyState extends State<PlayerBody> {
  void showSnackBarMessage(ctx, String msg) {
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    SnackBar snackBar = SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.black.withOpacity(0.7),
      width: 200,
    );
    ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
  }

  String returnMinAndSecondFormat(int time) {
    List<String> arr = (time / 60).toStringAsFixed(1).split('.');
    String integerPartOfDuration = arr[0];
    String fractionalPartOfDuration = ':' + arr[1] + '0';
    return '$integerPartOfDuration$fractionalPartOfDuration';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlayerBuilder.current(
                    player: widget.player,
                    builder: (context, playing) {
                      if (playing != null) {
                        var audioMetaData = playing.audio.audio.metas;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              audioMetaData.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(fontSize: 17),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              maxLines: 1,
                            ),
                            Text(
                              audioMetaData.artist,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                  PlayerBuilder.currentPosition(
                    player: widget.player,
                    builder: (context, currentDuration) {
                      if (currentDuration != null &&
                          widget.player.current.hasValue) {
                        return Container(
                          width: 600,
                          child: NeumorphicSlider(
                            height: 12,
                            min: 0,
                            max: double.parse(widget
                                .player.current.value.audio.duration.inSeconds
                                .toString()),
                            value: double.parse(
                                currentDuration.inSeconds.toString()),
                            onChanged: (value) {
                              widget.player.seek(
                                Duration(
                                  seconds: int.parse(
                                    value.toStringAsFixed(0),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  PlayerBuilder.realtimePlayingInfos(
                    player: widget.player,
                    builder: (context, info) {
                      if (info != null) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('0:00'),
                            Container(
                              width: 550,
                            ),
                            Text(
                              returnMinAndSecondFormat(
                                info.duration.inSeconds,
                              ),
                            ),
                          ],
                        );
                      }
                      return Text('0:00');
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.shuffle_rounded),
                            iconSize: 20,
                            color: widget.player.isShuffling.value
                                ? Colors.amber
                                : Colors.black,
                            onPressed: () {
                              setState(() => widget.player.toggleShuffle());
                              String msg = widget.player.isShuffling.value
                                  ? 'shuffle is on!'
                                  : 'shuffle is off!';
                              showSnackBarMessage(context, msg);
                            },
                            tooltip: 'shuffle',
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_previous_rounded),
                            iconSize: 35,
                            onPressed: () async {
                              await widget.player.previous();
                            },
                            tooltip: 'play previous',
                          ),
                          PlayerBuilder.currentPosition(
                            player: widget.player,
                            builder: (context, currentDuration) {
                              if (currentDuration != null) {
                                return IconButton(
                                  icon: Icon(Icons.fast_rewind_rounded),
                                  iconSize: 35,
                                  onPressed: () async {
                                    await widget.player.seek(
                                      Duration(
                                        seconds:
                                            (currentDuration.inSeconds - 10),
                                      ),
                                    );
                                  },
                                  tooltip: 'fast rewind',
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                          PlayerBuilder.isPlaying(
                            player: widget.player,
                            builder: (context, isPlaying) {
                              if (isPlaying != null) {
                                return isPlaying
                                    ? IconButton(
                                        icon: Icon(
                                            Icons.pause_circle_filled_rounded),
                                        onPressed: () async {
                                          await widget.player.pause();
                                        },
                                        iconSize: 35,
                                        tooltip: 'pause',
                                      )
                                    : IconButton(
                                        icon: Icon(
                                            Icons.play_circle_filled_rounded),
                                        onPressed: () async {
                                          await widget.player.play();
                                        },
                                        iconSize: 35,
                                        tooltip: 'play',
                                      );
                              } else {
                                return Container();
                              }
                            },
                          ),
                          PlayerBuilder.currentPosition(
                            player: widget.player,
                            builder: (context, currentDuration) {
                              if (currentDuration != null) {
                                return IconButton(
                                  icon: Icon(Icons.fast_forward_rounded),
                                  iconSize: 35,
                                  onPressed: () async {
                                    await widget.player.seek(
                                      Duration(
                                        seconds:
                                            (currentDuration.inSeconds + 10),
                                      ),
                                    );
                                  },
                                  tooltip: 'fast forward',
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next_rounded),
                            iconSize: 35,
                            onPressed: () async {
                              await widget.player.next();
                            },
                            tooltip: 'play next',
                          ),
                          widget.player.loopMode.hasValue &&
                                  widget.player.isShuffling.hasValue
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      tooltip: 'loop',
                                      icon: Icon(Icons.loop_rounded),
                                      iconSize: 20,
                                      color: widget.player.loopMode.value ==
                                              LoopMode.playlist
                                          ? Colors.black
                                          : Colors.amber,
                                      onPressed: () {
                                        if (widget.player.loopMode.value ==
                                            LoopMode.playlist) {
                                          widget.player
                                              .setLoopMode(LoopMode.single);
                                          setState(() {});
                                          showSnackBarMessage(context,
                                              'The song is on repeat!');
                                        } else {
                                          widget.player
                                              .setLoopMode(LoopMode.playlist);
                                          setState(() {});
                                          showSnackBarMessage(
                                              context, 'repeat is off!');
                                        }
                                      },
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
