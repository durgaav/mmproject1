import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mmcustomerservice/screens/data.dart';
import 'package:mmcustomerservice/ticketsModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart' as fileOpen;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketViewPage extends StatefulWidget {
  List<TeamAssign> tmAssignList = [];
  List teamsList = [];
  List teamsNamelist = [];
  TicketViewPage({required this.tmAssignList, required this.teamsNamelist});

  @override
  _TicketViewPageState createState() => _TicketViewPageState(
      tmAssignList: tmAssignList, teamsNamelist: teamsNamelist);
}

class _TicketViewPageState extends State<TicketViewPage> {
  List<TeamAssign> tmAssignList = [];
  List teamsNamelist = [];
  _TicketViewPageState(
      {required this.tmAssignList, required this.teamsNamelist});

  //region Strings
  String ticketId = '';
  String Notification = '';
  String Username = '';
  String Email = '';
  String Phonenumber = '';
  String DomainName = '';
  String CusCreatedOn = '';
  String Description = '';
  String Team = '';
  String Status = '';
  String Screenshots = '';
  String statusUpdateTime = '';
  String createdOn = '',
      adm_updte_on = '',
      adm_update_by = '',
      adm_modify_on = '',
      adm_mod_by = "";
  String tm_startupdateon = "",
      tm_startupdateBy = "",
      tm_startModon = "",
      tm_startModBy = "",
      tm_procesupdOn = "",
      tm_procesupdBy = "",
      tm_procesModOn = "",
      tm_procesModBy = "",
      tm_cmpleUpdOn = '',
      tm_compleupBy = '',
      tm_CompModOn = "",
      tm_CompModby = "",
      projectCode = "";
  String server = '', seo = '', design = '', development = '';
  //endregion Strings

  //region Variables
  List<TeamAssign> teams = [];
  List getName = [];
  List<int> teamsIndex = [];
  String dropdownValue = "Design";
  final List<String> datas = ["SEO", "Design", "Development", "Server"];
  String dropdown = "Inprogress";
  bool tmStatusBtn = false;
  String createdBy = '';
  String userType = '';
  bool floatBtnVisi = false;
  String statusVal = 'Started';
  String alertText = 'Updating...';
  bool adDateVisi = false;
  final List<String> status = ["Completed", "Inprogress", "Started"];
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
  int _total = 0, _received = 0;
  final List<int> _bytes = [];
  bool checkDesign = false;
  List emptyList = [];
  bool checkDev = false;
  bool checkSer = false;
  bool checkSeo = false;
  bool _loading = false;
  String currentUser = '';
  double _progressValue = 0.0;
  List filteredby = [];
  List<String> fromAPI = [];
  String teamId = "0";
  List<bool> teamCheck = [];
  List teamsId = [];
  List ids = [];
  List idList = [];
  var contextTeam = [];
  List userNames = [];
  //endregion Variables

  //region Dialogs

