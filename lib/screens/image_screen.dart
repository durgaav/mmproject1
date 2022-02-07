import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  String screenshot;

  ImageScreen({required this.screenshot});

  @override
  _ImageScreenState createState() => _ImageScreenState(screenshot: screenshot);
}

class _ImageScreenState extends State<ImageScreen> {
  String screenshot;
  _ImageScreenState({required this.screenshot});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text('Image viewer'),
          leading: IconButton(
            icon: Icon(Icons.close),
            color: Colors.white,
            iconSize: 36,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Image(
            image: NetworkImage('$screenshot'),
          ),
        ),
    ),
    );
  }
}
