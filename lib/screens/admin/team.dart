import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamList extends StatefulWidget {
  const TeamList({Key? key}) : super(key: key);

  @override
  _TeamListState createState() => _TeamListState();
}

class _TeamListState extends State<TeamList> {
  //region Var
  String dropdownValue = "Design";
  final List<String> datas = ["SEO", "Design", "Development", "Server"];
  TextEditingController UserController = TextEditingController();
  TextEditingController PassController = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();
  TextEditingController phoneCtrlnew = TextEditingController();
  TextEditingController searchController = new TextEditingController();
  String searchText = "";
  List<GetTeam> teamList = [];
  bool divider = true;
  String createdBy = '';
  bool retryVisible = false;
  bool clearSearch = false;
  String sortString = "all";
  List<GetTeam> searchList = [];
  bool isVisible = true;
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
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
                    deleteAlbum(searchList[index].teamId);
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
          TextEditingController  UserController = TextEditingController(text: searchList[index].Username);
          TextEditingController PassController = TextEditingController(text: searchList[index].Password);
          phoneCtrl = new TextEditingController(text:searchList[index].phone );
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
                            hintText: 'Enter Mail id',
                            labelText: 'Mail',
                          ),
                          controller: UserController,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Password here',
                            labelText: 'Password',
                          ),
                          controller: PassController,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            hintText: 'Phone number',
                            labelText: 'Phone',
                          ),
                          controller: phoneCtrl,
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
                      if(UserController.text.isEmpty||PassController.text.isEmpty||phoneCtrl.text.isEmpty){
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.close_outlined,color: Colors.white,),
                                  Text(' Fields not be empty!'),
                                ],
                              ),
                              backgroundColor: Color(0xffE33C3C),
                              behavior: SnackBarBehavior.floating,
                            )
                        );
                      }else{
                        updateTeam(UserController.text.toString(),
                            PassController.text.toString(),phoneCtrl.text.toString(),dropdownValue.toLowerCase(),index);
                        Navigator.pop(context);
                      }
                    },
                    color: Colors.blueAccent,
                    focusColor: Colors.white,
                  )
                ],
              )
          );
        });
  }

  void showAlert(BuildContext context) {
    showDialog(
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

  Future<void> AddtmPopup(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Container(
              height: 600,
              width: double.infinity,
              child: AlertDialog(
                title: Column(
                  children: [
                    Text('Add New Team Member',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    Container(
                      height: 0.5,
                      color: Colors.blue,
                      margin: EdgeInsets.only(top : 15),
                    )
                  ],
                ),
                scrollable: true,
                content: Form(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Enter mail id',
                            labelText: 'Mail id',
                          ),
                          controller: UserController,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Password here',
                            labelText: 'Password',
                          ),
                          controller: PassController,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            hintText: 'Phone number',
                            labelText: 'Phone',
                          ),
                          controller: phoneCtrlnew,
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
                      onPressed: () {
                        String Username = UserController.text;
                        String Password = PassController.text;
                        if(Username.isEmpty||Password.isEmpty||phoneCtrlnew.text.isEmpty||phoneCtrlnew.text.length<10){
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.close_outlined,color: Colors.white,),
                                    Text(' Fields not be empty!'),
                                  ],
                                ),
                                backgroundColor: Color(0xffE33C3C),
                                behavior: SnackBarBehavior.floating,
                              )
                          );
                        }else{
                          Addteam(
                            Username,
                            Password,
                            phoneCtrlnew.text.toString(),
                            dropdownValue.toString(),
                          );
                          Navigator.pop(context);
                        }
                      },
                      color: Colors.blueAccent,
                      focusColor: Colors.white)
                ],
              ));
        });
  }

  Future<void> Addteam(String Username, String Password,String phone, String Team) async {
    showAlert(context);
    try {
      var url = Uri.parse('https://mindmadetech.in/api/team/new');
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            "Email" : Username.toString(),
            "Password" : Password.toString(),
            "Team" : Team.toString(),
            "Phonenumber":phone.toString(),
            "ModifiedOn":formatter.format(DateTime.now()),
            "ModifiedBy":createdBy,
          }));
      if (response.statusCode == 200) {
        if(response.body.contains( "Team added successfully")){
          Navigator.pop(context);
          setState(() {
            refreshListener();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.done_all,color: Colors.white,),
                    Text(' Team created!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              )
          );
        }
        else{
          print(response.body);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.close_outlined,color: Colors.white,),
                    Text(' E-mail already exists!'),
                  ],
                ),
                backgroundColor: Color(0xffE33C3C),
                behavior: SnackBarBehavior.floating,
              )
          );
        }
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
      createdBy = pref.getString('usertypeMail')!;
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
    if(searchText.isNotEmpty){
      setState(() {
        searchList = teamList.where((element) => element.email.toString()
            .toLowerCase().contains(searchText.toString().toLowerCase())).toList();
      });
    }else{
      setState(() {
        searchList = teamList.toList();
      });
    }
    searchList = searchList.reversed.toList();

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: (){Navigator.pop(context);},
            icon:Icon(CupertinoIcons.back),
            iconSize: 30,
            splashColor: Colors.purpleAccent,
          ),
          centerTitle: true,
          backgroundColor: Color(0Xff146bf7),
          title: Text("Team"),
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
          Icons.person_add_alt_outlined ,
          size: 28,
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[

          Container(
            margin: EdgeInsets.all(10),
            height: 45,
            child: TextField(
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
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
                  contentPadding: EdgeInsets.all(5),
                  hintStyle: TextStyle(color: Colors.black),
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.black54,
                    size: 26,
                  ),
                  suffixIcon: Visibility(
                    visible: clearSearch,
                    child: IconButton(
                      color: Colors.black54,
                      iconSize: 24,
                      icon: Icon(
                          Icons.cancel_outlined
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

          Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height *0.81,
                  child: RefreshIndicator(
                    onRefresh: refreshListener,
                    backgroundColor: Colors.blue,
                    color: Colors.white,
                    child: searchList.length>0?
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return
                              sortString=="all"
                              ? Column(
                              children: <Widget>[
                                Container(
                                  child: ExpansionTile(
                                    leading:CircleAvatar(
                                      backgroundColor:
                                      Colors.lightGreen,
                                       radius: 27,
                                      child: Text(
                                          searchList[index].email[0].toUpperCase(),
                                          style: TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      searchList[index].email,
                                      maxLines:1,
                                      style: TextStyle(fontSize: 17.5),
                                    ),
                                    subtitle: Text(
                                      searchList[index].Team,
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black45),
                                    ),
                                    children: <Widget>[
                                      Container(
                                        decoration:BoxDecoration(
                                          color:Colors.blue[50],
                                          borderRadius: BorderRadius.circular(17)
                                        ),
                                        margin:EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: Text('Id & Team',
                                                  style: TextStyle(
                                                      fontSize: 15, color: Colors.black45)),
                                              subtitle: Text(
                                                searchList[index].teamId + " & " +searchList[index].Team,
                                                style: TextStyle(
                                                    fontSize: 16, color: Colors.black),
                                              ),
                                            ),
                                            ListTile(
                                              title: Text('Email',
                                                  style: TextStyle(
                                                      fontSize: 15, color: Colors.black45)),
                                              subtitle: Text(
                                                searchList[index].email,
                                                style: TextStyle(
                                                    fontSize: 16, color: Colors.black),
                                              ),

                                            ),
                                            ListTile(
                                              title: Text('Password',
                                                  style: TextStyle(
                                                      fontSize: 15, color: Colors.black45)),
                                              subtitle: Text(
                                                searchList[index].Password,
                                                style: TextStyle(
                                                    fontSize: 16, color: Colors.black),
                                              ),
                                            ),
                                            ListTile(
                                              onTap:(){
                                                launch("tel://${searchList[index].phone}");
                                              },
                                              title: Text('Phone',
                                                  style: TextStyle(
                                                      fontSize: 15, color: Colors.black45)),
                                              subtitle: Text(
                                                searchList[index].phone,
                                                style: TextStyle(
                                                    fontSize: 16, color: Colors.black
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              leading:Container(
                                                margin: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: Colors.blueAccent[100],
                                                    borderRadius: BorderRadius.circular(20)
                                                ),
                                                width:222,
                                                child: Row(
                                                  children: [
                                                    FlatButton(
                                                        onPressed: (){
                                                          edittm(context,index);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit_outlined , size: 25,color: Colors.red,),
                                                            Text(" Edit   ",style: TextStyle(
                                                                fontSize: 16, color: Colors.white)),
                                                          ],
                                                        )
                                                    ),
                                                    Container(width: 3,color: Colors.white,),
                                                    FlatButton(
                                                        onPressed: (){
                                                          deletetmDailog(context,index);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete_outline , size: 25,color: Colors.red,),
                                                            Text(" Delete",style: TextStyle(
                                                                fontSize: 16, color: Colors.white)),
                                                          ],
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]) :
                              searchList[index].Team.toLowerCase()=="$sortString"
                              ?Column(
                              children: <Widget>[
                                Container(
                                  child: ExpansionTile(
                                    leading:CircleAvatar(
                                      backgroundColor:
                                      Colors.blueAccent,
                                      radius: 27,
                                      child: Text(
                                        searchList[index].email[0].toUpperCase(),
                                        style: TextStyle(fontSize:22,fontWeight: FontWeight.bold,color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      searchList[index].email,
                                      maxLines:1,
                                      style: TextStyle(fontSize: 17.5),
                                    ),
                                    subtitle: Text(
                                      searchList[index].Team,
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black45),
                                    ),
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('Id & Team',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          searchList[index].teamId + " & " +searchList[index].Team,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text('Email',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          searchList[index].email,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),

                                      ),
                                      ListTile(
                                        title: Text('Password',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          searchList[index].Password,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                      ),
                                      ListTile(
                                        onTap:(){
                                          launch("tel://${searchList[index].phone}");
                                        },
                                        title: Text('Phone',
                                            style: TextStyle(
                                                fontSize: 15, color: Colors.black45)),
                                        subtitle: Text(
                                          searchList[index].phone,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        leading:Container(
                                          margin: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: Colors.red[100],
                                              borderRadius: BorderRadius.circular(20)
                                          ),
                                          width:222,
                                          child: Row(
                                            children: [
                                              FlatButton(
                                                  onPressed: (){
                                                    edittm(context,index);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit_outlined , size: 25,color: Colors.deepPurple,),
                                                      Text(" Edit   ",style: TextStyle(
                                                          fontSize: 16, color: Colors.black)),
                                                    ],
                                                  )
                                              ),
                                              Container(width: 3,color: Colors.white,),
                                              FlatButton(
                                                  onPressed: (){
                                                    deletetmDailog(context,index);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete_outline , size: 25,color: Colors.red,),
                                                      Text(" Delete",style: TextStyle(
                                                          fontSize: 16, color: Colors.black)),
                                                    ],
                                                  )
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                          ):
                               Container();
                        }):Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'No data found!',
                          style: TextStyle(
                              fontSize: 25, color: Colors.deepPurple),
                        ),
                      ),
                    )
                  ))

        ]),
      ),
    );
  }

   //delete tm
  Future<void> deleteAlbum(String teamId) async {
    showAlert(context);
    try{
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
        if(response.body.contains("Is deleted : y")){
          Navigator.pop(context);
          setState(() {
            refreshListener();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.done_all,color: Colors.white,),
                    Text(' Team Deleted!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              )
          );
        }else{
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.wifi_outlined,color: Colors.white,),
                    Text(' Unable to delete team!'),
                  ],
                ),
                backgroundColor: Colors.red[300],
                behavior: SnackBarBehavior.floating,
              )
          );
        }
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_outlined,color: Colors.white,),
                  Text(' Something went wrong!'),
                ],
              ),
              backgroundColor: Colors.red[300],
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }catch(error){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi_outlined,color: Colors.white,),
                Text(' Something went wrong!'),
              ],
            ),
            backgroundColor: Colors.red[300],
            behavior: SnackBarBehavior.floating,
          )
      );
    }

  }
  //update tm
  Future<void> updateTeam(String name, String Pass,String mobile, String tm,int index) async {
    showAlert(context);
    String teamId = searchList[index].teamId;
    final response = await http.put(
      Uri.parse('https://mindmadetech.in/api/team/update/$teamId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "Email" : name.toString(),
        "Password" : Pass.toString(),
        "Team" : tm.toString(),
        "Phonenumber":mobile.toString(),
        "ModifiedOn":formatter.format(DateTime.now()),
        "ModifiedBy":createdBy,
      }),
    );

    if (response.statusCode == 200) {
      if(response.body.contains('Updated Successfully')){
        Navigator.pop(context);
        setState((){
          searchList[index].email = name;
          searchList[index].Password= Pass;
          searchList[index].Team= tm;
          searchList[index].phone= mobile;
          refreshListener();
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.done_all,color: Colors.white,),
                  Text(' Edits saved!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            )
        );
      }else{
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.close_outlined,color: Colors.white,),
                  Text(' Failed to save edits!'),
                ],
              ),
              backgroundColor: Colors.red[300],
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Failed to Update Team!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0
      );
      throw Exception('Failed to update album.');
    }
  }
}

class GetTeam {
  String teamId;
  String Username;
  String Password;
  String email;
  String phone;
  String Team;
  String createdOn;
  String createdBy;
  String modOn;
  String modBy;
  String Isdeleted;

  GetTeam(
      {required this.teamId,
        required this.email,
        required this.Username,
        required this.Password,
        required this.phone,
        required this.createdOn,
        required this.createdBy,
        required this.modOn,
        required this.modBy,
        required this.Team,
        required this.Isdeleted});

  factory GetTeam.fromJson(Map<String, dynamic> json) {
    return GetTeam(
        teamId: json['teamId'].toString(),
        email: json['Email'].toString(),
        phone: json['Phonenumber'].toString(),
        Username: json['Username'].toString(),
        Password: json['Password'].toString(),
        createdOn: json['CreatedOn'].toString(),
        createdBy: json['CreatedBy'].toString(),
        modOn: json['ModifiedOn'].toString(),
        modBy: json['ModifiedBy'].toString(),
        Team: json['Team'].toLowerCase().toString(),
        Isdeleted: json['Isdeleted'].toString());
  }
}

