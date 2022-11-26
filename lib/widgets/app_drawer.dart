import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';

import '../screens/upload_screen.dart';
import './sliverappbar+sliverlist.dart';
import '../providers/audio_provider.dart';
import '../models/music_model.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Drawer(
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.only(
              left: 10,
              bottom: 10,
            ),
            child: Text(
              'Listen Up!',
              style: Theme.of(context).textTheme.headline2,
            ),
            height: height * 0.39,
            width: double.infinity,
            color: Colors.cyan,
          ),
          ListTile(
            title: Text(
              'Home',
              style: TextStyle(fontFamily: "Raleway"),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          kIsWeb
              ? SizedBox.shrink()
              : ListTile(
                  title: Text(
                    'Add Song',
                    style: TextStyle(fontFamily: "Raleway"),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(UploadScreen.routeName);
                  },
                ),
        ],
      ),
    );
  }
}

class SideMenu extends StatefulWidget {
  final List<MusicObject> playlist;
  final Audio audioProvider;

  const SideMenu({@required this.playlist, @required this.audioProvider});

  @override
  State<SideMenu> createState() => _NavBarState();
}

class _NavBarState extends State<SideMenu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SideNavigationBar(
          theme: SideNavigationBarTheme(
            backgroundColor: Colors.white,
            dividerTheme: SideNavigationBarDividerTheme.standard(),
            itemTheme: SideNavigationBarItemTheme(
              labelTextStyle: TextStyle(fontFamily: 'Raleway'),
            ),
            togglerTheme: SideNavigationBarTogglerTheme.standard(),
          ),
          header: SideNavigationBarHeader(
            title: Container(
              child: Text(
                'Spotify Music',
                style: Theme.of(context).textTheme.headline1,
              ),
              alignment: Alignment.bottomCenter,
            ),
            subtitle: Text(
              '',
            ),
            image: Container(),
          ),
          selectedIndex: _selectedIndex,
          items: const [
            SideNavigationBarItem(icon: Icons.home, label: 'Home'),
            SideNavigationBarItem(icon: Icons.upload, label: 'Add Song'),
          ],
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
        Expanded(
          child: _selectedIndex == 0
              ? SliverSet(
                  playlist: widget.playlist,
                  audioProvider: widget.audioProvider,
                )
              : UploadScreen(),
        ),
      ],
    );
  }
}
