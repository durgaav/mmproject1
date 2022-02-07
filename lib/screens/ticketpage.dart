import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/ticketview.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<GetTicket> ticketDetails = [];
  TextEditingController searchController = new TextEditingController();
  String searchText = "";
  String hintText = "Search";
  String team = '';
  bool clearSearch = false;
  bool isVisible = true;
  bool isSorted = false;
  List filtered = [];
  //retry
  bool retryVisible = false;
  //endregion Variables

  //region Functions
  Future<void> passDataToView(int index) async{
    String des='',dev='',seo='',ser='';
    if(ticketDetails[index].design=='y'){
      setState(() {
        des = 'Design';
      });
    }if(ticketDetails[index].development=='y'){
      setState(() {
        dev = 'Development';
      });
    }if(ticketDetails[index].seo=='y'){
      setState(() {
        seo = 'Seo';
      });
    }if(ticketDetails[index].server=='y'){
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
    pref.remove('project_Code');

      pref.setString('adm_modify_on',ticketDetails[index].admModifiedOn??'');
      pref.setString('project_Code',ticketDetails[index].projectCode??'');
      pref.setString('adm_update_by',ticketDetails[index].admUpdatedBy??'');
      pref.setString('statusUpdateTime',ticketDetails[index].status??'');
      pref.setString('Description',ticketDetails[index].description??'');
      pref.setString('tm_CompModby',ticketDetails[index].tmCompleteModifiedBy??'');
      pref.setString('DomainName', ticketDetails[index].domainName??'');
      pref.setString('Screenshots', ticketDetails[index].screenshots??'');
      pref.setString('tm_procesModBy',ticketDetails[index].tmProcessModifiedBy??'');
      pref.setString( 'Date', ticketDetails[index].cusCreatedOn??'');
      pref.setString('Email',ticketDetails[index].email??'');
      pref.setString('tm_cmpleUpdOn',ticketDetails[index].tmCompleteUpdatedOn??'');
      pref.setString('createdOn',ticketDetails[index].cusCreatedOn??'');
      pref.setString( 'ticketId', ticketDetails[index].ticketsId??'');
      pref.setString('adm_mod_by',ticketDetails[index].admModifiedBy??'');
      pref.setString('adm_updte_on', ticketDetails[index].admUpdatedOn??'');
      pref.setString('tm_compleupBy',ticketDetails[index].tmCompleteUpdatedBy??'');
      pref.setString( 'Username',ticketDetails[index].username??'');
      pref.setString('Phonenumber', ticketDetails[index].phonenumber??'');
      pref.setString( 'Status', ticketDetails[index].status??'');
      pref.setString('tm_startupdateBy', ticketDetails[index].tmStartUpdatedBy??'');
      pref.setString('tm_procesupdBy',ticketDetails[index].tmProcessUpdatedBy??'');
      pref.setString('tm_procesModOn',ticketDetails[index].tmProcessModifiedOn??'');
      pref.setString('tm_CompModOn',ticketDetails[index].tmCompleteModifiedOn??'');
      pref.setString('tm_startModBy',ticketDetails[index].tmStartModifiedBy??'');
      pref.setString('Team',des+" "+dev+" "+seo+" "+ser??'');
      pref.setString('tm_startupdateon', ticketDetails[index].tmStartUpdatedOn??'');
      pref.setString('tm_procesupdOn', ticketDetails[index].tmProcessUpdatedOn??'');
      pref.setString('tm_startModon',ticketDetails[index].tmStartModifiedOn??'');

    //Loading prefs

    Navigator.push(context,MaterialPageRoute(builder: (context)=>TicketViewPage()));

  }

  Future<void> fetchTickets() async {
    showAlert(context);
    try {
      http.Response response;
      if (usertype == "admin") {
        response =
        await http.get(Uri.parse("https://mindmadetech.in/api/tickets/list"));
      }
      else if (usertype == "team") {
        response = await http.get(Uri.parse(
            "https://mindmadetech.in/api/tickets/Teamtickets/$currentUser"));
      }
      else {
        response = await http.get(Uri.parse(
            "https://mindmadetech.in/api/tickets/customertickets/$currentUser"));
      }
      print(response.statusCode);
      if (response.statusCode == 200) {
        List body = [];
        setState(() {
          //tap again - visible
          retryVisible = false;
          body = jsonDecode(response.body);
          ticketDetails = body.map((e) => GetTicket.fromJson(e)).toList();
        });
        Navigator.pop(context);
      }
      else {
        Navigator.pop(context);
        onNetworkChecking();
      }
    }
    catch (Exception) {
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
    super.initState();
    Future.delayed(Duration.zero, () async {
      fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0Xff146bf7),
          title: Container(
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
                        sortString = "completed";
                        isVisible = false;
                        isSorted = true;
                        FocusScope.of(context).unfocus();
                        filtered = ticketDetails.where((element) => element.status=='$sortString').toList();
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
                          filtered = ticketDetails.where((element) => element.status=='$sortString').toList();
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
                          filtered = ticketDetails.where((element) => element.status=='$sortString').toList();
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
                          filtered = ticketDetails.where((element) => element.status=='$sortString').toList();
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
                              return ticketDetails[index].username.toLowerCase().contains(searchText.toLowerCase()) ?
                              Column(
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
                                                CircleAvatar(radius: 40,
                                                  backgroundImage: AssetImage(
                                                      'assets/images/loginimg.png'),
                                                ),
                                                ticketDetails[index].status.toLowerCase() ==
                                                    "completed"
                                                    ? Positioned(
                                                    left: 50,
                                                    top: 40,
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors
                                                          .green,
                                                      radius: 8,
                                                    )
                                                ):ticketDetails[index].status.toLowerCase() ==
                                                    "inprogress" ?
                                                Positioned(
                                                    left: 50,
                                                    top: 40,
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors
                                                          .yellowAccent,
                                                      radius: 8,
                                                    )
                                                ) : ticketDetails[index].status.toLowerCase() ==
                                                    "new" ?
                                                Positioned(
                                                    left: 50,
                                                    top: 40,
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors
                                                          .blue,
                                                      radius: 8,
                                                    )
                                                ):ticketDetails[index].status.toLowerCase() ==
                                                    "started" ?
                                                Positioned(
                                                    left: 50,
                                                    top: 40,
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors
                                                          .red,
                                                      radius: 8,
                                                    )
                                                ):SizedBox()
                                              ]
                                          ),
                                        ),
                                        title: Text(ticketDetails[index].username[0].toUpperCase() +ticketDetails[index].username.substring(1), style: TextStyle(
                                            fontSize: 17.5),),
                                        subtitle: Text("Status : "+ticketDetails[index].status),
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
                                return ticketDetails[index].status == sortString ?
                                ticketDetails[index].username.toLowerCase()
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
                                                  CircleAvatar(radius: 40,
                                                    backgroundImage: AssetImage(
                                                        'assets/images/loginimg.png'),
                                                  ),
                                                  ticketDetails[index].status ==
                                                      "completed"
                                                      ? Positioned(
                                                      left: 50,
                                                      top: 40,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .green,
                                                        radius: 8,
                                                      )
                                                  ):ticketDetails[index].status.toLowerCase() ==
                                                      "inprogress" ?
                                                  Positioned(
                                                      left: 50,
                                                      top: 40,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .yellowAccent,
                                                        radius: 8,
                                                      )
                                                  ) : ticketDetails[index].status.toLowerCase() ==
                                                      "new" ?
                                                  Positioned(
                                                      left: 50,
                                                      top: 40,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .blue,
                                                        radius: 8,
                                                      )
                                                  ) : ticketDetails[index].status.toLowerCase() ==
                                                      "started" ? Positioned(
                                                      left: 50,
                                                      top: 40,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .red,
                                                        radius: 8,
                                                      )
                                                  ) : SizedBox()
                                                ]
                                            ),
                                          ),
                                          title: Text(ticketDetails[index].username[0]
                                              .toUpperCase()
                                              +
                                              ticketDetails[index].username.substring(
                                                  1), style: TextStyle(
                                              fontSize: 17.5),),
                                          subtitle: Text("Status : "+ticketDetails[index].status),
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

