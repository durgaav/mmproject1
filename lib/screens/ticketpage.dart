import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/ticketview.dart';
import 'package:mmcustomerservice/ticketsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Tickets extends StatefulWidget {
  String usertype='';
  String currentUser='';
  Tickets({required this.usertype, required this.currentUser, required});
  @override
  _TicketsState createState() => _TicketsState(
    usertype: usertype,
    currentUser: currentUser,
  );
}

class _TicketsState extends State<Tickets> {
  String usertype='';
  String currentUser='';
  _TicketsState({
    required this.usertype,
    required this.currentUser,
  });

  //region Variables
  String sortString = "user";
  List<TicketModel> ticketDetails = [];
  TextEditingController searchController = new TextEditingController();
  String searchText = "";
  String hintText = "Search";
  String team = '';
  bool clearSearch = false;
  bool isVisible = true;
  bool isSorted = false;
  List filtered = [];
  String choice = '';
  int teamId = 0;
  //retry
  bool retryVisible = false;
  //endregion Variables

  //region Functions
  Future<void> passDataToView(int index) async{
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

      Navigator.push(context,MaterialPageRoute(builder: (context)=>TicketViewPage(tmAssignList: teamTick,)));

  }

  Future<void> fetchTeams() async{
    print('Current user...... $currentUser');
    http.Response res = await http.get(
      Uri.parse('https://mindmadetech.in/api/team/list')
    );
    if(res.statusCode==200){
      List body = json.decode(res.body);
      List team = body.where((e)=>e['Username']=='${currentUser}').toList();
      print(team[0]['teamId']);
      setState(() {
        teamId = team[0]['teamId'];
        print("team iddddd....."+teamId.toString());
      });
    }
  }

