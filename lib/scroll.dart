import 'dart:core';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_performance/firebase_performance.dart';

class Scroll extends StatefulWidget {
  const Scroll({Key? key}) : super(key: key);

  @override
  _ScrollState createState() => _ScrollState();
}

class Fire {
  static late FirebaseStorage storage;
  static late ListResult listOImageNames;
  static late FirebasePerformance performance;
  static late Trace trace;
  static late String sliding;

  static Future<String> doWhileStartingUp(String folder) async {
    await Firebase.initializeApp();
    storage = FirebaseStorage.instance;
    performance = FirebasePerformance.instance;
    sliding = folder;
    trace = performance.newTrace("Trace: " + folder);
    listOImageNames = await storage.ref(folder).listAll();
    return "Done";
  }

  static Future<List<ImageR>> getImages(int start, int limit) async {
    List<ImageR> list = [];
    trace.start();
    for (int i = start; i < limit; i++) {
      final String imageUrl = await Fire.storage
          .ref(Fire.listOImageNames.items[i].fullPath)
          .getDownloadURL();
      list.add(ImageR(imageUrl));
    }
    trace.stop();
    return list;
  }
}

class _ScrollState extends State<Scroll> {
  late final Future<String> appReady = Fire.doWhileStartingUp("632kb/");
  late String _sliding = Fire.sliding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: appReady,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    "Something went wrong:\n${snapshot.error.toString()}"));
          } else if (snapshot.hasData) {
            return Column(
              children: [
                // CupertinoSlidingSegmentedControl(
                //   children: const {
                //     "632kb/": Text('632kb/'),
                //     "1038kb/": Text("1038kb/"),
                //     "1450kb/": Text('1450kb/'),
                //     "1926kb/": Text('1926kb/'),
                //     "2470kb/": Text("2470kb/"),
                //   },
                //   groupValue: _sliding,
                //   onValueChanged: (value) async {
                //     await Fire.doWhileStartingUp(value as String);
                //     setState(() {
                //       _sliding = value;
                //     });
                //   },
                // ),
                Expanded(child: PagewiseListViewExample(key: UniqueKey())),
              ],
            );
          } else {
            return const Center(
                child: CupertinoActivityIndicator(
              radius: 20,
            ));
          }
        },
      ),
    );
  }
}

class ImageR {
  late String url;
  ImageR(this.url);
}

class PagewiseListViewExample extends StatefulWidget {
  static const int PAGE_SIZE = 4;

  const PagewiseListViewExample({Key? key}) : super(key: key);

  @override
  State<PagewiseListViewExample> createState() =>
      _PagewiseListViewExampleState();
}

class _PagewiseListViewExampleState extends State<PagewiseListViewExample> {
  @override
  Widget build(BuildContext context) {
    print(Fire.sliding);
    return Scrollbar(
      child: PagewiseListView<ImageR>(
        loadingBuilder: (context) {
          return const CupertinoActivityIndicator();
        },
        retryBuilder: (context, callback) {
          return Container();
        },
        pageSize: PagewiseListViewExample.PAGE_SIZE,
        itemBuilder: _itemBuilder,
        pageFuture: (pageIndex) => Fire.getImages(
            pageIndex! * PagewiseListViewExample.PAGE_SIZE,
            pageIndex * PagewiseListViewExample.PAGE_SIZE +
                PagewiseListViewExample.PAGE_SIZE),
      ),
    );
  }

  Widget _itemBuilder(context, ImageR entry, _) {
    return SizedBox(
      height: 281,
      child: Image.network(entry.url),
    );
  }
}
