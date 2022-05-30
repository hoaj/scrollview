import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scroll_v3/scroll.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: const Scroll(),
    );
  }
}
