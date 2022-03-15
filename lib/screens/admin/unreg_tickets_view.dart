import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mmcustomerservice/screens/admin/customerviewpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';


class UnRegTickets_View extends StatefulWidget {
  const UnRegTickets_View({Key? key}) : super(key: key);

  @override
  _UnRegTickets_ViewState createState() => _UnRegTickets_ViewState();
}

class _UnRegTickets_ViewState extends State<UnRegTickets_View> {
  String cmpyname='';
  String cliname='';
  String UserName='';
  String pass='';
  String logo='';
  String email='';
  String phonenumber='';
  String domainname='';
  String description='';
  String createdon='';
  String status='';
  String adm_updatedon='';
  String adm_updatedby='';
  String registerId='';
  List<File> files =[];
  List extensions =[];

  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
  String extention = "*";

  Color green =Color(0xff198D0F);
  Color red = Color(0xffE33C3C);


  Future <void> getData() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      registerId= pref.getString('registerId')!;
      cmpyname= pref.getString('cmpyname')!;
      cliname= pref.getString('cliname')!;
      UserName=pref.getString('UserName')!;
      pass =pref.getString('pass')!;
      logo= pref.getString('logo')!;
      email=pref.getString('email')!;
      phonenumber=pref.getString('phonenumber')!;
      domainname=pref.getString('domainname')!;
      description=pref.getString('description')!;
      createdon=pref.getString('createdon')!;
      status=pref.getString('status')!;
      adm_updatedon=pref.getString('adm_updatedon')!;
      adm_updatedby=pref.getString('adm_updatedby')!;

    });
  }

  showAlert(BuildContext context){
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(
              child: AlertDialog(
                  content:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:<Widget> [
                      CircularProgressIndicator(
                        color: Colors.deepPurpleAccent,
                      ),
                      Text(' please wait...',style: TextStyle(fontSize: 18),),
                    ],
                  )
              )
          );
        }
    );
  }

  Future <void>ApproveDailog(BuildContext context) async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Container(
              child: AlertDialog(
                title:Row(
                  children: <Widget>[
                    Icon(
                      Icons.beenhere ,
                      color: Colors.green,
                      size: 25,
                    ),
                    Text('Approve!',
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ],
                ),
                content: Text('Customer details will be Approved',
                  style: TextStyle(fontSize: 17),),
                actions: [
                  Row(
                    children: [
                      FlatButton(onPressed: (){
                        Navigator.of(context,rootNavigator: true).pop();
                        print('window closed');
                        Navigator.of(context).pop();

                      }, child: Text('Cancel',
                          style: TextStyle(fontSize: 13,color: Colors.blue))),
                      FlatButton(onPressed: (){
                        setState(() {
                          ApproveTicket(registerId,status='Reject',context);
                        });
                        print('$status');
                        Navigator.of(context).pop();

                      }, child: Text('Reject',
                          style: TextStyle(fontSize: 13,color: Colors.blue))),
                      FlatButton(onPressed: (){
                        setState(() {
                          ApproveTicket(registerId,status='Approved',context);
                        });
                        print('$status');
                        Navigator.of(context).pop();

                      }, child: Text('Approve',
                          style: TextStyle(fontSize: 13,color: Colors.blue))),

                    ],
                  )

                ],
              )
          );
        }
    );
  }


  Future AddUnRegTicket() async {
    showAlert(context);
    final request = http.MultipartRequest(
        'POST', Uri.parse('https://mindmadetech.in/api/tickets/new')
    );
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields.addAll
      ({
      'Username': UserName,
      'Email': email,
      'Phonenumber': phonenumber,
      'DomainName': domainname,
      'Description': description,
      'Cus_CreatedOn':'null'
    });
    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();
    print(response.statusCode);
    print('tickets...');
    if (response.statusCode == 200) {
      Navigator.pop(context);
      if(res.contains('Ticket added successfully')){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.done_all,color: Colors.white,),
                Text('Ticket added successfully'),
              ],
            ),
            backgroundColor:green,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
    else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.announcement_outlined,color: Colors.white,),
                Text(response.reasonPhrase.toString()),
              ],
            ),
            backgroundColor: red,
            behavior: SnackBarBehavior.floating,
          )
      );
      print(response.reasonPhrase);
    }
  }



  Future AddUnRegUser() async {
    print('enter...');
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('https://mindmadetech.in/api/customer/new'));
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields.addAll({
        'Companyname': cmpyname,
        'Clientname': cliname,
        'Username': UserName,
        'Password': pass,
        'Email': email,
        'Phonenumber': phonenumber,
        'Createdon': formatter.format(DateTime.now()),
        'Logo':logo
      });

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print(response.statusCode);
        String res = await response.stream.bytesToString();
        print(res);
        if (res.contains("Username already Exists!")) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.announcement,color: Colors.white,),
                    Text('Username already Exists!'),
                  ],
                ),
                backgroundColor:red,
                behavior: SnackBarBehavior.floating,
              )
          );
          return response;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.done_all,color: Colors.white,),
                    Text('Customer added successfully!'),
                  ],
                ),
                backgroundColor: green,
                behavior: SnackBarBehavior.floating,
              )
          );
        }
      } else {
        print(await response.stream.bytesToString());
        print(response.statusCode);
        print(response.reasonPhrase);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.announcement,color: Colors.white,),
                  Text(response.reasonPhrase.toString(),),
                ],
              ),
              backgroundColor: red,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }catch(ex){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.announcement,color: Colors.white,),
                Text('Something went wrong'),
              ],
            ),
            backgroundColor: red,
            behavior: SnackBarBehavior.floating,
          )
      );
      print(ex);
    }
  }



  Future<void> ApproveTicket(String usersId,String Status,BuildContext context) async {
    try {
      print(usersId);
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('PUT', Uri.parse(
          'https://mindmadetech.in/api/unregisteredcustomer/statusupdate/$registerId'));
      request.body = json.encode(<String, String>{
        "Status": "$status",
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String s = await response.stream.bytesToString();
        if("$status"== 'Reject'){
          setState(() {
            rejectStatusMail();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.close,color: Colors.white,),
                    Text('Reject Successfully'),
                  ],
                ),
                backgroundColor:red,
                behavior: SnackBarBehavior.floating,
              )
          );
        }else if("$status"=='Approved'){
          setState(() {
            AddUnRegUser();
            AddUnRegTicket();
            approveStatusMail();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.done_all,color: Colors.white,),
                    Text('Approved successfully!'),
                  ],
                ),
                backgroundColor: green,
                behavior: SnackBarBehavior.floating,
              )
          );
        }
      }
    }catch(Exception){
      print(Exception);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.announcement_rounded,color: Colors.white,),
                Text('Something went wrong'),
              ],
            ),
            backgroundColor: red,
            behavior: SnackBarBehavior.floating,
          )
      );
    }
  }


  //send approve mail
  void approveStatusMail() async {
    String username = 'durgadevi@mindmade.in';
    String password = 'Appu#001';

    final smtpServer = gmail(username, password);
    final equivalentMessage = Message()
      ..from = Address(username, 'DurgaDevi')
      ..recipients.add(Address(email))
      ..ccRecipients.addAll([Address('surya@mindmade.in'),])
    // ..bccRecipients.add('bccAddress@example.com')
      ..subject = 'Your Ticket status ${formatter.format(DateTime.now())}'
    ..text = ("Dear Sir/Madam,\n\n"
        "Greetings from MindMade Customer Support Team!!!\n"
        "You have been registered as Client on MindMade Customer Support.\n"
        "To Login,go to https://mm-customer-support-ten.vercel.app/ then enter the following information:\n\n"
        "Email:$email\n"
        "Password:$pass\n\n"
        "You can change your password once you logged in.\n\n"
        "Thanks & Regards,\n"
        "Mindmade;"

    );
    // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";
    try {
      await send(equivalentMessage, smtpServer);
      print('Message sent: ' + send.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.done_all,color: Colors.white,),
                Text('Approve send via mail'),
              ],
            ),
            backgroundColor: green,
            behavior: SnackBarBehavior.floating,
          )
      );
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.close,color: Colors.white,),
                  Text('Failed to send Approve'),
                ],
              ),
              backgroundColor:red,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }
  }
  //


  //send reject  mail
  void rejectStatusMail() async {
    String username = 'durgadevi@mindmade.in';
    String password = 'Appu#001';

    final smtpServer = gmail(username, password);
    final equivalentMessage = Message()
      ..from = Address(username, 'DurgaDevi')
      ..recipients.add(Address(email))
      ..ccRecipients.addAll([Address('surya@mindmade.in'),])
    // ..bccRecipients.add('bccAddress@example.com')
      ..subject = 'Your Ticket status ${formatter.format(DateTime.now())}'
      ..text = 'Your Ticket is Rejected ';
    // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";
    try {
      await send(equivalentMessage, smtpServer);
      print('Message sent: ' + send.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.announcement_rounded,color: Colors.white,),
                Text('Rejection send via mail'),
              ],
            ),
            backgroundColor: red,
            behavior: SnackBarBehavior.floating,
          )
      );
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.close,color: Colors.white,),
                  Text('Failed to send Reject'),
                ],
              ),
              backgroundColor: red,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }
  }
  //


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    print(registerId);
    print(status);
    print(email);
    print(pass);
    print ("Dear Sir/Madam,\n\n"
        "Greetings from MindMade Customer Support Team!!!\n"
        "You have been registered as Client on MindMade Customer Support.\n"
        "To Login,go to https://mm-customer-support-ten.vercel.app/ then enter the following information:\n\n"
        "Email:$email\n"
        "Password:$pass\n\n"
        "You can change your password once you logged in.\n\n"
        "Thanks & Regards,\n"
        "Mindmade;"

    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ApproveDailog(context);
          }, label: Text('Approve'),
          icon: Icon(Icons.beenhere_outlined ),

        ),
        body: Stack(
            children: [
              ClipPath(
                clipper: MyClipper(),
                child: Container(
                  color: Colors.lightBlue,
                ),
              ),
              Positioned(
                top: 20,
                child:IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, icon: Icon(Icons.arrow_back,color: Colors.black,)),
              ),
              Positioned(
                top:65,
                left: 22,
                child:  SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child:Text(cmpyname[0].toUpperCase()+cmpyname.substring(1),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(email, style: TextStyle(fontSize: 17, color: Colors.white),),),

                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(phonenumber, style: TextStyle(fontSize: 16, color: Colors.white,),)),
                    ],
                  ),
                ),),
              Positioned(
                top:110,
                left: 235,
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                  ),
                  child: Container(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage:  NetworkImage(logo),
                    ),
                  ),
                ), ),
              Positioned(
                top: 200,
                left: 10,
                child:  SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 45,top:0),
                    height: MediaQuery.of(context).size.height*0.8,
                    width: MediaQuery.of(context).size.width,
                    child:ListView(
                      children: [
                        ListTile(
                            leading: Icon(Icons.person),
                            title:Text('Register Id',style: TextStyle(fontSize: 15, color: Colors.black45),),
                            subtitle:Text(registerId, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),)
                        ),
                        ListTile(
                            leading: Icon(Icons.account_balance_outlined ),
                            title: Text('Company Name',style: TextStyle(fontSize: 15, color: Colors.black45),),
                            subtitle:Text(cmpyname, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),)
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.person_circle ),
                          title: Text("Client name", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:Text(cliname, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                          leading: Icon(Icons.lock),
                          title: Text("Password", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:Text(pass, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                          leading: Icon(Icons.language),
                          title: Text("Domain Name", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:Text(domainname, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                          leading: Icon(Icons.description ),
                          title: Text("Description", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:Text(description, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.doc_person_fill ),
                          title: Text("Status", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:Text(status, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.time ),
                          title: Text("Created on", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:Text(createdon, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),

                        // ListTile(
                        //     leading: Icon(CupertinoIcons.time_solid ),
                        //     title: Text("Admin Updated On", style: TextStyle(fontSize: 15, color: Colors.black45),),
                        //     subtitle:adm_updatedon==''?Text('Not yet updated.',
                        //       style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):
                        //     Text(adm_updatedon, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),)
                        // ),
                        // ListTile(
                        //     leading: Icon(CupertinoIcons.doc_person),
                        //     //doc_checkmark  doc_checkmark_fill description_rounded doc_person
                        //     title: Text("Admin Updated By", style: TextStyle(fontSize: 15, color: Colors.black45),),
                        //     subtitle:adm_updatedby==''?Text('Not yet modified.',
                        //       style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):
                        //     Text(adm_updatedby, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),)
                        // ),

                      ],
                    ),
                  ),
                ),
              ),

            ]
        )
    );
  }
}


