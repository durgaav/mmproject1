import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/ticketsModel.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  String body = '';
  List<sampleTickets> ticks = [];
  Future<void> fetchTickets() async{
    print('Please wait....');
    http.Response response =
    await http.get(Uri.parse("https://mindmadetech.in/api/tickets/listtest"));

    if(response.statusCode==200){
      List resList = jsonDecode(response.body);
      print(resList);
      // for(int i=0 ;i<=resList.length;i++){
      //   print(resList[i]);
      // }
      setState(() {
        ticks = resList.map((e) => sampleTickets.fromJson(e)).toList();
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Test'),
        backgroundColor: Colors.amber,
      ),
      body: Container(
        child: Column(
          children: [
            RaisedButton(
              onPressed: (){
                fetchTickets();
              },
              child: Text('Fetch'),
            ),
            SingleChildScrollView(
              child: Container(
                height: 400,
                  child: ListView.builder(
                    itemCount: ticks.length,
                      itemBuilder: (context , index) =>
                          Column(
                            children: [
                              Text('${ticks[index]}'),
                              Divider(
                                height: 2,
                                color: Colors.red,
                              )
                            ],
                          )
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
