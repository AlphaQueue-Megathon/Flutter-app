import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stellantis/Introduction/introduction_animation_screen.dart';
import 'package:stellantis/Home/home.dart';
import 'package:stellantis/Map/MapPage.dart';

Future<void> main() async {
  // await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Avenir'),
    initialRoute: 'intro',
    routes: {
      'intro': (context) => const IntroductionAnimationScreen(),
      'home': (context) => const HomePage(),
      'routing': (context) => const MapPage(),
    },
  ));
}