class GetTicket {
  String ticketsId='';
  String projectCode = '';
  String username='';
  String email='';
  String phonenumber='';
  String domainName='';
  String description='';
  String design='';
  String development='';
  String seo='';
  String server='';
  String status='';
  String screenshots='';
  String notification='';
  String cusCreatedOn='';
  String cusModifiedOn='';
  String admUpdatedOn='';
  String admUpdatedBy='';
  String admModifiedOn='';
  String admModifiedBy='';
  String tmStartUpdatedOn='';
  String tmStartUpdatedBy='';
  String tmStartModifiedOn='';
  String tmStartModifiedBy='';
  String tmProcessUpdatedOn='';
  String tmProcessUpdatedBy='';
  String tmProcessModifiedOn='';
  String tmProcessModifiedBy='';
  String tmCompleteUpdatedOn='';
  String tmCompleteUpdatedBy='';
  String tmCompleteModifiedOn='';
  String tmCompleteModifiedBy='';

  GetTicket(
      {required this.ticketsId,
        required this.username,
        required this.email,
        required this.design,
        required this.development,
        required this.server,
        required this.seo,
        required this.phonenumber,
        required this.projectCode,
        required this.domainName,
        required this.description,
        required this.status,
        required this.screenshots,
        required this.notification,
        required this.cusCreatedOn,
        required this.cusModifiedOn,
        required this.admUpdatedOn,
        required this.admUpdatedBy,
        required this.admModifiedOn,
        required this.admModifiedBy,
        required this.tmStartUpdatedOn,
        required this.tmStartUpdatedBy,
        required this.tmStartModifiedOn,
        required this.tmStartModifiedBy,
        required this.tmProcessUpdatedOn,
        required this.tmProcessUpdatedBy,
        required this.tmProcessModifiedOn,
        required this.tmProcessModifiedBy,
        required this.tmCompleteUpdatedOn,
        required this.tmCompleteUpdatedBy,
        required this.tmCompleteModifiedOn,
        required this.tmCompleteModifiedBy});

