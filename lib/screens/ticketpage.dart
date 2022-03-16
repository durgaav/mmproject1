import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/admin/team.dart';
import 'package:mmcustomerservice/screens/ticketview.dart';
import 'package:mmcustomerservice/ticketsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

class Tickets extends StatefulWidget {
  String usertype = '';
  String currentUser = '';
  Tickets({required this.usertype, required this.currentUser, required});
@override
_TicketsState createState() => _TicketsState(
  usertype: usertype,
  currentUser: currentUser,
);
}

class _TicketsState extends State<Tickets> {
  String usertype = '';
  String currentUser = '';
  _TicketsState({
    required this.usertype,
    required this.currentUser,
  });

  //region Variables
  String sortString = "all";
  List<TicketModel> ticketDetails = [];
  List<TicketModel> searchList = [];
  TextEditingController searchController = new TextEditingController();
  String searchText = "";
  String hintText = "Search";
  String team = '';
  FontWeight normal = FontWeight.normal;
  bool clearSearch = false;
  bool isVisible = true;
  bool isSorted = false;
  List filtered = [];
  String choice = '';
  int teamId = 0;
  ScrollController scrollController = new ScrollController();
  List teamListToPass = [];
  ScrollController barControll = ScrollController();
  //retry
  bool retryVisible = false;
  //endregion Variables