  Future<void> fetchTickets() async {
    showAlert(context);
    try {
      http.Response response;
      if (usertype == "admin") {
        response =
        await http.get(Uri.parse("https://mindmadetech.in/api/tickets/listtest"));
      }
      else if (usertype == "team") {
        response = await http.get(Uri.parse(
            "https://mindmadetech.in/api/tickets/Teamtickets/$currentUser"
        )
        );
      }
      else {
        response = await http.get(Uri.parse(
            "https://mindmadetech.in/api/tickets/customertickets/$currentUser"
        ));
      }
      print(response.statusCode);
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        setState(() {
            retryVisible = false;
            ticketDetails = body.map((e) => TicketModel.fromJson(e)).toList();
        });
        Navigator.pop(context);
      }
      else {
        Navigator.pop(context);
        onNetworkChecking();
      }
    }
    catch (Exception) {
      print(Exception);
      //tap again - visible
      setState(() {
        retryVisible = true;
      });
      Navigator.pop(context);
      onNetworkChecking();
    }
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
                        color: Colors.deepPurpleAccent,
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

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      //networkStatus = "offline";
      return false;
    }
  }

  Future<void> refreshListener() async{
    setState(() {
      fetchTickets();
    });
  }
  //endregion Functions

  @override
  void initState() {
    // TODO: implement initState
    print(usertype);
    super.initState();
    Future.delayed(Duration.zero, () async {
      if(usertype == 'team'){
        fetchTickets();
        fetchTeams();
      }else{
        fetchTickets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0Xff146bf7),
          title: usertype!="client"?Container(
            child: TextField(
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  if(searchText.length > 0){
                    clearSearch = true;
                  }else{
                    clearSearch = false;
                  }
                });
              },
              decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  hintText: 'Search...',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_rounded, color: Colors.white, size: 26,
                  ),
                  suffixIcon:  Visibility(
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
                  )
              ),
            ),
          ):Text('My Tickets'),
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
                        sortString = "completed";
                        isVisible = false;
                        isSorted = true;
                        FocusScope.of(context).unfocus();
                        filtered = ticketDetails.where((element) => element.status.toLowerCase()=='$sortString').toList();
                      });
                    },
                    child:Row(
                        children: <Widget>[
                          Icon(Icons.circle, color: Colors.green,),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text("Completed"),
                          ),
                        ],
                      ),

                    value: 1,
                  ),
                  PopupMenuItem(
                      onTap: () {
                        setState(() {
                          FocusScope.of(context).unfocus();
                          //hintText = "Search in progress";
                          sortString = "inprogress";
                          isVisible = false;
                          isSorted = true;
                          print(sortString);
                          filtered = ticketDetails.where((element) => element.status.toLowerCase()=='$sortString').toList();
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.circle, color: Colors.yellow,),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text("In progress"),
                          ),
                        ],
                      ),
                    value: 2,
                  ),
                  PopupMenuItem(
                      onTap: () {
                        setState(() {
                          //hintText = "Search new";
                          sortString = "new";
                          isVisible = false;
                          isSorted = true;
                          filtered = ticketDetails.where((element) =>element.status.toLowerCase()=='$sortString').toList();
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.circle, color: Colors.blue,),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text("New"),
                          ),
                        ],
                      ),
                    value: 3,
                  ),
                  PopupMenuItem(
                      onTap: () {
                        setState(() {
                          // hintText = "Search not assigned";
                          sortString = "started";
                          isVisible = false;
                          isSorted = true;
                          filtered = ticketDetails.where((element) => element.status.toLowerCase()=='$sortString').toList();
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.circle, color: Colors.red,),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text("Started"),
                          ),
                        ],
                      ),
                    value: 4,
                  ),
                  PopupMenuItem(
                      onTap: () {
                        setState(() {
                          // hintText = "Search by user";
                          // sortString="started";
                          isVisible = true;
                          isSorted = false;
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

      body: SingleChildScrollView(
          child: Container(
            child: RefreshIndicator(
              onRefresh: refreshListener,
              backgroundColor: Colors.blue,
              color: Colors.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //Retry visible
                    Visibility(
                        visible: retryVisible,
                        child : Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: InkWell(
                              child:Text("Load Failed, Tap here to retry !",
                                style: TextStyle(color: Colors.red, fontSize: 16),
                              ),
                              onTap: () => setState(()
                              {
                                fetchTickets();
                              })),
                        ),
                      ),
                    //All status
                    Visibility(
                      visible: isVisible,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: ticketDetails.length>0?ListView.builder(
                            itemCount: ticketDetails.length,
                            itemBuilder: (BuildContext context, int index) {
                              return
                                ticketDetails[index].username.toString().toLowerCase().
                                contains(searchText.toLowerCase()) ?
                              Column(
                                  children: <Widget>[
                                    Container(
                                      height: 70,
                                      child: ListTile(
                                        onLongPress: (){
                                          // Navigator.push(context,MaterialPageRoute(builder: (context)
                                          //     => Test()
                                          // ));
                                        },
                                        onTap: () {
                                          passDataToView(index);
                                        },
                                        leading: Container(
                                          child: Stack(
                                              children: <Widget>[
                                                CircleAvatar(
                                                  radius: 35,
                                                  backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                                  child: Text(
                                                      ticketDetails[index].username!=null?
                                                      ticketDetails[index].username[0].toUpperCase():"Un named"[0].toUpperCase(),
                                                      style: TextStyle(
                                                      color: Colors.white,fontSize: 25,fontWeight: FontWeight.w900
                                                  ),),
                                                ),
                                                ticketDetails[index].status.toString().toLowerCase() ==
                                                    "completed"
                                                    ? Positioned(
                                                    left: 50,
                                                    top: 35,
                                                    child: CircleAvatar(
                                                      radius: 9,
                                                      backgroundColor: Colors.white,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .green,
                                                        radius: 8,
                                                      ),
                                                    )
                                                ):ticketDetails[index].status.toString().toLowerCase()==
                                                    "inprogress" ?
                                                Positioned(
                                                    left: 50,
                                                    top: 35,
                                                    child: CircleAvatar(
                                                      radius: 9,
                                                      backgroundColor: Colors.white,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .yellowAccent,
                                                        radius: 8,
                                                      ),
                                                    )
                                                ) : ticketDetails[index].status.toString().toLowerCase() ==
                                                    "new" ?
                                                Positioned(
                                                    left: 50,
                                                    top: 35,
                                                    child:CircleAvatar(
                                                      radius: 9,
                                                      backgroundColor: Colors.white,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .blue,
                                                        radius: 8,
                                                      ),
                                                    )
                                                ):ticketDetails[index].status.toString().toLowerCase() ==
                                                    "started" ?
                                                Positioned(
                                                    left: 50,
                                                    top: 35,
                                                    child: CircleAvatar(
                                                      radius: 9,
                                                      backgroundColor: Colors.white,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .red,
                                                        radius: 8,
                                                      ),
                                                    )
                                                ):SizedBox()
                                              ]
                                          ),
                                        ),
                                        title: ticketDetails[index].username!=null?
                                        Text(
                                           choice == "email"?ticketDetails[index].email:
                                             ticketDetails[index].username[0].toUpperCase()
                                            + ticketDetails[index].username.substring(1)
                                          , style: TextStyle(
                                            fontSize: 17.5),maxLines: 1,):Text('Un named'),
                                        subtitle: Text("Status : "+ticketDetails[index].status.toString().toLowerCase()),
                                        trailing: IconButton(
                                          onPressed: () {
                                            passDataToView(index);
                                          },
                                          icon: Icon(
                                            Icons.arrow_right, size: 35,
                                            color: Colors.blueAccent,),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.black12,
                                    ),
                                  ]
                              ) : Container(
                                // alignment: Alignment.center,
                                // child: Text('No data found!',style: TextStyle(fontSize: 17,color: Colors.deepPurple),),
                              );
                            }
                        ):Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Text('No data found!',style: TextStyle(fontSize: 25,color: Colors.deepPurple),),
                          ),
                        )
                      ),
                    ),
                    //Filtered status
                    Visibility(
                      visible: isSorted,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.9,
                        child:filtered.length>0?ListView.builder(
                            itemCount: ticketDetails.length,
                            itemBuilder: (BuildContext context, int index) {
                                return ticketDetails[index].status.toString().toLowerCase() == sortString ?
                                ticketDetails[index].username.toString().toLowerCase()
                                    .contains(searchText.toLowerCase())
                                    ? Column(
                                    children: <Widget>[
                                      Container(
                                        height: 70,
                                        child: ListTile(
                                          onTap: () {
                                            passDataToView(index);
                                          },
                                          leading: Container(
                                            child: Stack(
                                                children: <Widget>[
                                                  CircleAvatar(
                                                    radius: 35,
                                                    backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                                    child: Text(
                                                      ticketDetails[index].username!=null?
                                                      ticketDetails[index].username[0].toUpperCase():"Un named"[0].toUpperCase(),
                                                      style: TextStyle(
                                                      color: Colors.white,fontSize: 25,fontWeight: FontWeight.w900
                                                    ),),
                                                  ),
                                                  ticketDetails[index].status.toString().toLowerCase() ==
                                                      "completed"
                                                      ? Positioned(
                                                      left: 50,
                                                      top: 35,
                                                      child: CircleAvatar(
                                                        radius: 9,
                                                        backgroundColor: Colors.white,
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors
                                                              .green,
                                                          radius: 8,
                                                        ),
                                                      )
                                                  ):ticketDetails[index].status.toString().toLowerCase() ==
                                                      "inprogress" ?
                                                  Positioned(
                                                      left: 50,
                                                      top: 35,
                                                      child: CircleAvatar(
                                                        radius: 9,
                                                        backgroundColor: Colors.white,
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors
                                                              .yellowAccent,
                                                          radius: 8,
                                                        ),
                                                      )
                                                  ) : ticketDetails[index].status.toString().toLowerCase() ==
                                                      "new" ?
                                                  Positioned(
                                                      left: 50,
                                                      top: 35,
                                                      child: CircleAvatar(
                                                        radius: 9,
                                                        backgroundColor: Colors.white,
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors
                                                              .blue,
                                                          radius: 8,
                                                        ),
                                                      )
                                                  ) : ticketDetails[index].status.toString().toLowerCase()==
                                                      "started" ? Positioned(
                                                      left: 50,
                                                      top: 35,
                                                      child: CircleAvatar(
                                                        radius: 9,
                                                        backgroundColor: Colors.white,
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors
                                                              .red,
                                                          radius: 8,
                                                        ),
                                                      )
                                                  ) : SizedBox()
                                                ]
                                            ),
                                          ),
                                          title: ticketDetails[index].username!=null?Text(ticketDetails[index].username[0].toUpperCase()
                                              + ticketDetails[index].username.substring(1), style: TextStyle(
                                              fontSize: 17.5),):Text('Un named'),
                                          subtitle: Text("Status : "+ticketDetails[index].status.toString().toLowerCase()),
                                          trailing: IconButton(
                                            onPressed: () {
                                              passDataToView(index);
                                            },
                                            icon: Icon(
                                              Icons.arrow_right, size: 35,
                                              color: Colors.blueAccent,),
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.black12,
                                      ),
                                    ]
                                ):
                                Container() : Container();
                            }
                        ):Center(
                          child: Container(
                          padding: EdgeInsets.only(top: 15),
                          child: Text('No data found!',style: TextStyle(fontSize: 25,color: Colors.deepPurple),),
                      ),
                        )
                      ),
                    ),
                  ]),
            ),
          ),
        ),
    );
  }
}

