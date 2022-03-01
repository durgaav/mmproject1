import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart' as mail;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mmcustomerservice/screens/ticket_assign.dart';
import 'package:mmcustomerservice/ticketsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'image_screen.dart';

class TicketViewPage extends StatefulWidget {

  List<TeamAssign> tmAssignList = [];
  TicketViewPage({required this.tmAssignList});

  @override
  _TicketViewPageState createState() => _TicketViewPageState(tmAssignList: tmAssignList);
}
class _TicketViewPageState extends State<TicketViewPage> {

  List<TeamAssign> tmAssignList = [];
  _TicketViewPageState({required this.tmAssignList});

  //region Strings
  String ticketId = '';
  String Notification='';
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
      tm_CompModby = "" , projectCode = "";
      String server = '',seo = '',design = '',development = '';
  //endregion Strings

  //region Variables
  String dropdownValue = "Design";
  final List<String> datas = ["Seo", "Design", "Development", "Server"];
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
  bool checkDev = false;
  bool checkSer = false;
  bool checkSeo = false;
  bool _loading = false;
  double _progressValue = 0.0;
  List<String> fromAPI = [];
  String teamId = "0";
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
                                statusUpdate(ticketId,statusVal);
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

  Future<void> mailDialog(BuildContext context) async {
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
                              'Sent status via mail',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
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
                          'UPDATE MAIL $ticketId',
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
                          value: dropdown,
                          items: status
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdown = newValue!;
                            });
                          },
                          hint: Text("select"),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(right: 10, top: 10),
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: RaisedButton(
                              onPressed: () {
                                print("$dropdown");
                                Updateemail(dropdown, context);
                              },
                              color: Colors.blue,
                              child: Text(
                                'Sent',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ))),
                    ],
                  )));
        });
  }

  showAlert(BuildContext context,String alertText) {
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
                      )
                  );
        });
  }

  //endregion Dialogs

  //region Functions
  //tm assign


  //Sending mail
  Future<void> Updateemail(String dropdown, context) async {
    if (dropdown == "Completed") {
      final mail.Email email = mail.Email(
        body: 'Your Problem is solved',
        subject: 'Ticket id ',
        recipients: ['durgavenkatesh805@gmail.com'],
        cc: ['naveensurya9566@gmail.com'],
        bcc: [],
        attachmentPaths: [],
        isHTML: false,
      );
      String platformResponse;
      try {
        await mail.FlutterEmailSender.send(email);
        platformResponse = 'success';
        Navigator.pop(context);
      } catch (error) {
        platformResponse = error.toString();
      }
    } else {
      Navigator.pop(context);
    }
  }

  //File dwnld
  Future<String> downloadFile(String url, String fileName, String dir) async {
    showAlert(context," Downloading...");
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

        Fluttertoast.showToast(
            msg: 'Download successfully',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 15.0);
        Navigator.pop(context);
        OpenFile.open(filePath);
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
      onNetworkChecking();
      Navigator.pop(context);
      filePath = 'Can not fetch url';
    }
    return filePath;
  }

  //Status update tm
  Future<void> statusUpdate(String id , String val) async {
    var pref = await SharedPreferences.getInstance();
    String assignId = pref.getString('tickAssignId')??'';
    print("Id..............."+assignId);
    showAlert(context,"Updating...");
    String fieldOn='' , fieldBy='' ;
    if(val == 'Inprogress'){
      setState(() {
        fieldOn = "Tm_Process_UpdatedOn";
        fieldBy = 'Tm_Process_UpdatedBy';
      });
    }if(val == 'Started'){
      setState(() {
        fieldOn = "Tm_Start_UpdatedOn";
        fieldBy = 'Tm_Start_UpdatedBy';
      });
    }if(val == 'Completed'){
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
        "ticketsId" : ticketId,
        "tickets_assignId" : tmAssignList[0].ticketsAssignId,
        fieldOn: formatter.format(DateTime.now()),
        fieldBy: createdBy
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
            fontSize: 15.0
        );
        Navigator.pop(context);
        setState(() {
          if (val == "Started") {
            tm_startupdateon = formatter.format(DateTime.now());
            tm_startupdateBy = createdBy;
          } else if (val == "Inprogress") {
            tm_procesupdOn = formatter.format(DateTime.now());
            tm_procesupdBy = createdBy;
          } else {
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
    }catch(ex){
      onNetworkChecking();
      Navigator.pop(context);
    }
  }

  //Getting login prefs
  Future<void> getPref() async {
    var pref = await SharedPreferences.getInstance();
    if (pref != null) {
      createdBy = pref.getString('username')!;
      userType = pref.getString('usertype')!;
      if (userType == "admin") {
        setState(() {
          floatBtnVisi = true;
          tmStatusBtn = false;
          adDateVisi = false;
        });
      } else if(userType == "team"){
        setState(() {
          tmStatusBtn = true;
          adDateVisi = true;
        });
      }else{
        setState(() {
          tmStatusBtn = false;
          adDateVisi = true;
        });
      }
    }
    print("Created by = " + createdBy);
    print(userType);
  }

  //Loading previous screen data
  Future<void> loadGivenData() async{
    var pref = await SharedPreferences.getInstance();

    setState(() {

      teamId = pref.getString('teamMemId')??'';

      print('Team id......... $teamId');

      List<TeamAssign> list = tmAssignList.where((element) => element.teamId.toString() == teamId).toList();
      tmAssignList = list.toList();

      print('Filtered with ID ....' + tmAssignList.toString());

      for(int i = 0 ; i<tmAssignList.length;i++){
        print(tmAssignList[i].ticketsAssignId.toString() + " tmId"+tmAssignList[i].teamId.toString() );
      }


     fromAPI = pref.getStringList('Files')!;
     server = pref.getString('server')??'';
     seo = pref.getString('seo')??'';
     design = pref.getString('design')??'';
     development = pref.getString('development')??'';
     ticketId = pref.getString("tickId")??'';
     Username = pref.getString("UserName")??'';
     Email = pref.getString("MailID")??'';
     Phonenumber = pref.getString("PhoneNum")??'';
     DomainName = pref.getString("DomainNm")??'';
     Description = pref.getString("Desc")??'';
     Status = pref.getString("Statuses")??'';
     Notification = pref.getString("Notify")??'';
     createdOn = pref.getString("cusCreatedOn")??'';
      // pref.getString("cusModifiedOn")??'';
     adm_updte_on = pref.getString("admCreatedOn")??'';
     adm_update_by = pref.getString("admUpdatedBy")??'';
     adm_modify_on = pref.getString("admModifiedOn")??'';
     adm_mod_by = pref.getString("admModifiedBy")??'';
     adm_updte_on = pref.getString("admUpdatedOn")??'';
     adm_mod_by = pref.getString("admUpdatedBy")??'';
     tm_startupdateon = pref.getString("tmStartUpdatedOn")??'';
     tm_startupdateBy = pref.getString("tmStartUpdatedBy")??'';
     tm_startModon = pref.getString("tmStartModifiedOn")??'';
     tm_startModBy = pref.getString("tmStartModifiedBy")??'';
     tm_procesupdOn = pref.getString("tmProcessUpdatedOn")??'';
     tm_procesupdBy= pref.getString("tmProcessUpdatedBy")??'';
     tm_procesModOn = pref.getString("tmProcessModifiedOn")??'';
     tm_procesModBy = pref.getString("tmProcessModifiedBy")??'';
     tm_cmpleUpdOn = pref.getString("tmCompleteUpdatedOn")??'';
     tm_compleupBy = pref.getString("tmCompleteUpdatedBy")??'';
     tm_startModon = pref.getString("tmCompleteModifiedOn")??'';
     tm_startModBy = pref.getString("tmCompleteModifiedBy")??'';
    });

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

  //endregion Functions

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    getPref();
    loadGivenData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         //APP bar
        appBar: AppBar(
          backgroundColor: Color(0Xff146bf7),
          title: Text('Ticket ID : $ticketId'),
        ),
        floatingActionButton: this.Status == "completed"
            ? Visibility(
                visible: floatBtnVisi,
                child: FloatingActionButton(
                  child: Icon(Icons.mail),
                  onPressed: () {
                    //Mail send
                    mailDialog(context);
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
                        // assignDialog(context);
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>TicketAssign(ticketId:ticketId,updatedBy: adm_update_by,)));
                      },
                    ),
                  ),
        body: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.all(7.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            //Customer info
            ExpansionTile(
              leading: Icon(
                Icons.account_circle,
                size: 35,
                color: Colors.green,
              ),
              title: Text(
                'CUSTOMER INFO',
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
                  title: Text('Username',
                      style: TextStyle(fontSize: 15, color: Colors.black45)),
                  subtitle: Text(
                    '$Username',
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
                    onPressed: () async{
                      if(DomainName.startsWith("http")){
                        if (await canLaunch(DomainName)) {
                          await launch(DomainName);
                        } else {
                          throw 'Could not launch $DomainName';
                        }
                      }else{
                        if (await canLaunch("https://"+DomainName)) {
                          await launch("https://"+DomainName);
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
            Divider(
              height: 2,
              color: Colors.black,
            ),

                //Admin updates
                Visibility(
                  visible: adDateVisi,
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.calendar_today,
                      size: 35,
                      color: Colors.grey,
                    ),
                    title: Text(
                      'ADMIN UPDATES',
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
                            style: TextStyle(fontSize: 15, color: Colors.black45)),
                        subtitle: Text(
                          '$adm_updte_on',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      ListTile(
                        title: Text('Updated by',
                            style: TextStyle(fontSize: 15, color: Colors.black45)),
                        subtitle: Text(
                          '$adm_update_by',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: adDateVisi,
                  child: Divider(
                    height: 2,
                    color: Colors.black,
                  ),
                ),

            //Customers issue
            ExpansionTile(
              leading: Icon(
                Icons.bug_report_rounded,
                size: 35,
                color: Colors.red,
              ),
              title: Text(
                'CUSTOMER ISSUES',
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
                ListTile(
                  title: Text('Ticket status',
                      style: TextStyle(fontSize: 15, color: Colors.black45)),
                  subtitle: Text(
                    '$Status',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            Divider(
              height: 2,
              color: Colors.black,
            ),

            //Tm start
            ExpansionTile(
              leading: Icon(
                Icons.lock_clock_rounded,
                size: 35,
                color: Colors.indigo,
              ),
              title: Text(
                'TEAM STARTED TIMELINE',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Click for more...',
                style: TextStyle(fontSize: 15, color: Colors.black45),
              ),
              children: <Widget>[
                userType=='admin'?Column(
                  children: [
                    Text('Assigned Teams', style: TextStyle(fontSize: 17.0)),
                    SizedBox(height: 10,),
                    Container(
                      child: Table(
                        defaultColumnWidth: FixedColumnWidth(90.0),
                        border: TableBorder.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 1),
                        children: [
                          TableRow( children: [
                            Column(children:[Text('Server', style: TextStyle(fontSize: 13.0))]),
                            Column(children:[Text('SEO', style: TextStyle(fontSize: 13.0))]),
                            Column(children:[Text('Design', style: TextStyle(fontSize: 13.0))]),
                            Column(children:[Text('Development', style: TextStyle(fontSize: 13.0))]),
                          ]),
                          TableRow( children: [
                            Column(children:[
                              server=="y"?Icon(Icons.done,color: Colors.green,):
                                      Icon(Icons.close,color: Colors.red,)
                            ]),
                            Column(children:[seo=="y"?Icon(Icons.done,color: Colors.green,):
                            Icon(Icons.close,color: Colors.red,)]),
                            Column(children:[design=="y"?Icon(Icons.done,color: Colors.green,):
                            Icon(Icons.close,color: Colors.red,)]),
                            Column(children:[development=="y"?Icon(Icons.done,color: Colors.green,):
                            Icon(Icons.close,color: Colors.red,)]),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ):Container(),
                  ListTile(
                  title: Text('Team started on',
                      style: TextStyle(fontSize: 15, color: Colors.black45)),
                  subtitle: Text(
                    '$tm_startupdateon',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                ListTile(
                  title: Text('Started by',
                      style: TextStyle(fontSize: 15, color: Colors.black45)),
                  subtitle: Text(
                    '$tm_startupdateBy',
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
            Divider(
              height: 2,
              color: Colors.black,
            ),

            //tm Progress
            ExpansionTile(
              leading: Icon(
                Icons.access_alarm_rounded,
                size: 35,
                color: Colors.orangeAccent,
              ),
              title: Text(
                'TEAM PROGRESS TIMELINE',
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
                  title: Text('Team progress started on',
                      style: TextStyle(fontSize: 15, color: Colors.black45)),
                  subtitle: Text(
                    '$tm_procesupdOn',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                ListTile(
                  title: Text('Updates by',
                      style: TextStyle(fontSize: 15, color: Colors.black45)),
                  subtitle: Text(
                    '$tm_procesupdBy',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                // Divider(
                //   height: 2,
                //   color: Colors.black,
                // ),
                // ListTile(
                //   title: Text('Progress modified on',style: TextStyle(fontSize: 15,color: Colors.black45)),
                //   subtitle: Text('$tm_procesModOn',style: TextStyle(fontSize: 16,color: Colors.black),),
                // ),
                // Divider(
                //   height: 2,
                //   color: Colors.black,
                // ),
                // ListTile(
                //   title: Text('Progress modified by',style: TextStyle(fontSize: 15,color: Colors.black45)),
                //   subtitle: Text('$tm_startModon',style: TextStyle(fontSize: 16,color: Colors.black),),
                // ),
              ],
            ),
            Divider(
              height: 2,
              color: Colors.black,
            ),

            //Tm completed
            ExpansionTile(
              leading: Icon(
                CupertinoIcons.check_mark_circled,
                size: 35,
                color: Colors.green,
              ),
              title: Text(
                'COMPLETED TIMELINE',
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
                  title: Text('Team completed on',
                      style: TextStyle(fontSize: 15, color: Colors.black45)),
                  subtitle: Text(
                    '$tm_cmpleUpdOn',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                ListTile(
                  title: Text('Completed by',
                      style: TextStyle(fontSize: 15, color: Colors.black45)),
                  subtitle: Text(
                    '$tm_compleupBy',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                // Divider(
                //   height: 2,
                //   color: Colors.black,
                // ),
                // ListTile(
                //   title: Text('Complete modified on',style: TextStyle(fontSize: 15,color: Colors.black45)),
                //   subtitle: Text('$tm_CompModOn',style: TextStyle(fontSize: 16,color: Colors.black),),
                // ),
                // Divider(
                //   height: 2,
                //   color: Colors.black,
                // ),
                // ListTile(
                //   title: Text('Complete modified by',style: TextStyle(fontSize: 15,color: Colors.black45)),
                //   subtitle: Text('$tm_CompModby',style: TextStyle(fontSize: 16,color: Colors.black),),
                // ),
              ],
            ),
            Divider(
              height: 2,
              color: Colors.black,
            ),

            //Attachments
            ExpansionTile(
              leading: Icon(
                Icons.attach_file,
                size: 35,
                color: Colors.blue,
              ),
              title: Text(
                'ATTACHMENTS',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Click for more...',
                style: TextStyle(fontSize: 15, color: Colors.black45),
              ),
              children: <Widget>[
                fromAPI.isNotEmpty?
                ListView.builder(
                    itemCount: fromAPI.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context,index){
                     return ListTile(
                        onTap: (){
                          String filename = Screenshots.split("/").last;
                          setState(() {
                            downloadFile(fromAPI[index], fromAPI[index].split("/").last,
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
                              downloadFile(fromAPI[index], fromAPI[index].split("/").last,
                                  'storage/emulated/0/Download');
                            });
                          },
                          icon: Icon(Icons.cloud_download),
                          color: Colors.blue,
                          iconSize: 40,
                        ),
                      );
                    }
                ):
                Container(
                      height: 50,
                      child: Center(
                        child:Text('No attachments found...')
                      ),
                    )
              ],
            ),
          ]),
        )));
  }
}
