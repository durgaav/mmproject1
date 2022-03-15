import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //text controller
  TextEditingController Cmpname = TextEditingController();
  TextEditingController Clientname = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController phnoController = TextEditingController();
  TextEditingController domainController = TextEditingController();
  TextEditingController dsController = TextEditingController();
  //end controller

//region variables
  Color green =Color(0xff198D0F);
  Color red = Color(0xffE33C3C);



  String extention = "*";
  List unAppTic = [];
  List filterdByPhn = [];
  String imgPath = "";
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
  bool _obscured = true;
  String userType = '';
  String status = 'No status';
  String emailId = '';
//end region

  //file open
  OpenFiles(List<PlatformFile> files){
    ListView.builder(
        itemCount: files.length,
        itemBuilder: (BuildContext context , index){
          return ListTile(
            leading: Icon(Icons.image,color: Colors.green,size: 40,),
            title: Text(files[index].path.split('/').last,style: TextStyle(fontSize: 14),),
            trailing: IconButton(
              onPressed: (){
                print('hi');
                setState(() {
                  files.removeAt(index);
                });
              },
              icon: Icon(Icons.close,color: Colors.red,size: 30,),
            ),
          );
        });
  }
  //

  //default loader
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
  //


  //add unreg ticket
  Future AddTicket(String cmp,String clname,String passwrd,String email,
      String phno,String doname,String description) async {
    showAlert(context);
    var pref = await SharedPreferences.getInstance();
    try{
      http.Response response = await http.post(
          Uri.parse('https://mindmadetech.in/api/unregisteredcustomer/new'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: jsonEncode(<String, String>{
            'Companyname': cmp.toString(),
            'Clientname': clname.toString(),
            'Password': passwrd.toString(),
            'Email': email.toString(),
            'Phonenumber': phno.toString(),
            'DomainName':doname.toString(),
            'Description':description.toString(),
            'CreatedOn': formatter.format(DateTime.now()),
            "Logo" : "https://mindmadetech.in/public/images/file-1645099812344.png",
          }));

      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        Map<String, dynamic> map =
        new Map<String, dynamic>.from(jsonDecode(response.body));
        print(map['message'].toString());
        if (map['message'].toString() == "Request sent successfully") {
          setState(() {
            emailId = pref.getString('unregmailid')??'';
            Cmpname = TextEditingController();
            Clientname = TextEditingController();
            pass = TextEditingController();
            mailController = TextEditingController();
            phnoController = TextEditingController();
            domainController = TextEditingController();
            dsController = TextEditingController();
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.done_all),
                    Text('Ticket Created Successfuly'),
                  ],
                ),
                backgroundColor: green,
                behavior: SnackBarBehavior.floating,
              )
          );
          Navigator.pop(context);
        } else {
          print(map['message'].toString());
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.announcement_sharp),
                    Text('Email already Exists'),
                  ],
                ),
                backgroundColor: red,
                behavior: SnackBarBehavior.floating,
              )
          );
        }
      }
      else {
        Navigator.pop(context);
        onNetworkChecking();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.announcement,color: Colors.white,),
                  Text(response.reasonPhrase.toString()),
                ],
              ),
              backgroundColor: red,
              behavior: SnackBarBehavior.floating,
            )
        );
        print(response.reasonPhrase);
      }
    } catch(ex){
      Navigator.pop(context);
      onNetworkChecking();
    }
  }
//end

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

// ticket status
  Future<void> getTickets() async{
    var pref = await SharedPreferences.getInstance();
    try{
      http.Response response;
      response = await http.get(Uri.parse("https://mindmadetech.in/api/unregisteredcustomer/list"));
      if(response.statusCode==200){
        unAppTic = jsonDecode(response.body);
        setState(() {
          filterdByPhn = unAppTic.where((element) => element['Email'].toLowerCase() ==
              emailId.toLowerCase()).toList();
          status = filterdByPhn[0]['Status'].toString();
          if(status.toLowerCase() == 'approved'){
            pref.remove('unregmailid');
          }else if(status.toLowerCase() == 'reject'){
            pref.remove('unregmailid');
          }
        });ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.lightGreen,
                content: Text('Status fetched.'))
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red,
                content: Text('Something wen wrong please try again.')
            )
        );

      }
    }catch(ex){
      onNetworkChecking();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to fetch status...')
          )
      );
    }
  }
