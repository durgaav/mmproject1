import 'dart:convert';
import 'dart:io';
import 'package:mmcustomerservice/screens/data.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketAssign extends StatefulWidget {
String ticketId = "";
String updatedBy = '';

TicketAssign({required this.ticketId,required this.updatedBy});

  @override
  _TicketAssignState createState() => _TicketAssignState(ticketId: ticketId,updatedBy: updatedBy);
}

class _TicketAssignState extends State<TicketAssign> {

  String ticketId = "";
  String updatedBy = '';
  String description = '';
  _TicketAssignState({required this.ticketId,required this.updatedBy});

  String? currentUser = '';
  List<teamModel> teamMemberList = [];
  List<bool> teamCheck = [];
  List teamId = [];
  String filterTeam = "all";
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');

  //Default alert dialog
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

  Future<void> getTeam() async{
    showAlert(context);
    try{
      var response = await http.get(Uri.parse("https://mindmadetech.in/api/team/list"));
      print(response.statusCode);
      if(response.statusCode == 200){
        List team = jsonDecode(response.body);
        setState(() {
          //Design
          teamMemberList = team.map((e) => teamModel.fromJson(e)).toList();
          for(int i = 0;i<=teamMemberList.length;i++){
            teamCheck.add(false);
          }
        });
        Navigator.pop(context);
      }
      else{
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_outlined,color: Colors.white,),
                  Text('  ${response.reasonPhrase.toString()}!'),
                ],
              ),
              backgroundColor: Color(0xffE33C3C),
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }catch(ex){
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

  Future<void> teamAssign(String id , List teamId) async{
    showAlert(context);
    try{
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse('https://mindmadetech.in/api/tickets/team/update'));
      request.body = json.encode({
        "ticketsId": "$id",
        "teamId": teamId,
        "Adm_UpdatedOn": formatter.format(DateTime.now()),
        "Adm_UpdatedBy": "$currentUser"
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.done_all,color: Colors.white,),
                  Text('  Team assigned!'),
                ],
              ),
              backgroundColor: Color(0xff28CD1B),
              behavior: SnackBarBehavior.floating,
            )
        );
        // context.read<Data>().addList(teamId);
        print(await response.stream.bytesToString());
      }
      else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_outlined,color: Colors.white,),
                  Text('  ${response.reasonPhrase.toString()}!'),
                ],
              ),
              backgroundColor: Color(0xffE33C3C),
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }catch(Exception){
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
    }

  }

  Future<void> getPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      currentUser = pref.getString('username')!;
      description = pref.getString('Desc')!;
    });
    print(currentUser);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration
        .zero, () async {
      getTeam();
      getPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    List getids = context.watch<Data>().getList();
    List addedList = teamId+getids;
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            print(teamId);
            if(teamId.isEmpty){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.close_outlined,color: Colors.white,),
                        Text('  Please select at least one member!'),
                      ],
                    ),
                    backgroundColor: Color(0xffE33C3C),
                    behavior: SnackBarBehavior.floating,
                  )
              );
            }
            else{
              teamAssign(ticketId, teamId);
            }
            // context.read<Data>().addList(addedList);
          },
          label: Text('Commit team'),
          icon: Icon(Icons.thumb_up),
        ),
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: (){
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                     ),
                      context: context, builder: (context){
                        return Container(
                          padding: EdgeInsets.all(15),
                          height: 250,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("User's Report",style: TextStyle(
                                  color: Colors.red , fontSize: 20,fontWeight: FontWeight.bold
                                ),),
                                SizedBox(height: 20,),
                                Text('$description',style: TextStyle(
                                    color: Colors.black , fontSize: 15
                                ),textAlign: TextAlign.center,),
                              ],
                            ),
                          ),
                        );
                  }
                  );
                },
                icon: Icon(Icons.info)
            ),
            PopupMenuButton(
                icon: Icon(Icons.filter_alt_outlined),
                itemBuilder: (context) =>
                [
                  PopupMenuItem(
                    enabled: false,
                    child: Text('Sort by team...'),
                    value: 1,
                  ),
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        filterTeam = "Design";
                      });
                    },
                    child:Row(
                      children: <Widget>[
                        Icon(Icons.circle, color: Colors.green,),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text("Design"),
                        ),
                      ],
                    ),

                    value: 1,
                  ),
                  PopupMenuItem(

                    onTap: () {
                      setState(() {
                        //hintText = "Search in progress";
                        filterTeam = "Development";
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.circle, color: Colors.yellow,),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text("Development"),
                        ),
                      ],
                    ),
                    value: 2,
                  ),
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        //hintText = "Search new";
                        filterTeam = "SEO";
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.circle, color: Colors.blue,),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text("SEO"),
                        ),
                      ],
                    ),
                    value: 3,
                  ),
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        // hintText = "Search not assigned";
                        filterTeam = "Server";
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.circle, color: Colors.red,),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text("Server"),
                        ),
                      ],
                    ),
                    value: 4,
                  ),
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        filterTeam = "all";
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.account_box, color: Colors.amber,),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text("All"),
                        ),
                      ],
                    ),
                    value: 4,
                  ),
                ]
            )
          ],
          title: Text('Ticket ID : $ticketId'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height*0.9,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 10,
                ),
                GestureDetector(
                  onTap: (){},
                    child: Text("Select member(s) to assign",style:TextStyle(fontSize: 17) ,)),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 10,
                ),
                //Design
                Container(
                  height:  MediaQuery.of(context).size.height*0.8,
                  child: ListView.builder(
                      itemCount: teamMemberList.length,
                      itemBuilder: (context , index){
                        return filterTeam=="all"?
                        CheckboxListTile(
                          subtitle:Text(teamMemberList[index].team.toString()),
                          title: Text(teamMemberList[index].username.toString()),
                          autofocus: false,
                          checkColor: Colors.white,
                          activeColor: Colors.green,
                          selected: teamCheck[index],
                          value: teamCheck[index],
                          onChanged: (bool? value) {
                            setState(() {
                              if(teamCheck[index] == true){
                                teamCheck[index] = false;
                                teamId.removeWhere((element) => element==teamMemberList[index].teamId.toString());
                              }else{
                                teamCheck[index] = true;
                                if(teamId.contains(teamMemberList[index].teamId.toString())){
                                  print('exists...');
                                }else{
                                  teamId.add(teamMemberList[index].teamId.toString());
                                }
                              }
                            });
                          },
                        ):teamMemberList[index].team.toLowerCase().toString()==filterTeam.toLowerCase()?
                        CheckboxListTile(
                          subtitle:Text(teamMemberList[index].team.toString()),
                          title: Text(teamMemberList[index].username.toString()),
                          autofocus: false,
                          checkColor: Colors.white,
                          activeColor: Colors.green,
                          selected: teamCheck[index],
                          value: teamCheck[index],
                          onChanged: (bool? value) {
                            setState(() {
                              if(teamCheck[index] == true){
                                teamCheck[index] = false;
                                teamId.removeWhere((element) => element==teamMemberList[index].teamId.toString());
                              }else{
                                teamCheck[index] = true;
                                if(teamId.contains(teamMemberList[index].teamId.toString())){
                                  print('exists...');
                                }else{
                                  teamId.add(teamMemberList[index].teamId.toString());
                                }
                              }
                            });
                          },
                        ):Container();
                      }
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
class teamModel {
  String teamId = "";
  String username= "";
  String password= "";
  String team= "";
  String email= "";
  String phonenumber= "";
  String createdon= "";
  String createdby= "";
  String modifiedon= "";
  String modifiedby= "";
  String isdeleted= "";

  teamModel(
      {required this.teamId,
        required this.username,
        required this.password,
        required  this.team,
        required this.email,
        required this.phonenumber,
        required  this.createdon,
        required this.createdby,
        required  this.modifiedon,
        required this.modifiedby,
        required this.isdeleted
      });

  teamModel.fromJson(Map<String, dynamic> json) {
    teamId = json['teamId'].toString();
    username = json['Username'];
    password = json['Password'];
    team = json['Team'];
    email = json['Email'];
    phonenumber = json['Phonenumber'];
    createdon = json['Createdon'];
    createdby = json['Createdby'];
    modifiedon = json['Modifiedon'];
    modifiedby = json['Modifiedby'];
    isdeleted = json['Isdeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['teamId'] = this.teamId;
    data['Username'] = this.username;
    data['Password'] = this.password;
    data['Team'] = this.team;
    data['Email'] = this.email;
    data['Phonenumber'] = this.phonenumber;
    data['Createdon'] = this.createdon;
    data['Createdby'] = this.createdby;
    data['Modifiedon'] = this.modifiedon;
    data['Modifiedby'] = this.modifiedby;
    data['Isdeleted'] = this.isdeleted;
    return data;
  }
}