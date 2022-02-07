import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mmcustomerservice/screens/admin/teamview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamList extends StatefulWidget {
  const TeamList({Key? key}) : super(key: key);

  @override
  _TeamListState createState() => _TeamListState();
}

class _TeamListState extends State<TeamList> {
  //region Var
  String dropdownValue = "Design";
  final List<String> datas = ["Seo", "Design", "Development", "Server"];
  TextEditingController UserController = TextEditingController();
  TextEditingController PassController = TextEditingController();
  TextEditingController searchController = new TextEditingController();
  String searchText = "";
  List<GetTeam> teamList = [];
  bool divider = true;
  String createdBy = '';
  bool retryVisible = false;
  bool clearSearch = false;
  String sortString = "user";
  bool isVisible = true;
  bool isSorted = false;

  //endregion Var

  //region Functions
  Future<void> refreshListener() async {
    setState(() {
      fetchTeam();
    });
  }

  Future<void> fetchTeam() async {
    showAlert(context);
    try {
      http.Response response =
      await http.get(Uri.parse("https://mindmadetech.in/api/team/list"));
      if (response.statusCode == 200) {
        Navigator.pop(context);
        List body = jsonDecode(response.body);
        print("body,....."+body.toString());
        setState(() {
          retryVisible = false;
          teamList = body.map((e) => GetTeam.fromJson(e)).toList();
        });
      } else {
        setState(() {
          retryVisible = false;
        });
        Navigator.pop(context);
        onNetworkChecking();
      }
    } catch (ex) {
      setState(() {
        retryVisible = false;
      });
      // Navigator.pop(context);
      onNetworkChecking();
    }
  }