//end status

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
        Duration.zero, () async {
      var pref = await SharedPreferences.getInstance();
      setState(() {
        emailId = pref.getString('unregmailid')??'';
        userType = pref.getString('usertype')??'';
        if(emailId==null){
          setState(() {
            emailId = '';
          });
        }
        if(userType=='unreguser'){
          getTickets();
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color(0Xff146bf7),
        actions: [
          userType=="unreguser"?PopupMenuButton(
              icon: Icon(Icons.info_outline , size: 30,),
              itemBuilder: (context) =>
              [
                PopupMenuItem(
                    enabled: false,
                    child:Text("$emailId")
                ),
                PopupMenuItem(
                    child:Row(
                      children: [
                        status.toLowerCase()=="pending"?
                        Icon(Icons.autorenew , color: Colors.blueAccent,):
                        status.toLowerCase()=="approved"?
                        Icon(CupertinoIcons.check_mark_circled_solid , color: Colors.green,):
                        status.toLowerCase()=="reject"?
                        Icon(Icons.close_outlined , color: Colors.red,):
                        Container(),
                        Text(
                          status.toLowerCase()=='pending'?' '
                              '$status...    ':' $status    ',
                          style: TextStyle(
                              color: Colors.black
                          ),)
                      ],
                    )
                ),
                PopupMenuItem(
                  enabled: true,
                  child:Text("Refresh..."),
                  onTap: (){
                    setState(() {
                      getTickets();
                    });
                  },
                ),
              ]
          ):Container()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
                child:Container(
                  padding: EdgeInsets.only(top:20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Company name',
                            labelText: 'Company name',
                            border: OutlineInputBorder(),
                          ),
                          controller:Cmpname ,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(height:10,),
                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Client name',
                            labelText: 'Client name',
                            border: OutlineInputBorder(),
                          ),
                          controller:Clientname ,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(height:10,),

                      Container(
                        height: 45,
                        child: TextFormField(
                          controller: pass,
                          obscureText: _obscured,
                          decoration:  InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _obscured = !_obscured;
                                  });
                                },
                                child: (_obscured)?Icon(Icons.visibility_off,color: Colors.black54,):
                                Icon(Icons.visibility,color: Colors.black,)
                            ),
                            hintText: 'Password',
                          ),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),
                      SizedBox(height:10,),

                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Emailid',
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          controller: mailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(height:10,),

                      Container(
                        height: 65,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Phonenumber',
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          controller: phnoController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                        ),
                      ),
                      SizedBox(height:10,),

                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Domain Name',
                            labelText: 'Domain Name',
                            border: OutlineInputBorder(),
                          ),
                          controller: domainController,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(height:10,),

                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Enter your Issue',
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 100,
                        minLines: 3,
                        controller: dsController,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height:10,),
                      Container(
                        height: 60,
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(onPressed: () {
                          if(Cmpname.text.isEmpty||Clientname.text.isEmpty||
                              pass.text.isEmpty||mailController.text.isEmpty||phnoController.text.isEmpty||domainController.text.isEmpty||dsController.text.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    backgroundColor: red,
                                    content: Row(
                                      children: [
                                        Icon(Icons.article,color: Colors.white,),
                                        Text('Please enter all details'),
                                      ],
                                    ),
                                  behavior: SnackBarBehavior.floating,
                                )
                            );
                          } else{
                            AddTicket(Cmpname.text.toString(), Clientname.text.toString(),
                                pass.text.toString(), mailController.text.toString(), phnoController.text.toString(),
                                domainController.text.toString(), dsController.text.toString());
                          }
                        },
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            onPrimary: Colors.white,
                          ),child: Text("send",style: TextStyle(fontSize: 17),),),
                      ),
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}

