import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/ticketview.dart';
import 'package:mmcustomerservice/ticketsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      print(resList.where((element) => element=="TeamAssign"));
      setState(() {
        ticks = resList.map((e) => sampleTickets.fromJson(e)).toList();
      });
    }

  }

  Future<void> passData(index) async{
    var pref = await SharedPreferences.getInstance();

    //Deleting prefs
    pref.remove("tickId");
    pref.remove("UserName");
    pref.remove("MailID");
    pref.remove("PhoneNum");
    pref.remove("DomainNm");
    pref.remove("Desc");
    pref.remove("Statuses");
    pref.remove("Notify");
    pref.remove("cusCreatedOn");
    pref.remove("cusModifiedOn");
    pref.remove("admCreatedOn");
    pref.remove("admCreatedBy");
    pref.remove("admModifiedOn");
    pref.remove("admModifiedBy");
    pref.remove("admUpdatedOn");
    pref.remove("admUpdatedBy");
    pref.remove("tmStartUpdatedOn");
    pref.remove("tmStartUpdatedBy");
    pref.remove("tmStartModifiedOn");
    pref.remove("tmStartModifiedBy");
    pref.remove("tmProcessUpdatedOn");
    pref.remove("tmProcessUpdatedBy");
    pref.remove("tmProcessModifiedOn");
    pref.remove("tmProcessModifiedBy");
    pref.remove("tmCompleteUpdatedOn");
    pref.remove("tmCompleteUpdatedBy");
    pref.remove("tmCompleteModifiedOn");
    pref.remove("tmCompleteModifiedBy");


    //Adding prefs
    pref.setString("tickId", ticks[index].tickets!.ticketsId.toString());
    pref.setString("UserName", ticks[index].tickets!.username.toString());
    pref.setString("MailID", ticks[index].tickets!.email.toString());
    pref.setString("PhoneNum", ticks[index].tickets!.phonenumber.toString());
    pref.setString("DomainNm", ticks[index].tickets!.domainName.toString());
    pref.setString("Desc", ticks[index].tickets!.description.toString());
    pref.setString("Statuses", ticks[index].tickets!.status.toString());
    pref.setString("Notify", ticks[index].tickets!.notification.toString());
    pref.setString("cusCreatedOn", ticks[index].tickets!.cusCreatedOn.toString());
    pref.setString("cusModifiedOn", ticks[index].tickets!.cusModifiedOn.toString());
    pref.setString("admCreatedOn", ticks[index].tickets!.admCreatedOn.toString());
    pref.setString("admCreatedBy", ticks[index].tickets!.admCreatedBy.toString());
    pref.setString("admModifiedOn", ticks[index].tickets!.admModifiedOn.toString());
    pref.setString("admModifiedBy", ticks[index].tickets!.admModifiedBy.toString());
    pref.setString("admUpdatedOn", ticks[index].tickets!.admUpdatedOn.toString());
    pref.setString("admUpdatedBy", ticks[index].tickets!.admUpdatedBy.toString());
    pref.setString("tmStartUpdatedOn", ticks[index].tickets!.tmStartUpdatedOn.toString());
    pref.setString("tmStartUpdatedBy", ticks[index].tickets!.tmStartUpdatedBy.toString());
    pref.setString("tmStartModifiedOn", ticks[index].tickets!.tmStartModifiedOn.toString());
    pref.setString("tmStartModifiedBy", ticks[index].tickets!.tmStartModifiedBy.toString());
    pref.setString("tmProcessUpdatedOn", ticks[index].tickets!.tmProcessUpdatedOn.toString());
    pref.setString("tmProcessUpdatedBy", ticks[index].tickets!.tmProcessUpdatedBy.toString());
    pref.setString("tmProcessModifiedOn", ticks[index].tickets!.tmProcessModifiedOn.toString());
    pref.setString("tmProcessModifiedBy", ticks[index].tickets!.tmProcessModifiedBy.toString());
    pref.setString("tmCompleteUpdatedOn", ticks[index].tickets!.tmCompleteUpdatedOn.toString());
    pref.setString("tmCompleteUpdatedBy", ticks[index].tickets!.tmCompleteUpdatedBy.toString());
    pref.setString("tmCompleteModifiedOn", ticks[index].tickets!.tmCompleteModifiedOn.toString());
    pref.setString("tmCompleteModifiedBy", ticks[index].tickets!.tmCompleteModifiedBy.toString());

    print(pref.get("UserName"));

    Navigator.push(context,MaterialPageRoute(builder: (context)=>TicketViewPage()));

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
                      itemBuilder: (context , index) {
                        int i = 0;
                        for(i;i<ticks[index].tickets!.teamAssign!.length;i++){
                          print(i);
                          i = i;
                          print(ticks[index].tickets!.teamAssign![i].teamId);
                        }
                        return Column(
                          children: [
                            ListTile(
                              onTap:(){
                                // print(ticks[index].tickets!.teamAssign!.length);
                                passData(index);
                              },
                              leading: Icon(Icons.account_circle , size: 45,color: Colors.blue,),
                              title: Text('${ticks[index].tickets!.username}'),
                              subtitle: Text('Status : ${ticks[index].tickets!.status}'),
                              trailing: IconButton(
                                onPressed: (){

                                },
                                icon: Icon(
                                  Icons.arrow_right, size: 35,
                                  color: Colors.blueAccent,
                                ),
                              )
                            ),
                            Divider(
                              height: 1.5,
                              color: Colors.blue,
                            ),
                          ],
                        );
                      }
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
