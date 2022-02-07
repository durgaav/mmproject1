import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeamViewPage extends StatefulWidget {
  @override
  _TeamViewPageState createState() => _TeamViewPageState();
}

class _TeamViewPageState extends State<TeamViewPage> {
  String teamId='';
  String Username='';
  String Password='';
  String Team='';
  String Isdeleted='';

  Future<void> deletetm(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Container(
              child: AlertDialog(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 25,
                    ),
                    Text('  Alert!',
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ],
                ),
                content: Text('Are You Sure You Want To Delete?',
                  style: TextStyle(fontSize: 17),),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                  },
                      child: Text('No', style: TextStyle(fontSize: 16),)),
                  TextButton(onPressed: () {
                        deleteAlbum(teamId,Isdeleted);
                        Navigator.pop(context);

                  },
                      child: Text('Yes', style: TextStyle(fontSize: 16),))
                ],
              )
          );
        }
    );
  }

  Future<void>getdata()async{
    var pref = await SharedPreferences.getInstance();

    setState(() {
      teamId = pref.getString('teamid'??'')!;
      Username = pref.getString('tm_user'??'')!;
      Password = pref.getString('tm_pass'??'')!;
      Team = pref.getString('team'??'')!;
      Isdeleted = pref.getString('isdeleted'??'')!;
    });

  }

  Future<void> edittm(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          TextEditingController  UserController = TextEditingController(text: '$Username');
          TextEditingController PassController = TextEditingController(text: '$Password');
          return Container(
              width: double.infinity,
              child: AlertDialog(
                scrollable: true,
                content: Form(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Username',
                            labelText: 'Username',
                          ),
                          controller: UserController,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Password here',
                            labelText: 'Passowrd',
                          ),
                          controller: PassController,
                        ),
                        DropdownButtonFormField(
                          value: dropdownValue,
                          items: datas
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  RaisedButton(
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: () {
                      updateTeam(UserController.text.toString(),
                          PassController.text.toString(),dropdownValue,teamId);
                      Navigator.pop(context);

                    },
                    color: Colors.blueAccent,
                    focusColor: Colors.white,
                  )
                ],
              )
          );
        });
  }

  String dropdownValue = "Design";
  final List<String>datas = ["SEO", "Design", "Development", "Server"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, ()async{
      getdata();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0Xff146bf7),
          title: Text('Team Detials Page'),
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Text(this.Username, style: TextStyle(
                                fontSize: 25, color: Colors.black),),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      edittm(context);
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      deletetm(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                  ),

                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 20, left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text("TeamId :", style: TextStyle(
                                      fontSize: 15, color: Colors.black45),),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(this.teamId, style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),),

                                )
                              ],
                            )
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text("Username:", style: TextStyle(
                                    fontSize: 15, color: Colors.black45),),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(this.Username, style: TextStyle(
                                    fontSize: 18, color: Color(0XFF333333)),),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text("Password:", style: TextStyle(
                                    fontSize: 15, color: Colors.black45),),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(this.Password, style: TextStyle(
                                    fontSize: 18, color: Color(0XFF333333)),),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text("Team:", style: TextStyle(
                                    fontSize: 15, color: Colors.black45),),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(this.Team, style: TextStyle(
                                    fontSize: 18, color: Color(0XFF333333)),),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            )
        )

    );
  }
  Future<void> updateTeam(String name, String Pass, String tm,String teamId) async {
    print(Username+Password+Team+teamId);
    final response = await http.put(
      Uri.parse('https://mindmadetech.in/api/team/update/$teamId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Username': name,
        'Password': Pass,
        'Team':tm
      }),
    );

    if (response.statusCode == 200) {
      print(Username);
      Fluttertoast.showToast(
          msg: 'Updated Successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 15.0
      );
      setState((){
        Username = name;
        Password = Pass;
        Team = tm;
      });
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to Update Team!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
      setState((){
        Username = name;
        Password = Pass;
        Team = tm;
      });
      throw Exception('Failed to update album.');
    }
  }
}

Future<TeamModel> deleteAlbum(String teamId,String y) async {
  final  response = await http.put(
    Uri.parse('https://mindmadetech.in/api/team/delete/$teamId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
body: jsonEncode(<String, String>{
      'Isdeleted': "y",
  }
));

  if (response.statusCode == 200) {
    Fluttertoast.showToast(
        msg: 'Team detials deleted Successfully',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0);
    return TeamModel.fromJson(jsonDecode(response.body));
  } else {
    Fluttertoast.showToast(
        msg: 'Failed to Delete Team Detials!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0);
    throw Exception('Failed to delete album.');
  }
}

class TeamModel {
  final String teamId;
  final String Username;
  final String Password;
  final String Team;
  final String Isdeleted;

  TeamModel({    required this.teamId,
    required this.Username,
    required this.Password,
    required this.Team,
  required this.Isdeleted});

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamId: json['teamId'],
      Username: json['Username'].toString(),
      Password: json['Password'].toString(),
      Team: json['Team'].toString(),
    Isdeleted: json['Isdeleted'].toString());
  }
}
