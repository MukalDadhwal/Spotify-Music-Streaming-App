import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import './providers/audio_provider.dart';
import './screens/upload_screen.dart';
import './screens/homepage.dart';
import './firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      textTheme: ThemeData.light().textTheme.copyWith(
            headline2: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w900,
              color: Colors.amber,
              fontFamily: 'Raleway',
            ),
            headline1: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w700,
              fontFamily: 'Raleway',
            ),
            headline4: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Raleway',
            ),
          ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Audio>(
          create: (_) => Audio(),
        ),
      ],
      child: MaterialApp(
        title: 'Media Player',
        theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: Colors.cyan,
          ),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (ctx) => MyHomePage(),
          UploadScreen.routeName: (ctx) => UploadScreen(),
        },
      ),
    );
  }
}