  Future<void> updateStatusDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Container(
              width: double.infinity,
              child: AlertDialog(
                  scrollable: true,
                  content: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Update status',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close),
                              color: Colors.red,
                              iconSize: 25,
                            ),
                          ))
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'STATUS UPDATE TICKET $ticketId',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10, left: 10),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: DropdownButtonFormField(
                          value: statusVal,
                          items: status
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              statusVal = newValue!;
                            });
                          },
                          hint: Text("SELECT"),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(right: 10, top: 10),
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: RaisedButton(
                              onPressed: () {
                                statusUpdate(ticketId, statusVal);
                              },
                              color: Colors.blue,
                              child: Text(
                                'Update',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ))),
                    ],
                  )));
        });
  }

  void completeMailAlert(){
    showDialog(context: context, builder: (context){
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)
        ),
        child: Container(
          height: 290,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10))
                ),
                padding: EdgeInsets.all(15),
                alignment: Alignment.centerLeft,
                child: Text('Mail sender' , style: TextStyle(
                  fontSize: 20 , fontWeight: FontWeight.bold,color: Colors.white
                ),),
              ),
              Container(
                padding: EdgeInsets.all(14),
                child: Text('Do you want to send complete mail'
                    ' to this ticket ($ticketId)?' , style: TextStyle(
                    fontSize: 17 , fontWeight: FontWeight.bold
                ),),
              ),
              Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      child: RaisedButton(
                          color: Colors.green,
                          onPressed: (){
                            Navigator.pop(context);
                            sendCompleteMail();
                            },
                          child: Row(
                            children: [
                              Icon(Icons.mail_outline , color: Colors.white,),
                              Text(' SEND' , style: TextStyle(color: Colors.white),)
                            ],
                          ),
                      ),
                    ),
                    Container(
                      width: 150,
                      child: RaisedButton(
                          color: Colors.red,
                          onPressed: (){Navigator.pop(context);},
                          child: Row(
                            children: [
                              Icon(Icons.close_outlined , color: Colors.white,),
                              Text(' CANCEL' , style: TextStyle(color: Colors.white),)
                            ],
                          ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  showAlert(BuildContext context, String alertText) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              Text(' $alertText'),
            ],
          ));
        });
  }

  Future<void> sendCompleteMail() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sending mail...'),
      )
    );

    try{
      String username = 'durgadevi@mindmade.in';
      String password = 'Appu#001';
      final smtpServer = gmail(username, password);

      final equivalentMessage = Message()
        ..from = Address(username, 'DurgaDevi')
        ..recipients.add(Address('durgavenkatesh805@gmail.com'))
        ..ccRecipients.addAll([
          Address('surya@mindmade.in'),
        ])
      // ..bccRecipients.add('bccAddress@example.com')
        ..subject = 'Ticket completed ${formatter.format(DateTime.now())}'
        ..text = 'Dear Sir/Madam,n\n'
            'Greetings from MindMade Customer Support Team!!! \n\n'
            "We're reaching out to you in regards to the ticket (#$ticketId) we completed for you.\n\n"
            "Don't hesitate to contact us if you have questions or concerns.\n\n"
            "Thanks & Regards,\nMindMade";
      try {
        await send(equivalentMessage, smtpServer);
        print('Message sent: ' + send.toString());
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(' Mail Sent!'),
              backgroundColor: Colors.green,
            )
        );
      } on MailerException catch (e) {
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Something went wrong!'),
                backgroundColor: Colors.red[200],
              )
          );
        }
      }
    }catch(error){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong!'),
            backgroundColor: Colors.red,
          )
      );
    }

  }

  Future<void> sendAssignMail() async{

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sending Mail To Team(s)....'),
        )
    );

    try{
      String username = 'durgadevi@mindmade.in';
      String password = 'Appu#001';
      final smtpServer = gmail(username, password);
      final equivalentMessage = Message()
        ..from = Address(username, 'DurgaDevi')
        ..recipients.add(Address('durgavenkatesh805@gmail.com'))
        ..ccRecipients.addAll([
          Address('surya@mindmade.in'),
        ])
      // ..bccRecipients.add('bccAddress@example.com')
        ..subject = 'Mindmade Ticket Assign (${formatter.format(DateTime.now())})'
        ..text = "Dear Sir/Madam,\n\nGreetings from MindMade Customer Support Team!!! \n\n"
            "Ticket(${ticketId}) have been assigned to you.kindly check the ticket details in Mindmade Customer Support portal.\n\n"
            "Thanks & Regards, \nMindmade\n";
      try {
        await send(equivalentMessage, smtpServer);
        print('Message sent: ' + send.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.mail_outline,
                color: Colors.white,
              ),
              Text('  Mail sent!'),
            ],
          ),
          backgroundColor: Color(0xff198D0F),
          behavior: SnackBarBehavior.floating,
        ));
      } on MailerException catch (e) {
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.close_outlined,
                  color: Colors.white,
                ),
                Text('  Mail send failed!'),
              ],
            ),
            backgroundColor:Colors.red[200],
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    }catch(ex){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong!'),
            backgroundColor: Colors.red,
          )
      );
    }

  }

  void confirmDialogTeamRe(){
    showDialog(
        context: context,
        builder: (context) {
          return Container(
              child: AlertDialog(
                title: Row(
                  children: <Widget>[
                    Icon(
                      Icons.warning_outlined,
                      color: Colors.red,
                      size: 25,
                    ),
                    Text('  Alert!',
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ],
                ),
                content: Text(
                  'Are you sure? Assigned teams will be removed.!',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text('cancel',
                          style: TextStyle(fontSize: 16, color: Colors.blue))),
                  FlatButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        reAssignTeam();
                      },
                      child: Text('Re Assign',
                          style: TextStyle(fontSize: 16, color: Colors.red)))
                ],
              ));
        });
  }
  //endregion Dialogs

  //File dwnld
  Future<String> downloadFile(String url, String fileName, String dir) async {
    showAlert(context, " Downloading...");
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';
    try {
      myUrl = url;
      print(myUrl);
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        print(fileName);
        print(filePath);
        await file.writeAsBytes(bytes);

        Navigator.pop(context);
        fileOpen.OpenFile.open(filePath);
        Fluttertoast.showToast(
            msg: 'Download successfully',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 15.0);
      } else {
        onNetworkChecking();
        Fluttertoast.showToast(
            msg: 'Download Failed',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
        Navigator.pop(context);
        filePath = 'Error code: ' + response.statusCode.toString();
      }
    } catch (ex) {
      print(ex);
      onNetworkChecking();
      Navigator.pop(context);
    }
    return filePath;
  }

  Future<void> assignTeam(String tickid, List teamsIds) async {
    showAlert(context, " Please wait...");
    print(teamsIds);
    try{
      http.Response res = await http.post(
        Uri.parse('https://mindmadetech.in/api/tickets/team/update'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "ticketsId": tickid.toString(),
          "Adm_UpdatedOn": formatter.format(DateTime.now()),
          "Adm_UpdatedBy": currentUser,
          "teamId": teamsIds
        }),
      );
      if (res.statusCode == 200) {
        if (res.body
            .contains("Ticket assigned successfully")) {
          Navigator.pop(context);
          setState(() {
            sendAssignMail();
            teamsId = teamsId + ids;
            ids = [];
            ids = ids + teamsId;
            ids = ids.toSet().toList();
            for (int i = 0; i < ids.length; i++) {
              teamsIndex.add(teamsNamelist.indexWhere((element) =>
              element['teamId'].toString() == ids[i].toString()));
            }
            teamsIndex.removeWhere((element) => element == -1);
            teamsIndex = teamsIndex.toSet().toList();
            print(teamsIndex);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.done_all,
                  color: Colors.white,
                ),
                Text('  Team assigned!'),
              ],
            ),
            backgroundColor: Color(0xff198D0F),
            behavior: SnackBarBehavior.floating,
          ));
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.wifi_outlined,
                  color: Colors.white,
                ),
                Text('  Error occurred!'),
              ],
            ),
            backgroundColor: Color(0xffE33C3C),
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        print(res.body);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.wifi_outlined,
                color: Colors.white,
              ),
              Text('  Error occurred!'),
            ],
          ),
          backgroundColor: Color(0xffE33C3C),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }catch(error){
      //my code
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.wifi_outlined,
              color: Colors.white,
            ),
            Text('  Something went wrong!'),
          ],
        ),
        backgroundColor: Color(0xffE33C3C),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  //Status update tm
  Future<void> statusUpdate(String id, String val) async {
    var pref = await SharedPreferences.getInstance();
    String assignId = pref.getString('tickAssignId') ?? '';
    print("Id..............." + assignId);
    showAlert(context, "Updating...");
    String fieldOn = '', fieldBy = '';
    if (val == 'Inprogress') {
      setState(() {
        fieldOn = "Tm_Process_UpdatedOn";
        fieldBy = 'Tm_Process_UpdatedBy';
      });
    }
    if (val == 'Started') {
      setState(() {
        fieldOn = "Tm_Start_UpdatedOn";
        fieldBy = 'Tm_Start_UpdatedBy';
      });
    }
    if (val == 'Completed') {
      setState(() {
        fieldOn = "Tm_Complete_UpdatedOn";
        fieldBy = 'Tm_Complete_UpdatedBy';
      });
    }

    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('PUT',
          Uri.parse('https://mindmadetech.in/api/tickets/status/update'));
      request.body = json.encode({
        "Status": val.toLowerCase(),
        "ticketsId": ticketId,
        "tickets_assignId": tmAssignList[0].ticketsAssignId,
        fieldOn: formatter.format(DateTime.now()),
        fieldBy: currentUser
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: 'Status updated!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 15.0);
        Navigator.pop(context);
        setState(() {
          if (val == "Started") {
            Status = 'started';
            tm_startupdateon = formatter.format(DateTime.now());
            tm_startupdateBy = createdBy;
          } else if (val == "Inprogress") {
            Status = 'inprogress';
            tm_procesupdOn = formatter.format(DateTime.now());
            tm_procesupdBy = createdBy;
          } else {
            Status = 'completed';
            tm_cmpleUpdOn = formatter.format(DateTime.now());
            tm_compleupBy = createdBy;
          }
        });
      } else {
        onNetworkChecking();
        Navigator.pop(context);
        print(response.reasonPhrase);
        Fluttertoast.showToast(
            msg: 'Something went wrong!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
        Navigator.pop(context);
      }
    } catch (ex) {
      onNetworkChecking();
      Navigator.pop(context);
    }
  }

  //Getting login prefs
  Future<void> getPref() async {
    var pref = await SharedPreferences.getInstance();
    print(pref.getString("usertypeMail"));
    createdBy = pref.getString('usertypeMail') ?? '';
    userType = pref.getString("usertype") ?? '';
    if (userType == "admin") {
      setState(() {
        floatBtnVisi = true;
        tmStatusBtn = false;
        adDateVisi = false;
      });
    } else if (userType == "team") {
      setState(() {
        tmStatusBtn = true;
        adDateVisi = true;
      });
    } else {
      setState(() {
        tmStatusBtn = false;
        adDateVisi = true;
      });
    }
    print("Created by = " + createdBy);
    print(userType);
  }

  Future<void> reAssignTeam() async{
    showAlert(context, "Please wait...");
    http.Response response = await http.put(
        Uri.parse('https://mindmadetech.in/api/tickets/team/reassign'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "ticketsId" : "$ticketId",
          "Adm_ModifiedOn" :formatter.format(DateTime.now()),
          "Adm_ModifiedBy" : "$currentUser",
          "Isdeleted" : "y"
      }),
    );
    if(response.statusCode==200){
      Navigator.pop(context);
      if(response.body.contains("Team array's data are temporarily deleted")){
        setState(() {
          ids = [];
          teamsIndex = [];
          print("here is idss..."+ids.toString() + teamsIndex.toString());

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.done_all,
                  color: Colors.white,
                ),
                Text('  Assigned teams removed!'),
              ],
            ),
            backgroundColor: Color(0xff198D0F),
            behavior: SnackBarBehavior.floating,
          ));

        });
      }else{
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.done_all,
                color: Colors.white,
              ),
              Text('  Failed to Re-assign!'),
            ],
          ),
          backgroundColor:Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }else{
      Navigator.pop(context);
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.done_all,
              color: Colors.white,
            ),
            Text('  Something went wrong!'),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  //Loading previous screen data
  Future<void> loadGivenData() async {
    var pref = await SharedPreferences.getInstance();

    setState(() {
      currentUser = pref.getString('usertypeMail') ?? '';
      teams = tmAssignList.toList();
      fromAPI = pref.getStringList('Files')!;
      server = pref.getString('server') ?? '';
      seo = pref.getString('seo') ?? '';
      design = pref.getString('design') ?? '';
      development = pref.getString('development') ?? '';
      ticketId = pref.getString("tickId") ?? '';
      Username = pref.getString("UserName") ?? '';
      Email = pref.getString("MailID") ?? '';
      Phonenumber = pref.getString("PhoneNum") ?? '';
      DomainName = pref.getString("DomainNm") ?? '';
      Description = pref.getString("Desc") ?? '';
      Status = pref.getString("Statuses") ?? '';
      Notification = pref.getString("Notify") ?? '';
      createdOn = pref.getString("cusCreatedOn") ?? '';
      // pref.getString("cusModifiedOn")??'';
      adm_updte_on = pref.getString("admCreatedOn") ?? '';
      adm_update_by = pref.getString("admUpdatedBy") ?? '';
      adm_modify_on = pref.getString("admModifiedOn") ?? '';
      adm_mod_by = pref.getString("admModifiedBy") ?? '';
      adm_updte_on = pref.getString("admUpdatedOn") ?? '';
      adm_mod_by = pref.getString("admUpdatedBy") ?? '';
      tm_startupdateon = pref.getString("tmStartUpdatedOn") ?? '';
      tm_startupdateBy = pref.getString("tmStartUpdatedBy") ?? '';
      tm_startModon = pref.getString("tmStartModifiedOn") ?? '';
      tm_startModBy = pref.getString("tmStartModifiedBy") ?? '';
      tm_procesupdOn = pref.getString("tmProcessUpdatedOn") ?? '';
      tm_procesupdBy = pref.getString("tmProcessUpdatedBy") ?? '';
      tm_procesModOn = pref.getString("tmProcessModifiedOn") ?? '';
      tm_procesModBy = pref.getString("tmProcessModifiedBy") ?? '';
      tm_cmpleUpdOn = pref.getString("tmCompleteUpdatedOn") ?? '';
      tm_compleupBy = pref.getString("tmCompleteUpdatedBy") ?? '';
      tm_startModon = pref.getString("tmCompleteModifiedOn") ?? '';
      tm_startModBy = pref.getString("tmCompleteModifiedBy") ?? '';
    });
  }

  //Network
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

  void showTeamsBottom() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (context) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Team Select',
                      style: TextStyle(fontSize: 20),
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      color: Colors.deepPurple,
                      onPressed: () {
                        if (teamsId.isEmpty) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.close_outlined,
                                  color: Colors.white,
                                ),
                                Text('  Please select at least one member!'),
                              ],
                            ),
                            backgroundColor: Color(0xffE33C3C),
                            behavior: SnackBarBehavior.floating,
                          ));
                        } else {
                          Navigator.pop(context);
                          assignTeam(ticketId, teamsId);
                        }
                      },
                      child: Text(
                        'Assign Now !',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      // icon: Icon(Icons.close_rounded,color:Colors.red,size: 30,)
                    )
                  ],
                ),
              ),
              Container(
                  height: 350,
                  padding: EdgeInsets.all(8),
                  child: StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return Scrollbar(
                        isAlwaysShown: true,
                        child: ListView.builder(
                            itemCount: teamsNamelist.length,
                            itemBuilder: (context, index) {
                              teamCheck.add(false);
                              return Column(
                                children: [
                                  CheckboxListTile(
                                    subtitle: Text(teamsNamelist[index]['Team']
                                        .toString()+" "+teamsNamelist[index]['teamId'].toString()),
                                    title: Text(teamsNamelist[index]['Email']
                                        .toString()),
                                    autofocus: false,
                                    checkColor: Colors.white,
                                    activeColor: Colors.green,
                                    selected: teamCheck[index],
                                    value: teamCheck[index],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (teamCheck[index] == true) {
                                          teamCheck[index] = false;
                                          teamsId.removeWhere((element) =>
                                              element ==
                                              teamsNamelist[index]['teamId']
                                                  .toString());
                                        } else {
                                          teamCheck[index] = true;
                                          if (teamsId.contains(
                                              teamsNamelist[index]['teamId']
                                                  .toString())) {
                                            print('exists...');
                                          } else {
                                            teamsId.add(teamsNamelist[index]
                                                    ['teamId']
                                                .toString());
                                          }
                                        }
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Divider(
                                      height: 0.5,
                                      color: Colors.blueAccent,
                                    ),
                                  )
                                ],
                              );
                            }),
                      );
                    },
                  )),
            ],
          );
        });
  }

  void loadAssignedTeam() {
    // if(teams.isEmpty){
    //   print('empty assign...');
    // }else{
    setState(() {
      for (int i = 0; i < teams.length; i++) {
        ids.add(teams[i].teamId);
      }
      ids = ids.toSet().toList();

      for (int i = 0; i < ids.length; i++) {
        teamsIndex.add(teamsNamelist.indexWhere(
                (element) => element['teamId'].toString() == ids[i].toString()));
      }
      teamsIndex.removeWhere((element) => element == -1);
      teamsIndex = teamsIndex.toSet().toList();
    });

  }

  //endregion Functions
  @override
  void initState() {
// TODO: implement initState
    super.initState();
    getPref();
    loadGivenData();
    () async {
      var _permissionStatus = await Permission.storage.status;
      if (_permissionStatus != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        setState(() {
          _permissionStatus = permissionStatus;
        });
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    loadAssignedTeam();
    return Scaffold(
        //APP bar
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){Navigator.pop(context);},
            icon:Icon(CupertinoIcons.back),
            iconSize: 30,
            splashColor: Colors.purpleAccent,
          ),
          centerTitle: true,
          backgroundColor: Color(0Xff146bf7),
          title: Text('Ticket ID : $ticketId'),
        ),
        floatingActionButton: this.Status.toLowerCase() == "completed"
            ? Visibility(
                visible: floatBtnVisi,
                child: FloatingActionButton(
                  child: Icon(Icons.mail),
                  onPressed: () {
                    completeMailAlert();
                    //Mail send
                    //mailDialog(context);
                    // sendMail();
                  },
                ),
              )
            : tmStatusBtn == true
                ? Visibility(
                    visible: tmStatusBtn,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        updateStatusDialog(context);
                      },
                      label: Text('Update status'),
                      icon: Icon(Icons.thumb_up),
                    ))
                : Visibility(
                    visible: floatBtnVisi,
                    child: FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        showTeamsBottom();
                      },
                    ),
                  ),
        body: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.all(7.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            Card(
              color: Colors.blue[100],
              elevation: 3,
              child: Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                padding: EdgeInsets.all(7.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Status.toLowerCase() == 'completed'
                            ? Icon(
                                Icons.done_all,
                                size: 30,
                                color: Colors.green,
                              )
                            : Status.toLowerCase() == 'new'
                                ? Icon(
                                    Icons.bookmark_add,
                                    size: 30,
                                    color: Colors.blueAccent,
                                  )
                                : Status.toLowerCase() == 'started'
                                    ? Icon(
                                        Icons.cached_sharp,
                                        size: 30,
                                        color: Colors.red,
                                      )
                                    : Status.toLowerCase() == 'inprogress'
                                        ? Icon(
                                            CupertinoIcons.clock,
                                            size: 30,
                                            color: Colors.deepPurpleAccent,
                                          )
                                        : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '  $Status',
                          style: TextStyle(fontSize: 18, letterSpacing: 1),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Card(
              elevation: 3,
              child: ExpansionTile(
                leading: Icon(
                  Icons.thumb_up,
                  size: 30,
                  color: Colors.orangeAccent,
                ),
                title: Text(
                  'Teams Assigned',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Click for more...',
                  style: TextStyle(fontSize: 15, color: Colors.black45),
                ),
                children: <Widget>[
                  ids.isNotEmpty?
                  userType=="admin"?TextButton(
                      onPressed: () {
                        setState(() {
                          confirmDialogTeamRe();
                          // ids = [];
                          // teamsIndex = [];
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.how_to_reg_outlined,
                            color: Colors.black,
                            size: 25,
                          ),
                          Text(
                            ' Undo Assign!',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                    ):
                  Container():Container(),
                  ids.isNotEmpty
                      ? ListView.builder(
                          itemCount: teamsIndex.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            String userName = teamsNamelist[teamsIndex[index]]
                                    ["Email"]
                                .toString();
                            return Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    child: Text(userName[0].toUpperCase()),
                                  ),
                                  title: Text(
                                    userName,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Divider(
                                    height: 0.5,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            );
                          })
                      : Container(
                          height: 50,
                          child: Center(child: Text('No teams assigned...!',style: TextStyle(fontSize: 20),)),
                        ),
                ],
              ),
            ),
            Card(
              elevation: 3,
              child: ExpansionTile(
                leading: Icon(
                  Icons.account_circle,
                  size: 35,
                  color: Colors.green,
                ),
                title: Text(
                  'Customer Info',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '$Email',
                  style: TextStyle(fontSize: 15, color: Colors.black45),
                ),
                children: <Widget>[
                  ListTile(
                    title: Text('Mail Id',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$Email',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  ListTile(
                    title: Text('Phone',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$Phonenumber',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        launch("tel://$Phonenumber");
                      },
                      icon: Icon(Icons.phone),
                      color: Colors.green,
                      iconSize: 30,
                    ),
                  ),
                  ListTile(
                    title: Text('Email',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$Email',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  ListTile(
                    title: Text('Domain name',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$DomainName',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        if (DomainName.startsWith("http")) {
                          if (await canLaunch(DomainName)) {
                            await launch(DomainName);
                          } else {
                            throw 'Could not launch $DomainName';
                          }
                        } else {
                          if (await canLaunch("https://" + DomainName)) {
                            await launch("https://" + DomainName);
                          } else {
                            throw 'Could not launch $DomainName';
                          }
                        }
                      },
                      icon: Icon(Icons.language),
                      color: Colors.green,
                      iconSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: adDateVisi,
              child: Card(
                elevation: 3,
                child: ExpansionTile(
                  leading: Icon(
                    Icons.calendar_today,
                    size: 35,
                    color: Colors.grey,
                  ),
                  title: Text(
                    'Admin Updates',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Click for more...',
                    style: TextStyle(fontSize: 15, color: Colors.black45),
                  ),
                  children: <Widget>[
                    ListTile(
                      title: Text('Admin updated on',
                          style:
                              TextStyle(fontSize: 15, color: Colors.black45)),
                      subtitle: Text(
                        '$adm_updte_on',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    ListTile(
                      title: Text('Updated by',
                          style:
                              TextStyle(fontSize: 15, color: Colors.black45)),
                      subtitle: Text(
                        '$adm_update_by',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 3,
              child: ExpansionTile(
                leading: Icon(
                  Icons.bug_report_rounded,
                  size: 35,
                  color: Colors.red,
                ),
                title: Text(
                  'Customer Issues',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Click for more...',
                  style: TextStyle(fontSize: 15, color: Colors.black45),
                ),
                children: <Widget>[
                  ListTile(
                    title: Text('Description',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$Description',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  ListTile(
                    title: Text('Ticket created on',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$createdOn',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              elevation: 3,
              child: ExpansionTile(
                leading: Icon(
                  Icons.attach_file,
                  size: 35,
                  color: Colors.blue,
                ),
                title: Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Click for more...',
                  style: TextStyle(fontSize: 15, color: Colors.black45),
                ),
                children: <Widget>[
                  fromAPI.isNotEmpty
                      ? ListView.builder(
                          itemCount: fromAPI.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                String filename = Screenshots.split("/").last;
                                setState(() {
                                  downloadFile(
                                      fromAPI[index],
                                      fromAPI[index].split("/").last,
                                      'storage/emulated/0/Download');
                                });
                              },
                              subtitle: Text(
                                '${fromAPI[index].split("/").last}',
                                style: TextStyle(fontSize: 14),
                              ),
                              title: Text(
                                'Download file',
                                style: TextStyle(fontSize: 16),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  String filename = Screenshots.split("/").last;
                                  setState(() {
                                    downloadFile(
                                        fromAPI[index],
                                        fromAPI[index].split("/").last,
                                        'storage/emulated/0/Download');
                                  });
                                },
                                icon: Icon(Icons.cloud_download),
                                color: Colors.blue,
                                iconSize: 40,
                              ),
                            );
                          })
                      : Container(
                          height: 50,
                          child: Center(child: Text('No attachments found...')),
                        )
                ],
              ),
            ),
            Card(
              elevation: 3,
              child: ExpansionTile(
                leading: Icon(
                  CupertinoIcons.clock,
                  size: 35,
                  color: Colors.indigo,
                ),
                title: Text(
                  'Team Timelines',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Click for more...',
                  style: TextStyle(fontSize: 15, color: Colors.black45),
                ),
                children: <Widget>[
                  // userType=='admin'?Column(
                  //   children: [
                  //     Text('Assigned Teams', style: TextStyle(fontSize: 17.0)),
                  //     SizedBox(height: 10,),
                  //     Container(
                  //       child: Table(
                  //         defaultColumnWidth: FixedColumnWidth(90.0),
                  //         border: TableBorder.all(
                  //             color: Colors.black,
                  //             style: BorderStyle.solid,
                  //             width: 1),
                  //         children: [
                  //           TableRow( children: [
                  //             Column(children:[Text('Server', style: TextStyle(fontSize: 13.0))]),
                  //             Column(children:[Text('SEO', style: TextStyle(fontSize: 13.0))]),
                  //             Column(children:[Text('Design', style: TextStyle(fontSize: 13.0))]),
                  //             Column(children:[Text('Development', style: TextStyle(fontSize: 13.0))]),
                  //           ]),
                  //           TableRow( children: [
                  //             Column(children:[
                  //               server=="y"?Icon(Icons.done,color: Colors.green,):
                  //                       Icon(Icons.close,color: Colors.red,)
                  //             ]),
                  //             Column(children:[seo=="y"?Icon(Icons.done,color: Colors.green,):
                  //             Icon(Icons.close,color: Colors.red,)]),
                  //             Column(children:[design=="y"?Icon(Icons.done,color: Colors.green,):
                  //             Icon(Icons.close,color: Colors.red,)]),
                  //             Column(children:[development=="y"?Icon(Icons.done,color: Colors.green,):
                  //             Icon(Icons.close,color: Colors.red,)]),
                  //           ]),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ):Container(),
                  ListTile(
                    title: Text('Team Started On',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$tm_startupdateon',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  ListTile(
                    title: Text('Started By',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$tm_startupdateBy',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  ListTile(
                    title: Text('Team Updates On',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$tm_procesupdOn',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  ListTile(
                    title: Text('Updates By',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$tm_procesupdBy',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  ListTile(
                    title: Text('Team Completed On',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$tm_cmpleUpdOn',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  ListTile(
                    title: Text('Completed By',
                        style: TextStyle(fontSize: 15, color: Colors.black45)),
                    subtitle: Text(
                      '$tm_compleupBy',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),

                  // ListTile(
                  //   title: Text('Started modified on',style: TextStyle(fontSize: 15,color: Colors.black45)),
                  //   subtitle: Text('$tm_startModon',style: TextStyle(fontSize: 16,color: Colors.black),),
                  // ),
                  // Divider(
                  //   height: 2,
                  //   color: Colors.black,
                  // ),
                  // ListTile(
                  //   title: Text('Started modified by',style: TextStyle(fontSize: 15,color: Colors.black45)),
                  //   subtitle: Text('$tm_startModon',style: TextStyle(fontSize: 16,color: Colors.black),),
                  // ),
                ],
              ),
            ),
          ]),
        )));
  }
}
