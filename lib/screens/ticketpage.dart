import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/ticketview.dart';
import 'package:mmcustomerservice/test_screen.dart';
import 'package:mmcustomerservice/ticketsModel.dart';
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
  List<sampleTickets> ticketDetails = [];
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
    pref.setString("tickId", ticketDetails[index].tickets!.ticketsId.toString());
    pref.setString("UserName", ticketDetails[index].tickets!.username.toString());
    pref.setString("MailID", ticketDetails[index].tickets!.email.toString());
    pref.setString("PhoneNum", ticketDetails[index].tickets!.phonenumber.toString());
    pref.setString("DomainNm", ticketDetails[index].tickets!.domainName.toString());
    pref.setString("Desc", ticketDetails[index].tickets!.description.toString());
    pref.setString("Statuses", ticketDetails[index].tickets!.status.toString());
    pref.setString("Notify", ticketDetails[index].tickets!.notification.toString());
    pref.setString("cusCreatedOn", ticketDetails[index].tickets!.cusCreatedOn.toString());
    pref.setString("cusModifiedOn", ticketDetails[index].tickets!.cusModifiedOn.toString());
    pref.setString("admCreatedOn", ticketDetails[index].tickets!.admCreatedOn.toString());
    pref.setString("admCreatedBy", ticketDetails[index].tickets!.admCreatedBy.toString());
    pref.setString("admModifiedOn", ticketDetails[index].tickets!.admModifiedOn.toString());
    pref.setString("admModifiedBy", ticketDetails[index].tickets!.admModifiedBy.toString());
    pref.setString("admUpdatedOn", ticketDetails[index].tickets!.admUpdatedOn.toString());
    pref.setString("admUpdatedBy", ticketDetails[index].tickets!.admUpdatedBy.toString());
    pref.setString("tmStartUpdatedOn", ticketDetails[index].tickets!.tmStartUpdatedOn.toString());
    pref.setString("tmStartUpdatedBy", ticketDetails[index].tickets!.tmStartUpdatedBy.toString());
    pref.setString("tmStartModifiedOn", ticketDetails[index].tickets!.tmStartModifiedOn.toString());
    pref.setString("tmStartModifiedBy", ticketDetails[index].tickets!.tmStartModifiedBy.toString());
    pref.setString("tmProcessUpdatedOn", ticketDetails[index].tickets!.tmProcessUpdatedOn.toString());
    pref.setString("tmProcessUpdatedBy", ticketDetails[index].tickets!.tmProcessUpdatedBy.toString());
    pref.setString("tmProcessModifiedOn", ticketDetails[index].tickets!.tmProcessModifiedOn.toString());
    pref.setString("tmProcessModifiedBy", ticketDetails[index].tickets!.tmProcessModifiedBy.toString());
    pref.setString("tmCompleteUpdatedOn", ticketDetails[index].tickets!.tmCompleteUpdatedOn.toString());
    pref.setString("tmCompleteUpdatedBy", ticketDetails[index].tickets!.tmCompleteUpdatedBy.toString());
    pref.setString("tmCompleteModifiedOn", ticketDetails[index].tickets!.tmCompleteModifiedOn.toString());
    pref.setString("tmCompleteModifiedBy", ticketDetails[index].tickets!.tmCompleteModifiedBy.toString());



    Navigator.push(context,MaterialPageRoute(builder: (context)=>TicketViewPage()));

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
          ticketDetails = body.map((e) => sampleTickets.fromJson(e)).toList();
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
    print(usertype);
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
                        filtered = ticketDetails.where((element) => element.tickets!.status=='$sortString').toList();
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
                          filtered = ticketDetails.where((element) => element.tickets!.status=='$sortString').toList();
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
                          filtered = ticketDetails.where((element) =>element.tickets!.status=='$sortString').toList();
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
                          filtered = ticketDetails.where((element) => element.tickets!.status=='$sortString').toList();
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
                                ticketDetails[index].tickets!.username!.toLowerCase().
                                contains(searchText.toLowerCase()) ?
                              Column(
                                  children: <Widget>[
                                    Container(
                                      height: 70,
                                      child: ListTile(
                                        onLongPress: (){
                                          Navigator.push(context,MaterialPageRoute(builder: (context)
                                              => Test()
                                          ));
                                        },
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
                                                ticketDetails[index].tickets!.status!.toLowerCase() ==
                                                    "completed"
                                                    ? Positioned(
                                                    left: 50,
                                                    top: 40,
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors
                                                          .green,
                                                      radius: 8,
                                                    )
                                                ):ticketDetails[index].tickets!.status!.toLowerCase() ==
                                                    "inprogress" ?
                                                Positioned(
                                                    left: 50,
                                                    top: 40,
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors
                                                          .yellowAccent,
                                                      radius: 8,
                                                    )
                                                ) : ticketDetails[index].tickets!.status!.toLowerCase() ==
                                                    "new" ?
                                                Positioned(
                                                    left: 50,
                                                    top: 40,
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors
                                                          .blue,
                                                      radius: 8,
                                                    )
                                                ):ticketDetails[index].tickets!.status!.toLowerCase() ==
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
                                        title: Text(ticketDetails[index].tickets!.username![0].toUpperCase()
                                            + ticketDetails[index].tickets!.username!.substring(1), style: TextStyle(
                                            fontSize: 17.5),),
                                        subtitle: Text("Status : "+ticketDetails[index].tickets!.status!),
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
                                return ticketDetails[index].tickets!.status! == sortString ?
                                ticketDetails[index].tickets!.username!.toLowerCase()
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
                                                  ticketDetails[index].tickets!.status! ==
                                                      "completed"
                                                      ? Positioned(
                                                      left: 50,
                                                      top: 40,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .green,
                                                        radius: 8,
                                                      )
                                                  ):ticketDetails[index].tickets!.status!.toLowerCase() ==
                                                      "inprogress" ?
                                                  Positioned(
                                                      left: 50,
                                                      top: 40,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .yellowAccent,
                                                        radius: 8,
                                                      )
                                                  ) : ticketDetails[index].tickets!.status!.toLowerCase() ==
                                                      "new" ?
                                                  Positioned(
                                                      left: 50,
                                                      top: 40,
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors
                                                            .blue,
                                                        radius: 8,
                                                      )
                                                  ) : ticketDetails[index].tickets!.status!.toLowerCase() ==
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
                                          title: Text(ticketDetails[index].tickets!.username![0]
                                              .toUpperCase()
                                              +
                                              ticketDetails[index].tickets!.username!.substring(
                                                  1), style: TextStyle(
                                              fontSize: 17.5),),
                                          subtitle: Text("Status : "+ticketDetails[index].tickets!.status!),
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

