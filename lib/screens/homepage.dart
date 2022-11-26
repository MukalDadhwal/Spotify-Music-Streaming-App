import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../screens/music_widgets_list.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: width <= 700
          ? AppDrawer()
          : Container(
              height: 0,
              width: 0,
            ),
      body: MusicList(),
      drawerEnableOpenDragGesture: false,
    );
  }
}
