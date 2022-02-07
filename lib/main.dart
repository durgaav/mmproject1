// @dart=2.9
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mmcustomerservice/screens/homepage.dart';
import 'package:mmcustomerservice/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}
//java is working
class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String loginStatus = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      var loginPref = await SharedPreferences.getInstance();
      final status = loginPref.getString("loggedIn").toString();
      setState(() {
        loginStatus = status;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loginStatus=="true"?HomePage():LoginPage(),
    );
  }
}