  //region Functions
  Future<void> passDataToView(int index) async {
    List<String> files = [];
    var pref = await SharedPreferences.getInstance();
    List<TeamAssign> teamTick = [];

    //notification to seen
    if(searchList[index].notification=="unseen"){
      if(usertype=='admin'){
        clearNotify(searchList[index].ticketsId.toString(), index);
      }else{
        print("not a user!");
      }
    }

    for (int i = 0; i < searchList[index].files.length; i++) {
      files.add(searchList[index].files[i].filepath);
    };

    pref.remove('Files');
    pref.setStringList('Files', files);

    pref.setString('teamMemId', teamId.toString());

    setState(() {
      teamTick = searchList[index].teamAssign.toList();
    });

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
    pref.setString('server', searchList[index].server.toString() ?? '');
    pref.setString('tickAssignId',teamId.toString() ?? '');
    pref.setString('seo', searchList[index].seo.toString() ?? '');
    pref.setString('design', searchList[index].design.toString() ?? '');
    pref.setString(
        'development', searchList[index].development.toString() ?? '');
    pref.setString("tickId", searchList[index].ticketsId.toString() ?? '');
    pref.setString("UserName", searchList[index].username.toString() ?? "");
    pref.setString("MailID", searchList[index].email.toString() ?? '');
    pref.setString(
        "PhoneNum", searchList[index].phonenumber.toString() ?? '');
    pref.setString(
        "DomainNm", searchList[index].domainName.toString() ?? '');
    pref.setString("Desc", searchList[index].description.toString() ?? '');
    pref.setString("Statuses", searchList[index].status.toString() ?? '');
    pref.setString(
        "Notify", searchList[index].notification.toString() ?? '');
    pref.setString(
        "cusCreatedOn", searchList[index].cusCreatedOn.toString() ?? '');
    pref.setString(
        "cusModifiedOn", searchList[index].cusModifiedOn.toString() ?? '');
    pref.setString(
        "admCreatedOn", searchList[index].admCreatedOn.toString() ?? '');
    pref.setString(
        "admCreatedBy", searchList[index].admCreatedBy.toString() ?? '');
    pref.setString(
        "admModifiedOn", searchList[index].admModifiedOn.toString() ?? '');
    pref.setString(
        "admModifiedBy", searchList[index].admModifiedBy.toString() ?? '');
    pref.setString(
        "admUpdatedOn", searchList[index].admUpdatedOn.toString() ?? '');
    pref.setString(
        "admUpdatedBy", searchList[index].admUpdatedBy.toString() ?? '');
    pref.setString("tmStartUpdatedOn",
        searchList[index].tmStartUpdatedOn.toString() ?? '');
    pref.setString("tmStartUpdatedBy",
        searchList[index].tmStartUpdatedBy.toString() ?? '');
    pref.setString("tmStartModifiedOn",
        searchList[index].tmStartModifiedOn.toString() ?? '');
    pref.setString("tmStartModifiedBy",
        searchList[index].tmStartModifiedBy.toString() ?? '');
    pref.setString("tmProcessUpdatedOn",
        searchList[index].tmProcessUpdatedOn.toString() ?? '');
    pref.setString("tmProcessUpdatedBy",
        searchList[index].tmProcessUpdatedBy.toString() ?? '');
    pref.setString("tmProcessModifiedOn",
        searchList[index].tmProcessModifiedOn.toString() ?? '');
    pref.setString("tmProcessModifiedBy",
        searchList[index].tmProcessModifiedBy.toString() ?? '');
    pref.setString("tmCompleteUpdatedOn",
        searchList[index].tmCompleteUpdatedOn.toString() ?? '');
    pref.setString("tmCompleteUpdatedBy",
        searchList[index].tmCompleteUpdatedBy.toString() ?? '');
    pref.setString("tmCompleteModifiedOn",
        searchList[index].tmCompleteModifiedOn.toString() ?? '');
    pref.setString("tmCompleteModifiedBy",
        searchList[index].tmCompleteModifiedBy.toString() ?? '');

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TicketViewPage(
              tmAssignList: teamTick,
              teamsNamelist:teamListToPass,
            )
        ));
    FocusScope.of(context).unfocus();
  }

  Future<void> fetchTeams() async {
    print('Current user...... $currentUser');
    http.Response res =
    await http.get(Uri.parse('https://mindmadetech.in/api/team/list'));
    if (res.statusCode == 200) {
      List body = json.decode(res.body);
      teamListToPass = body.toList();
      List team = body.where((e) => e['Username'] == '${currentUser}').toList();
      print(team[0]['teamId']);
      setState(() {
        teamId = team[0]['teamId'];
        print("team iddddd....." + teamId.toString());
      });
    }
  }

  Future<void> clearNotify(String ticId , int index) async{
    var request = http.Request('PUT', Uri.parse('https://mindmadetech.in/api/tickets/updateNotification/$ticId'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      setState(() {
        searchList[index].notification = 'seen';
      });
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future<void> fetchTickets() async {
    showAlert(context);
    print("kmsijkhwseiu"+currentUser);
    try {
      http.Response response;
      if (usertype == "admin") {
        response = await http
            .get(Uri.parse("https://mindmadetech.in/api/tickets/list"));
      } else if (usertype == "team") {
        response = await http.get(Uri.parse(
            "https://mindmadetech.in/api/tickets/Teamtickets/$currentUser"));
      } else {
        response = await http.get(Uri.parse(
            "https://mindmadetech.in/api/tickets/customertickets/$currentUser"));
      }
      print(response.statusCode);
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        setState(() {
          retryVisible = false;
          ticketDetails = body.map((e) => TicketModel.fromJson(e)).toList();
        });
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        onNetworkChecking();
      }
    } catch (Exception) {
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

  Future<void> refreshListener() async {
    setState(() {
      fetchTeams();
      fetchTickets();
    });
  }
  //endregion Functions

  @override
  void initState() {
    // TODO: implement initState
    print(currentUser);
    super.initState();
    Future.delayed(Duration.zero, () async {
      fetchTeams();
      fetchTickets();
    });
  }
  @override
  Widget build(BuildContext context) {
    List completed = ticketDetails.where((element) => element.status.toLowerCase() == "completed").toList();
    if(searchText.isNotEmpty){
      setState(() {
        searchList = ticketDetails.where((element) => element.email.toString()
            .toLowerCase().contains(searchText.toString().toLowerCase())).toList();
      });
    }else{
      setState(() {
        searchList = ticketDetails.toList();
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
          title: usertype != "customer"
              ? Text('Tickets')
              : Text('My Tickets'),
          actions: [
            PopupMenuButton(
                icon: Icon(Icons.filter_alt_outlined),
                itemBuilder: (context) => [
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
                        filtered = ticketDetails
                            .where((element) =>
                        element.status.toLowerCase() ==
                            '$sortString')
                            .toList();
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.circle,
                          color: Colors.green,
                        ),
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
                        filtered = ticketDetails
                            .where((element) =>
                        element.status.toLowerCase() ==
                            '$sortString')
                            .toList();
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.circle,
                          color: Colors.yellow,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text("In Progress"),
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
                        filtered = ticketDetails
                            .where((element) =>
                        element.status.toLowerCase() ==
                            '$sortString')
                            .toList();
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.circle,
                          color: Colors.blue,
                        ),
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
                        filtered = ticketDetails
                            .where((element) =>
                        element.status.toLowerCase() ==
                            '$sortString')
                            .toList();
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.circle,
                          color: Colors.red,
                        ),
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
                        sortString = "all";
                        // isVisible = true;
                        // isSorted = false;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.account_box,
                          color: Colors.amber,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text("All"),
                        ),
                      ],
                    ),
                    value: 4,
                  ),
                ])
          ]),
      body:SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: refreshListener,
          backgroundColor: Colors.white,
          color: Colors.blue,
          child: Column(
              children: <Widget>[
                usertype!='customer'?
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
                )
                    :Container(
                  height: 50,
                  padding: EdgeInsets.all(10),
                  child: Text('${completed.length} completed tickets',style: TextStyle(
                      color: Colors.green,
                      fontSize: 17
                  ),),
                ),
                //Retry visible
                Visibility(
                  visible: retryVisible,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: InkWell(
                        child: Text(
                          "Load Failed, Tap here to retry !",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        onTap: () => setState(() {
                          fetchTickets();
                          fetchTeams();
                        })),
                  ),
                ),
                //All status
                searchList.length > 0 ?
                Container(
                  height: MediaQuery.of(context).size.height * 0.81,
                  child:DraggableScrollbar.rrect(
                    backgroundColor: Colors.blue,
                    alwaysVisibleScrollThumb: true,
                    controller: scrollController,
                    child: ListView.builder(
                      controller: scrollController,
                          itemCount: searchList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return sortString.toLowerCase()=="all"?
                            Column(
                                children: <Widget>[
                                  ListTile(
                                    onTap: () {
                                      passDataToView(index);
                                    },
                                    leading: Container(
                                      child: Stack(children: <Widget>[
                                        CircleAvatar(
                                          radius: 35,
                                          backgroundColor:
                                          Colors.cyan,
                                          child: Text(
                                            searchList[index]
                                                .email !=
                                                ''
                                                ? searchList[index]
                                                .email[0]
                                                .toUpperCase()
                                                : "Un named"[0]
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight:
                                                FontWeight.w900),
                                          ),
                                        ),
                                        searchList[index]
                                            .status
                                            .toString()
                                            .toLowerCase() ==
                                            "completed"
                                            ? Positioned(
                                            left: 50,
                                            top: 35,
                                            child: CircleAvatar(
                                              radius: 9,
                                              backgroundColor:
                                              Colors.white,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                Colors.green,
                                                radius: 8,
                                              ),
                                            ))
                                            : searchList[index]
                                            .status
                                            .toString()
                                            .toLowerCase() ==
                                            "inprogress"
                                            ? Positioned(
                                            left: 50,
                                            top: 35,
                                            child: CircleAvatar(
                                              radius: 9,
                                              backgroundColor:
                                              Colors.white,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                Colors
                                                    .yellowAccent,
                                                radius: 8,
                                              ),
                                            ))
                                            : searchList[index]
                                            .status
                                            .toString()
                                            .toLowerCase() ==
                                            "new"
                                            ? Positioned(
                                            left: 50,
                                            top: 35,
                                            child:
                                            CircleAvatar(
                                              radius: 9,
                                              backgroundColor:
                                              Colors
                                                  .white,
                                              child:
                                              CircleAvatar(
                                                backgroundColor:
                                                Colors
                                                    .blue,
                                                radius: 8,
                                              ),
                                            ))
                                            : searchList[index]
                                            .status
                                            .toString()
                                            .toLowerCase() ==
                                            "started"
                                            ? Positioned(
                                            left: 50,
                                            top: 35,
                                            child:
                                            CircleAvatar(
                                              radius: 9,
                                              backgroundColor:
                                              Colors
                                                  .white,
                                              child:
                                              CircleAvatar(
                                                backgroundColor:
                                                Colors
                                                    .red,
                                                radius: 8,
                                              ),
                                            ))
                                            : SizedBox()
                                      ]),
                                    ),
                                    title:searchList[index].email.isNotEmpty?
                                    Text(searchList[index].email,
                                      style:
                                      TextStyle(fontSize: 15.5,
                                          fontWeight:searchList[index].notification=="unseen"?FontWeight.bold:normal),
                                      maxLines: 1,
                                    ):Text('Un specified'),
                                    subtitle:searchList[index].status.isNotEmpty?
                                    Text(searchList[index].status):Text('Un specified'),
                                    trailing: IconButton(
                                      onPressed: () {
                                        passDataToView(index);
                                      },
                                      icon: Icon(
                                        Icons.arrow_right,
                                        size: 35,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 0.5,
                                    margin: EdgeInsets.only(left: 10 , right: 10),
                                    color: Colors.blue[100],
                                  ),
                                ]
                            ):
                            searchList[index].status.toString().toLowerCase() == sortString?
                            Column(children: <Widget>[
                              ListTile(
                                onTap: () {
                                  passDataToView(index);
                                },
                                leading: Container(
                                  child: Stack(children: <Widget>[
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundColor:
                                      Colors.blueGrey,
                                      child: Text(
                                        searchList[index]
                                            .email.isNotEmpty
                                            ? searchList[index]
                                            .email[0]
                                            .toUpperCase()
                                            : "Un named"[0]
                                            .toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight:
                                            FontWeight.w900),
                                      ),
                                    ),
                                    searchList[index]
                                        .status
                                        .toString()
                                        .toLowerCase() ==
                                        "completed"
                                        ? Positioned(
                                        left: 50,
                                        top: 35,
                                        child: CircleAvatar(
                                          radius: 9,
                                          backgroundColor:
                                          Colors.white,
                                          child: CircleAvatar(
                                            backgroundColor:
                                            Colors.green,
                                            radius: 8,
                                          ),
                                        ))
                                        : searchList[index]
                                        .status
                                        .toString()
                                        .toLowerCase() ==
                                        "inprogress"
                                        ? Positioned(
                                        left: 50,
                                        top: 35,
                                        child: CircleAvatar(
                                          radius: 9,
                                          backgroundColor:
                                          Colors.white,
                                          child: CircleAvatar(
                                            backgroundColor:
                                            Colors
                                                .yellowAccent,
                                            radius: 8,
                                          ),
                                        ))
                                        : searchList[index]
                                        .status
                                        .toString()
                                        .toLowerCase() ==
                                        "new"
                                        ? Positioned(
                                        left: 50,
                                        top: 35,
                                        child:
                                        CircleAvatar(
                                          radius: 9,
                                          backgroundColor:
                                          Colors
                                              .white,
                                          child:
                                          CircleAvatar(
                                            backgroundColor:
                                            Colors
                                                .blue,
                                            radius: 8,
                                          ),
                                        ))
                                        : searchList[index]
                                        .status
                                        .toString()
                                        .toLowerCase() ==
                                        "started"
                                        ? Positioned(
                                        left: 50,
                                        top: 35,
                                        child:
                                        CircleAvatar(
                                          radius: 9,
                                          backgroundColor:
                                          Colors
                                              .white,
                                          child:
                                          CircleAvatar(
                                            backgroundColor:
                                            Colors
                                                .red,
                                            radius: 8,
                                          ),
                                        ))
                                        : SizedBox()
                                  ]),
                                ),
                                title:searchList[index].email.isNotEmpty?
                                Text(
                                  searchList[index].email.toString(),
                                  maxLines: 1,
                                  style:
                                  TextStyle(fontSize: 15,color: Colors.black),
                                ):Text('Un specified'),
                                subtitle:searchList[index].status.isNotEmpty?
                                Text(searchList[index].status):Text('Un specified'),
                                trailing: IconButton(
                                  onPressed: () {
                                    passDataToView(index);
                                  },
                                  icon: Icon(
                                    Icons.arrow_right,
                                    size: 35,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              Container(
                                height: 0.5,
                                margin: EdgeInsets.only(left: 10 , right: 10),
                                color: Colors.blue[100],
                              ),
                            ]):
                            Container();
                          }),
                  ),
                ):
                Center(
                  child: Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      'No data found!',
                      style: TextStyle(
                          fontSize: 25, color: Colors.deepPurple),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}


