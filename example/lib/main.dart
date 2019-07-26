import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:kenburns/kenburns.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 300,
                child: KenBurns(
                  minAnimationDuration: Duration(milliseconds: 1000),
                  maxAnimationDuration: Duration(milliseconds: 3000),
                    child: Image.network("https://www.photo-paysage.com/?file=pic_download_link/picture&pid=3100", fit: BoxFit.cover,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
