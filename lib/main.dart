import 'package:flutter/material.dart';
import 'screens/watchlist_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const WatchlistScreen(),
    );
  }
}