  Future<void> deletetmDailog(BuildContext context,int  index) async {
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
                    deleteAlbum(teamList[index].teamId);
                    Navigator.pop(context);
                  },
                      child: Text('Yes', style: TextStyle(fontSize: 16),))
                ],
              )
          );
        }
    );
  }

  Future<void> edittm(BuildContext context,int index) async {
    return showDialog(
        context: context,
        builder: (context) {
          TextEditingController  UserController = TextEditingController(text: teamList[index].Username);
          TextEditingController PassController = TextEditingController(text: teamList[index].Password);
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
                          PassController.text.toString(),dropdownValue.toLowerCase(),index);
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

  onNetworkChecking() async {
    bool isOnline = await hasNetwork();
    if (isOnline == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You are Offline!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xffcd5c5c),
        margin: EdgeInsets.only(left: 100, right: 100, bottom: 15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Back to online!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        margin: EdgeInsets.only(left: 100, right: 100, bottom: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ));
    }
    return isOnline;
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      //networkStatus = "offline";
      return false;
    }
  }

  /*Future<void> passdata(int index) async {
   var pref = await SharedPreferences.getInstance();

   pref.remove('teamid').toString();
   pref.remove('tm_user').toString();
   pref.remove('pass').toString();
   pref.remove('tm_pass').toString();
   pref.remove('isdeleted').toString();

   pref.setString('teamid', teamList[index].teamId ?? '');
   pref.setString('tm_user', teamList[index].Username ?? '');
   pref.setString('tm_pass', teamList[index].Password ?? '');
   pref.setString('team', teamList[index].Team ?? '');
   pref.setString('isdeleted', teamList[index].Isdeleted ?? '');
   Navigator.push(
     context,
     MaterialPageRoute(
         builder: (context) => TeamViewPage()),
   );
 }*/

  Future<void> AddtmPopup(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Container(
              height: 600,
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
                          hint: Text("SELECT"),
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
                        "Add",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () async {
                        String Username = UserController.text;
                        String Password = PassController.text;
                        print(Username);
                        print(Password);
                        print(dropdownValue.toString());
                        setState(() {
                          Addteam(
                            Username,
                            Password,
                            dropdownValue.toString(),
                          );
                        });
                        Navigator.pop(context);
                      },
                      color: Colors.blueAccent,
                      focusColor: Colors.white)
                ],
              ));
        });
  }

  Future<void> Addteam(String Username, String Password, String Team) async {
    showAlert(context);
    try {
      var url = Uri.parse('https://mindmadetech.in/api/team/new');
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'Username': Username,
            'Password': Password,
            'Team': Team,
            'Createdon': DateTime.now().toString(),
            'Createdby': '$createdBy'
          }));
      if (response.statusCode == 200) {
        Navigator.pop(context);
        refreshListener();
        Fluttertoast.showToast(
            msg: 'Team Created successfully!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 15.0);
      } else {
        Navigator.pop(context);
        onNetworkChecking();
      }
    } catch (ex) {
      Navigator.pop(context);
      onNetworkChecking();
    }
  }

  Future<void> getPref() async {
    var pref = await SharedPreferences.getInstance();
    if (pref != null) {
      createdBy = pref.getString('username')!;
    }
    print("Created by = " + createdBy);
  }

  //endregion Functions

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    Future.delayed(Duration
        .zero, () async {
      fetchTeam();
    });
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0Xff146bf7),
          title: Container(
            //search
            child: TextField(
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  if (searchText.length > 0) {
                    clearSearch = true;
                  } else {
                    clearSearch = false;
                  }
                });
              },
              decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  hintText: 'Search...',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  suffixIcon: Visibility(
                    visible: clearSearch,
                    child: IconButton(
                      color: Colors.white,
                      iconSize: 20,
                      icon: Icon(
                        Icons.close,
                      ),
                      onPressed: () {
                        setState(() {
                          searchText = "";
                          searchController.clear();
                          FocusScope.of(context).unfocus();
                          clearSearch = false;
                        });
                      },
                    ),
                  )),
            ),
          ),
          actions: [
            PopupMenuButton(
                icon: Icon(Icons.filter_alt_outlined),
                itemBuilder: (context) =>
                [
                  PopupMenuItem(
                    enabled: false,
                    child: Text('Sort by...'),
                    value: 1,
                  ),
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        sortString = "design";
                        isVisible = false;
                        isSorted = true;
                        print(sortString);
                        FocusScope.of(context).unfocus();
                      });
                    },
                    child:Row(
                      children: <Widget>[
                        Icon(Icons.ballot_rounded , color: Colors.green,),
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
                        FocusScope.of(context).unfocus();
                        sortString = "development";
                        isVisible = false;
                        isSorted = true;
                        print(sortString);
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
                        sortString = "seo";
                        isVisible = false;
                        isSorted = true;
                        print(sortString);

                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.search, color: Colors.blue,),
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
                        sortString = "server";
                        isVisible = false;
                        isSorted = true;
                        print(sortString);

                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.admin_panel_settings, color: Colors.red,),
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
                        sortString="all";
                        isVisible = true;
                        isSorted = false;
                        print(sortString);

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
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddtmPopup(context);
        },
        child: Icon(
          Icons.add,
          size: 28,
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Visibility(
            visible: retryVisible,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: InkWell(
                  child: Text("Load Failed, Tap here to retry !",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  onTap: () =>
                      setState(() {
                        fetchTeam();
                      })),
            ),
          ),

          Visibility(
              visible: isVisible,
              child:Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height *0.9,
                  child: RefreshIndicator(
                    onRefresh: refreshListener,
                    backgroundColor: Colors.blue,
                    color: Colors.white,
                    child: ListView.builder(
                        itemCount: teamList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return (teamList[index].Isdeleted == "n")
                              ? (teamList[index]
                              .Username
                              .toLowerCase()
                              .contains(searchText))
                              ? Column(
                              children: <Widget>[
                                Container(
                                  child: ExpansionTile(
                                    leading:
                                    //Icon(Icons.calendar_today, size: 35, color: Colors.green,),
                                    Container(
                                        child:Stack(
                                          children: [
                                            (teamList[index].Team == "design") ? Icon(Icons.ballot_rounded, size: 35, color: Colors.orange,) :
                                            (teamList[index].Team == "server") ? Icon(Icons.admin_panel_settings,size: 35, color: Colors.red,):
                                            (teamList[index].Team == "development") ? Icon(Icons.calendar_today,  size: 35, color: Colors.green,) :
                                            (teamList[index].Team == "seo") ? Icon(Icons.search,size: 35,  color: Colors.blue,) : Container(),
                                          ],
                                        )
                                    ),
                                    title: Text(
                                      teamList[index]
                                          .Username[0]
                                          .toUpperCase() +
                                          teamList[index].Username.substring(1),
                                      style: TextStyle(fontSize: 17.5),
                                    ),
                                    subtitle: Text(
                                      'Click for more...',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black45),
                                    ),
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('TeamId',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          teamList[index].teamId,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text('Team',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          teamList[index].Team,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                        trailing: Icon(Icons.people,size: 25,color: Colors.black,),
                                      ),
                                      ListTile(
                                        title: Text('Username',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          teamList[index].Username,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                        trailing: Icon(Icons.person,size: 25,color: Colors.black,),
                                      ),
                                      ListTile(
                                        title: Text('Password',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          teamList[index].Password,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                        trailing: Icon(Icons.lock,size:25,color: Colors.black,),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            child: Row(
                                              children: [
                                                Container(
                                                  child: IconButton(
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () {
                                                      edittm(context,index);
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () {
                                                      deletetmDailog(context,index);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ])
                              : Container()
                              : Container();
                        }),
                  ))
          ),



          Visibility(
              visible: isSorted,
              child:Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height *0.9,
                  child: RefreshIndicator(
                    onRefresh: refreshListener,
                    backgroundColor: Colors.blue,
                    color: Colors.white,
                    child: ListView.builder(
                        itemCount: teamList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return (teamList[index].Team=="$sortString")
                              ? (teamList[index]
                              .Username
                              .toLowerCase()
                              .contains(searchText))
                              ? Column(
                              children: <Widget>[
                                Container(
                                  child:new ExpansionTile(
                                    leading: Container(
                                        child:Stack(
                                          children: [
                                            (teamList[index].Team == "design") ? Icon(Icons.ballot_rounded, size: 35, color: Colors.orange,) :
                                            (teamList[index].Team == "server") ? Icon(Icons.admin_panel_settings,size: 35, color: Colors.red,):
                                            (teamList[index].Team == "development") ? Icon(Icons.calendar_today,  size: 35, color: Colors.green,) :
                                            (teamList[index].Team == "seo") ? Icon(Icons.search,size: 35,  color: Colors.blue,) : Container(),
                                          ],
                                        )
                                    ),
                                    title: Text(
                                      teamList[index]
                                          .Username[0]
                                          .toUpperCase() +
                                          teamList[index].Username.substring(1),
                                      style: TextStyle(fontSize: 17.5),
                                    ),
                                    subtitle: Text(
                                      'Click for more...',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black45),
                                    ),
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('TeamId',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          teamList[index].teamId,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text('Team',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          teamList[index].Team,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                        trailing: Icon(Icons.people,size: 25,color: Colors.black,),
                                      ),
                                      ListTile(
                                        title: Text('Username',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          teamList[index].Username,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                        trailing: Icon(Icons.person,size: 25,color: Colors.black,),
                                      ),
                                      ListTile(
                                        title: Text('Password',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          teamList[index].Password,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                        trailing: Icon(Icons.lock,size: 25,color: Colors.black,),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            child: Row(
                                              children: [
                                                Container(
                                                  child: IconButton(
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () {
                                                      edittm(context,index);
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () {
                                                      deletetmDailog(context,index);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )

                                    ],
                                  ),

                                )])
                              : Container():Container();
                        }),
                  ))
          ),


        ]),
      ),
    );
  }

  //update tm
  Future<void> updateTeam(String name, String Pass, String tm,int index) async {
    String teamId = teamList[index].teamId;
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
      print( teamList[index].Username );
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
        teamList[index].Username = name;
        teamList[index].Password= Pass;
        teamList[index].Team= tm;
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
        teamList[index].Username = name;
        teamList[index].Password= Pass;
        teamList[index].Team= tm;
      });
      throw Exception('Failed to update album.');
    }
  }
}
//delete tm
Future<GetTeam> deleteAlbum(String teamId) async {
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
    return GetTeam.fromJson(jsonDecode(response.body));
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

class GetTeam {
  String teamId;
  String Username;
  String Password;
  String Team;
  String Isdeleted;

  GetTeam(
      {required this.teamId,
        required this.Username,
        required this.Password,
        required this.Team,
        required this.Isdeleted});

  factory GetTeam.fromJson(Map<String, dynamic> json) {
    return GetTeam(
        teamId: json['teamId'].toString(),
        Username: json['Username'].toString(),
        Password: json['Password'].toString(),
        Team: json['Team'].toLowerCase().toString(),
        Isdeleted: json['Isdeleted'].toString());
  }
}

