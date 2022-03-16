import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/data.dart';
import 'package:mmcustomerservice/screens/ticketpage.dart';
import 'package:mmcustomerservice/ticketsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ticketview.dart';
import 'package:provider/provider.dart';

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
  List<TicketModel> ticketDetails = [];
  String teamId = '';
  List teamListToPass = [];
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

  Future<void> fetchTeams() async {
    http.Response res =
    await http.get(Uri.parse('https://mindmadetech.in/api/team/list'));
    if (res.statusCode == 200) {
      List body = json.decode(res.body);
      teamListToPass = body.toList();
    }
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
        ticketDetails = body.map((e) => TicketModel.fromJson(e)).toList();
        setState(() {
          ticketDetails = ticketDetails.reversed.toList();
          count = body.length;
          context.read<Data>().setCount(count);
          if (body.length == 0) {
            setState(() {
              tileVisible = false;
              allCleared = true;
            });
          }
        });
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_outlined,color: Colors.white,),
                  Text('  Something went wrong!'),
                ],
              ),
              backgroundColor: Color(0xffE33C3C),
              behavior: SnackBarBehavior.floating,
            )
        );
          onNetworkChecking();
      }
    }catch(ex){
      print(ex);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi_outlined,color: Colors.white,),
                Text('  Something went wrong!'),
              ],
            ),
            backgroundColor: Color(0xffE33C3C),
            behavior: SnackBarBehavior.floating,
          )
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
    List<String> files = [];
    List<String> teamAssignId = [];
    var pref = await SharedPreferences.getInstance();
    List<TeamAssign> teamTick = [];

    for(int i=0;i<ticketDetails[index].files.length;i++){
      // print(ticketDetails[index].tickets!.files![i].filepath);
      files.add(ticketDetails[index].files[i].filepath);
    };

    pref.remove('Files');
    pref.setStringList('Files', files);

    pref.setString('teamMemId', teamId.toString());

    teamTick = ticketDetails[index].teamAssign.toList();

    pref.remove("tickId");
    pref.remove("server");
    pref.remove("seo");
    pref.remove("design");
    pref.remove("development");
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
    pref.setString('server', ticketDetails[index].server.toString()??'');
    pref.setString('seo', ticketDetails[index].seo.toString()??'');
    pref.setString('design', ticketDetails[index].design.toString()??'');
    pref.setString('development', ticketDetails[index].development.toString()??'');
    pref.setString("tickId", ticketDetails[index].ticketsId.toString()??'');
    pref.setString("UserName", ticketDetails[index].username.toString()??"");
    pref.setString("MailID", ticketDetails[index].email.toString()??'');
    pref.setString("PhoneNum", ticketDetails[index].phonenumber.toString()??'');
    pref.setString("DomainNm", ticketDetails[index].domainName.toString()??'');
    pref.setString("Desc", ticketDetails[index].description.toString()??'');
    pref.setString("Statuses", ticketDetails[index].status.toString()??'');
    pref.setString("Notify", ticketDetails[index].notification.toString()??'');
    pref.setString("cusCreatedOn", ticketDetails[index].cusCreatedOn.toString()??'');
    pref.setString("cusModifiedOn", ticketDetails[index].cusModifiedOn.toString()??'');
    pref.setString("admCreatedOn", ticketDetails[index].admCreatedOn.toString()??'');
    pref.setString("admCreatedBy", ticketDetails[index].admCreatedBy.toString()??'');
    pref.setString("admModifiedOn", ticketDetails[index].admModifiedOn.toString()??'');
    pref.setString("admModifiedBy", ticketDetails[index].admModifiedBy.toString()??'');
    pref.setString("admUpdatedOn", ticketDetails[index].admUpdatedOn.toString()??'');
    pref.setString("admUpdatedBy", ticketDetails[index].admUpdatedBy.toString()??'');
    pref.setString("tmStartUpdatedOn", ticketDetails[index].tmStartUpdatedOn.toString()??'');
    pref.setString("tmStartUpdatedBy", ticketDetails[index].tmStartUpdatedBy.toString()??'');
    pref.setString("tmStartModifiedOn", ticketDetails[index].tmStartModifiedOn.toString()??'');
    pref.setString("tmStartModifiedBy", ticketDetails[index].tmStartModifiedBy.toString()??'');
    pref.setString("tmProcessUpdatedOn", ticketDetails[index].tmProcessUpdatedOn.toString()??'');
    pref.setString("tmProcessUpdatedBy", ticketDetails[index].tmProcessUpdatedBy.toString()??'');
    pref.setString("tmProcessModifiedOn", ticketDetails[index].tmProcessModifiedOn.toString()??'');
    pref.setString("tmProcessModifiedBy", ticketDetails[index].tmProcessModifiedBy.toString()??'');
    pref.setString("tmCompleteUpdatedOn", ticketDetails[index].tmCompleteUpdatedOn.toString()??'');
    pref.setString("tmCompleteUpdatedBy", ticketDetails[index].tmCompleteUpdatedBy.toString()??'');
    pref.setString("tmCompleteModifiedOn", ticketDetails[index].tmCompleteModifiedOn.toString()??'');
    pref.setString("tmCompleteModifiedBy", ticketDetails[index].tmCompleteModifiedBy.toString()??'');

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TicketViewPage(
              tmAssignList: teamTick,
              teamsNamelist: teamListToPass.toList(),
            )));
  }

  //endregion Functions

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero,() async{
      fetchNotify();
      fetchTeams();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print(count);
  }

  @override
  Widget build(BuildContext context) {
    var counts = context.watch<Data>().getcounter();
    return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              onPressed: (){Navigator.pop(context);},
              icon:Icon(CupertinoIcons.back),
              iconSize: 30,
              splashColor: Colors.purpleAccent,
            ),
            backgroundColor: Color(0Xff146bf7),
            title: counts==0?
            Text('Notifications'):
            Text('$counts New notifications'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: allCleared,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Center(
                      child:Container(
                            child: Column(
                              children: [
                                Container(
                                  height: 100,
                                  width: 150,
                                  child: Image(
                                    image:AssetImage(
                                      "assets/images/done.gif"
                                    ),
                                  ),
                                ),
                                Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('All Read!'
                                   ,style: TextStyle(fontSize: 20,color: Colors.blueAccent,fontWeight: FontWeight.bold),),
                               ),
                              ],
                            ),
                          )
                    ),
                  ),
                ),
                Visibility(
                    visible:tileVisible ,
                    child:Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.9,
                      child:ListView.builder(
                        itemCount: ticketDetails.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              height:60,
                              child:Column(
                                children: <Widget>[
                                  ListTile(
                                    onTap: (){
                                      color[index]==false?setState(() {
                                        passData(index);
                                        clearNotify(ticketDetails[index].ticketsId.toString());
                                        color.removeAt(index);
                                        color.insert(index, true);
                                        counts = counts - 1;
                                        context.read<Data>().setCount(counts);
                                        if(counts==0){
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
                                    title: Text(ticketDetails[index].email.toString(),maxLines: 1,style:
                                    TextStyle(color: Colors.black,fontSize: 15,fontWeight:normal)
                                      ,),
                                    // subtitle: Text(snapshot.data![index].email,style:
                                    // TextStyle(color: Colors.red,fontSize: 13)),
                                    trailing: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Text(ticketDetails[index].ticketsId.toString()
                                          ,style:
                                          TextStyle(fontWeight: bold,fontSize: 12,color: Colors.white)
                                      ),
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
      );

  }
}