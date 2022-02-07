import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/ticketpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ticketview.dart';

class NotifScreen extends StatefulWidget {
  @override
  _NotifScreenState createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {

  //region Vars
  FontWeight bold = FontWeight.bold;
  FontWeight normal = FontWeight.normal;
  int count = 0;
  List<bool> color = [];
  bool tileVisible = true;
  bool allCleared = false;
  List<GetTicket> dataNotifi = [];
  //endregion Vars

  //region Functions

  //Default loader
  showAlert(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(
              child: AlertDialog(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        color: Colors.red,
                      ),
                      Text(
                        '  Please wait...',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  )));
        });
  }

  //Getting unseen notify list
  Future<void> fetchNotify() async {
    showAlert(context);
    try {
      http.Response response =
      await http.get(
          Uri.parse("https://mindmadetech.in/api/tickets/notification/unseen"));
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        List body = jsonDecode(response.body);
        for (int i = 0; i < body.length; i++) {
          color.add(false);
        }
        dataNotifi = body.map((e) => GetTicket.fromJson(e)).toList();
        setState(() {
          count = body.length;
          if (body.length == 0) {
            setState(() {
              tileVisible = false;
              allCleared = true;
            });
          }
        });
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: 'Something went wrong',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
          onNetworkChecking();
      }
    }catch(ex){
      print(ex);
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Something went wrong',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0
      );

        onNetworkChecking();

    }
  }

  //Network
  onNetworkChecking() async {
    bool isOnline = await hasNetwork();
    if (isOnline == false) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are Offline!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.bold)
            ),
            backgroundColor: Color(0xffcd5c5c),
            margin: EdgeInsets.only(left: 100,
                right: 100,
                bottom: 15),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(20))),
          ));
    }
    else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
          SnackBar(
            content: Text('Back to online!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.bold)
            ),
            backgroundColor: Colors.green,
            margin: EdgeInsets.only(left: 100,
                right: 100,
                bottom: 10),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(20))),
          ));
    }
    return isOnline;
  }
  //Network
  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      //networkStatus = "offline";
      return false;
    }
  }

  //Changing viewed notification to seen
  Future<void> clearNotify(String ticId) async{
    var request = http.Request('PUT', Uri.parse('https://mindmadetech.in/api/tickets/updateNotification/$ticId'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  //Passing data to screens by prefs
  Future<void> passData(int index) async{
    String des='',dev='',seo='',ser='';
    if(dataNotifi[index].design=='y'){
      setState(() {
        des = 'Design';
      });
    }if(dataNotifi[index].development=='y'){
      setState(() {
        dev = 'Development';
      });
    }if(dataNotifi[index].seo=='y'){
      setState(() {
        seo = 'Seo';
      });
    }if(dataNotifi[index].server=='y'){
      setState(() {
        ser = 'Server';
      });
    }
    var pref = await SharedPreferences.getInstance();
    //Removing prefs
    pref.remove('adm_modify_on');
    pref.remove('adm_update_by');
    pref.remove('statusUpdateTime');
    pref.remove('Description');
    pref.remove('tm_CompModby');
    pref.remove('DomainName');
    pref.remove('Screenshots');
    pref.remove('tm_procesModBy');
    pref.remove( 'Date');
    pref.remove('Email');
    pref.remove('tm_cmpleUpdOn');
    pref.remove('createdOn');
    pref.remove( 'ticketId');
    pref.remove('adm_mod_by');
    pref.remove('adm_updte_on');
    pref.remove('tm_compleupBy');
    pref.remove( 'Username');
    pref.remove('Phonenumber');
    pref.remove( 'Status');
    pref.remove('tm_startupdateBy');
    pref.remove('tm_procesupdBy');
    pref.remove('tm_procesModOn');
    pref.remove('tm_CompModOn');
    pref.remove('tm_startModBy');
    pref.remove('Team');
    pref.remove('tm_startupdateon');
    pref.remove('tm_procesupdOn');
    pref.remove('tm_startModon');

    //Loading prefs
    pref.setString('adm_modify_on',dataNotifi[index].admModifiedOn??'');
    pref.setString('adm_update_by',dataNotifi[index].admUpdatedBy??'');
    pref.setString('statusUpdateTime',dataNotifi[index].status??'');
    pref.setString('Description',dataNotifi[index].description??'');
    pref.setString('tm_CompModby',dataNotifi[index].tmCompleteModifiedBy??'');
    pref.setString('DomainName', dataNotifi[index].domainName??'');
    pref.setString('Screenshots', dataNotifi[index].screenshots??'');
    pref.setString('tm_procesModBy',dataNotifi[index].tmProcessModifiedBy??'');
    pref.setString( 'Date', dataNotifi[index].cusCreatedOn??'');
    pref.setString('Email',dataNotifi[index].email??'');
    pref.setString('tm_cmpleUpdOn',dataNotifi[index].tmCompleteUpdatedOn??'');
    pref.setString('createdOn',dataNotifi[index].cusCreatedOn??'');
    pref.setString( 'ticketId', dataNotifi[index].ticketsId??'');
    pref.setString('adm_mod_by',dataNotifi[index].admModifiedBy??'');
    pref.setString('adm_updte_on', dataNotifi[index].admUpdatedOn??'');
    pref.setString('tm_compleupBy',dataNotifi[index].tmCompleteUpdatedBy??'');
    pref.setString( 'Username',dataNotifi[index].username??'');
    pref.setString('Phonenumber', dataNotifi[index].phonenumber??'');
    pref.setString( 'Status', dataNotifi[index].status??'');
    pref.setString('tm_startupdateBy', dataNotifi[index].tmStartUpdatedBy??'');
    pref.setString('tm_procesupdBy',dataNotifi[index].tmProcessUpdatedBy??'');
    pref.setString('tm_procesModOn',dataNotifi[index].tmProcessModifiedOn??'');
    pref.setString('tm_CompModOn',dataNotifi[index].tmCompleteModifiedOn??'');
    pref.setString('tm_startModBy',dataNotifi[index].tmStartModifiedBy??'');
    pref.setString('Team',des+" "+dev+" "+seo+" "+ser??'');
    pref.setString('tm_startupdateon', dataNotifi[index].tmStartUpdatedOn??'');
    pref.setString('tm_procesupdOn', dataNotifi[index].tmProcessUpdatedOn??'');
    pref.setString('tm_startModon',dataNotifi[index].tmStartModifiedOn??'');

    Navigator.push(context,MaterialPageRoute(builder: (context)=>TicketViewPage()));

  }

  //endregion Functions

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero,() async{
      fetchNotify();
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text('$count New notifications'),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              icon: Icon(Icons.close),
              color: Colors.white,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Visibility(
                    visible: allCleared,
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget> [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No Notifications',style: TextStyle(fontSize: 22,color: Colors.pinkAccent),),
                          ),
                        )
                      ],
                    )),
                Visibility(
                    visible:tileVisible ,
                    child:Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.9,
                      child:ListView.builder(
                        itemCount: dataNotifi.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              height:60,
                              child:Column(
                                children: <Widget>[
                                  ListTile(
                                    onTap: (){
                                      color[index]==false?setState(() {
                                        passData(index);
                                        clearNotify(dataNotifi[index].ticketsId.toString());
                                        color.removeAt(index);
                                        color.insert(index, true);
                                        count = count-1;
                                        if(count==0){
                                          setState(() {
                                            tileVisible=false;
                                            allCleared=true;
                                          });
                                        }
                                      }):setState((){
                                        passData(index);
                                      });
                                    },
                                    leading: Icon(Icons.notifications,size: 30,color:color[index]==false?Colors.green:Colors.black26,),
                                    title: Text(dataNotifi[index].username.toString(),style:
                                    TextStyle(color: Colors.black,fontSize: 16,fontWeight:color[index]==false?bold:normal)
                                      ,),
                                    // subtitle: Text(snapshot.data![index].email,style:
                                    // TextStyle(color: Colors.red,fontSize: 13)),
                                    trailing: Text("Ticket Id : "+dataNotifi[index].ticketsId.toString()
                                        ,style:
                                        TextStyle(fontWeight: bold,fontSize: 12)
                                    ),
                                  ),
                                  Divider(
                                    height: 2,
                                    color: Colors.black,
                                  ),
                                ],
                              )
                          );
                        },
                      ),
                    )
                ),
                ]
            )
          )
      ),
    );
  }
}