  GetTicket.fromJson(Map<String, dynamic> json) {
    ticketsId = json['ticketsId'].toString();
    username = json['Username'].toString();
    email = json['Email'];
    projectCode = json['Projectcode'].toString();
    phonenumber = json['Phonenumber'];
    domainName = json['DomainName'];
    description = json['Description'];
    design = json['Design'];
    development = json['Development'];
    seo = json['Seo'];
    server = json['Server'];
    status = json['Status'].toLowerCase();
    screenshots = json['Screenshots'];
    notification = json['Notification'];
    cusCreatedOn = json['Cus_CreatedOn'];
    cusModifiedOn = json['Cus_ModifiedOn'];
    admUpdatedOn = json['Adm_UpdatedOn'];
    admUpdatedBy = json['Adm_UpdatedBy'];
    admModifiedOn = json['Adm_ModifiedOn'];
    admModifiedBy = json['Adm_ModifiedBy'].toString();
    tmStartUpdatedOn = json['Tm_Start_UpdatedOn'];
    tmStartUpdatedBy = json['Tm_Start_UpdatedBy'];
    tmStartModifiedOn = json['Tm_Start_ModifiedOn'];
    tmStartModifiedBy = json['Tm_Start_ModifiedBy'];
    tmProcessUpdatedOn = json['Tm_Process_UpdatedOn'];
    tmProcessUpdatedBy = json['Tm_Process_UpdatedBy'];
    tmProcessModifiedOn = json['Tm_Process_ModifiedOn'];
    tmProcessModifiedBy = json['Tm_Process_ModifiedBy'];
    tmCompleteUpdatedOn = json['Tm_Complete_UpdatedOn'];
    tmCompleteUpdatedBy = json['Tm_Complete_UpdatedBy'];
    tmCompleteModifiedOn = json['Tm_Complete_ModifiedOn'];
    tmCompleteModifiedBy = json['Tm_Complete_ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ticketsId'] = this.ticketsId.toString();
    data['Username'] = this.username;
    data['Email'] = this.email;
    data['Phonenumber'] = this.phonenumber;
    data['DomainName'] = this.domainName;
    data['Description'] = this.description;
    data['Design'] = this.design;
    data['Development'] = this.development;
    data['Seo'] = this.seo;
    data['Server'] = this.server;
    data['Status'] = this.status;
    data['Screenshots'] = this.screenshots;
    data['Notification'] = this.notification;
    data['Cus_CreatedOn'] = this.cusCreatedOn;
    data['Cus_ModifiedOn'] = this.cusModifiedOn;
    data['Adm_UpdatedOn'] = this.admUpdatedOn;
    data['Adm_UpdatedBy'] = this.admUpdatedBy;
    data['Adm_ModifiedOn'] = this.admModifiedOn;
    data['Adm_ModifiedBy'] = this.admModifiedBy;
    data['Tm_Start_UpdatedOn'] = this.tmStartUpdatedOn;
    data['Tm_Start_UpdatedBy'] = this.tmStartUpdatedBy;
    data['Tm_Start_ModifiedOn'] = this.tmStartModifiedOn;
    data['Tm_Start_ModifiedBy'] = this.tmStartModifiedBy;
    data['Tm_Process_UpdatedOn'] = this.tmProcessUpdatedOn;
    data['Tm_Process_UpdatedBy'] = this.tmProcessUpdatedBy;
    data['Tm_Process_ModifiedOn'] = this.tmProcessModifiedOn;
    data['Tm_Process_ModifiedBy'] = this.tmProcessModifiedBy;
    data['Tm_Complete_UpdatedOn'] = this.tmCompleteUpdatedOn;
    data['Tm_Complete_UpdatedBy'] = this.tmCompleteUpdatedBy;
    data['Tm_Complete_ModifiedOn'] = this.tmCompleteModifiedOn;
    data['Tm_Complete_ModifiedBy'] = this.tmCompleteModifiedBy;
    return data;
  }
}

