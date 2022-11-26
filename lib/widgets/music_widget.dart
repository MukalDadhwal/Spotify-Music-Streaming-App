import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/audio_provider.dart';

class MusicWidget extends StatefulWidget {
  final String id;
  final String title;
  final String webAudioUrl;
  final String webimageUrl;
  final int duration;
  final int index;
  final Audio audioProvider;

  MusicWidget({
    @required this.id,
    @required this.title,
    @required this.webAudioUrl,
    @required this.webimageUrl,
    @required this.duration,
    @required this.index,
    @required this.audioProvider,
  });

  @override
  State<MusicWidget> createState() => _MusicWidgetState();
}

class _MusicWidgetState extends State<MusicWidget> {
  void showSnackBarMessage(ctx, String msg) {
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    SnackBar snackBar = SnackBar(
      content: Text(msg),
    );
    ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
  }

  Future<void> _confirmDeletion(BuildContext ctx, Audio audioData) async {
    await showDialog(
      context: ctx,
      builder: (context) {
        return AlertDialog(
          actions: [
            OutlinedButton(
              onPressed: () async {
                try {
                  await audioData.removeFileFromDatabase(widget.webAudioUrl);
                  showSnackBarMessage(context, 'File Removed Successfully');
                  await Navigator.of(context).pushReplacementNamed('/');
                } catch (error) {
                  showSnackBarMessage(context, 'Something went wrong...');
                } finally {
                  Navigator.of(context).pop();
                }
              },
              child: Text('yes'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('no'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          title: Text('Confirm Deletion'),
          content: Text(
            'The file will be permanently deleted from the database. Are you sure you want to remove it?',
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton(double width, BuildContext context) {
    if (width > 700) {
      return OutlinedButton.icon(
        onPressed: () async {
          await _confirmDeletion(context, widget.audioProvider);
        },
        icon: Icon(
          Icons.delete_rounded,
          color: Colors.red,
        ),
        label: Text('Delete'),
      );
    }
    return IconButton(
      icon: Icon(Icons.delete_rounded, color: Colors.red),
      onPressed: () async {
        await _confirmDeletion(context, widget.audioProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListTile(
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 15,
        ),
        overflow: TextOverflow.fade,
        softWrap: true,
        maxLines: 2,
      ),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Text(
              '${widget.index + 1}',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Ralway',
              ),
            ),
          ),
          SizedBox(width: 10),
          Image(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            image: NetworkImage(
              widget.webimageUrl,
            ),
            loadingBuilder:
                (BuildContext context, Widget image, ImageChunkEvent event) {
              if (event == null) {
                return image;
              }
              return Shimmer.fromColors(
                child: Container(
                  color: Colors.grey,
                  width: width > 700 ? width * 0.10 : width * 0.20,
                  height: height * 0.10,
                ),
                baseColor: Colors.grey,
                highlightColor: Colors.white,
              );
            },
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Chip(
            label: Text('${(widget.duration / 60).toStringAsFixed(1)} min'),
            elevation: 4.0,
          ),
          _buildDeleteButton(width, context),
        ],
      ),
    );
  }
}
