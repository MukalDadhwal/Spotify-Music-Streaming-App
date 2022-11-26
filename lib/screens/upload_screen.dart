import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../providers/audio_provider.dart';
import '../widgets/app_drawer.dart';

class UploadScreen extends StatefulWidget {
  static const routeName = '/upload-screen';
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File _file;
  Directory directory;
  Map<String, dynamic> _fileData = {};
  bool _isLoading = false;
  bool _isEnabled = true;
  TextEditingController _textController = TextEditingController();
  bool _implyLeading = true;

  Future<void> _downloadAndSaveVideo(String videoId) async {
    final YoutubeExplode youtube = YoutubeExplode();

    try {
      Directory applicationDocumentsDirectory =
          await getApplicationDocumentsDirectory();

      var video = await youtube.videos.get(videoId);

      String title = video.title;
      String fileName = video.id.toString();
      String thumbnailUrl = video.thumbnails.mediumResUrl;
      String author = video.author;
      int duration = video.duration.inSeconds;

      var streamManifest =
          await youtube.videos.streamsClient.getManifest(videoId);
      var audio = streamManifest.audioOnly.first;
      var audioStream = youtube.videos.streamsClient.get(audio);
      var file = File(
          '${applicationDocumentsDirectory.uri.toFilePath()}/$fileName.mp4');

      var output = file.openWrite(mode: FileMode.writeOnlyAppend);

      await for (final data in audioStream) {
        output.add(data);
      }
      await output.close();

      setState(() {
        _file = file;
        _fileData = {
          'id': fileName,
          'title': title,
          'duration': duration,
          'thumbnailUrl': thumbnailUrl,
          'author': author,
        };
      });
    } catch (_) {
      throw const HttpException('Something Went Wrong!');
    } finally {
      youtube.close();
    }
  }

  void showSnackBarMessage(ctx, String msg) {
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    SnackBar snackBar = SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 4),
    );
    ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
  }

  Widget _buildPlaceHolder() {
    setState(() => _implyLeading = false);
    return Container(
      height: 0,
      width: 0,
    );
  }

  Widget _returnAppDrawer() {
    setState(() => _implyLeading = true);
    return AppDrawer();
  }

  @override
  Widget build(BuildContext context) {
    Audio audioData = Provider.of<Audio>(context);
    double width = MediaQuery.of(context).size.width;
    String fileName = _file != null ? basename(_file.path) : 'No File Selected';
    return Scaffold(
      drawer: width <= 700 ? _returnAppDrawer() : _buildPlaceHolder(),
      appBar: AppBar(
        title: Text('Upload Video'),
        automaticallyImplyLeading: _implyLeading,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.2),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter youtube id of video',
                  hintStyle: TextStyle(fontFamily: 'Raleway'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                ),
                autofocus: true,
                enabled: _isEnabled,
                controller: _textController,
              ),
            ),
            SizedBox(height: 50),
            Text(
              'File selected: $fileName',
            ),
            SizedBox(height: 50),
            _isLoading == false
                ? ElevatedButton.icon(
                    icon: Icon(Icons.cloud_upload_outlined),
                    label: Text('Download video and upload file'),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(10.0),
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _isEnabled = false;
                        _isLoading = true;
                      });
                      await _downloadAndSaveVideo(_textController.text).onError(
                        (error, _) {
                          setState(() {
                            _isEnabled = true;
                            _isLoading = false;
                          });
                          showSnackBarMessage(context, error.message);
                          return Future.value(null);
                        },
                      );
                      await audioData
                          .uploadFile(
                        _file,
                        _fileData['id'],
                        _fileData['title'],
                        _fileData['thumbnailUrl'],
                        _fileData['duration'],
                        _fileData['author'],
                      )
                          .onError(
                        (httpError, _) async {
                          setState(() {
                            _isEnabled = true;
                            _isLoading = false;
                          });
                          await _file.delete();
                          showSnackBarMessage(context, httpError.message);
                          return Future.value(null);
                        },
                      );

                      await _file.delete();
                      showSnackBarMessage(
                        context,
                        'Successfully uploaded the video!',
                      );
                      setState(() {
                        _isLoading = false;
                        _isEnabled = true;
                      });
                    },
                  )
                : ElevatedButton(
                    child: _file == null
                        ? FadingText('Downloading...')
                        : FadingText('Uploading...'),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(10.0),
                    ),
                    onPressed: () {},
                  ),
          ],
        ),
      ),
    );
  }
}
