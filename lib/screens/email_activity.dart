import 'package:flutter/material.dart';

class EmailACtivity extends StatefulWidget {
  const EmailACtivity({Key? key}) : super(key: key);

  @override
  State<EmailACtivity> createState() => _EmailACtivityState();
}

class _EmailACtivityState extends State<EmailACtivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email verify'),
      ),
      body: Column(
        children: [
          Container(
            height: 55,
            margin: EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter registered e-mail',
                border: OutlineInputBorder()
              ),
            ),
          ),
          RaisedButton(
              onPressed: (){

              },
              child: Text('Verify'),
          )
        ],
      ),
    );
  }
}
