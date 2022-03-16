import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mmcustomerservice/screens/admin/customerviewpage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';


class Customer extends StatefulWidget {
  @override
  _CustomerState createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {

  //region Variables
  Color green =Color(0xff198D0F);
  Color red = Color(0xffE33C3C);

  //Strings
  String extention = "*";
  String searchText = "";
  String imgPath = "";
  String createdBy = '';
  bool clearSearch = false;
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
  //Edittext
  TextEditingController searchController = new TextEditingController();
  TextEditingController compName = new TextEditingController(), passWd = new TextEditingController(),
      mailId = new TextEditingController(),
      phnNum = new TextEditingController(),clientNm = new TextEditingController();
  //List and File
  File _image = new File("");
  List<GetCustomer> data = [];
  //true false
  bool refresh = false;
  bool retryVisible = false;
  //endregion Variables

  //region Functions

  //ADD new customer dialog
  void dialogBuilder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget> [
                        GestureDetector(
                            onTap: () async {
                              print("image path" + imgPath);
                              print("Entering to file picker........");
                              FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                                type: FileType.image,
                              );
                              PlatformFile file = result.files.first;
                              if (result != "") {
                                setState(() {
                                  imgPath = file.path.toString();
                                });
                                _image = new File(imgPath);
                                extention = file.extension;
                                print("this is image : " +
                                    _image.absolute.path.toString());
                              }
                            },
                            child: imgPath == ""
                                ? CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage:
                              AssetImage('assets/images/user.png'),
                            ) : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: FileImage(File('$imgPath')),
                            )),
                      ],
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Email here',
                        labelText: 'Email',
                      ),
                      controller: mailId,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your Companyname',
                        labelText: 'Company name',
                      ),
                      controller: compName,
                      keyboardType: TextInputType.text,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter client name',
                        labelText: 'Client name',
                      ),
                      controller: clientNm,
                      keyboardType: TextInputType.text,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Password here',
                        labelText: 'Password',
                      ),
                      controller: passWd,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter a phone number',
                        labelText: 'Phone number',
                      ),
                      controller: phnNum,
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: 10.0),
                              child: new RaisedButton(
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(mailId.text.toString());
                                  print(emailValid);
                                  if(emailValid!=true){
                                    Fluttertoast.showToast(
                                      msg: 'Enter a valid email id',
                                      backgroundColor: Colors.red,
                                    );
                                  }else if (compName.text.isEmpty ||
                                      passWd.text.isEmpty ||
                                      mailId.text.isEmpty ||
                                      phnNum.text.length < 10 ||
                                      clientNm.text.isEmpty||_image.path.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please fill all the details/Select profile image.",
                                        toastLength: Toast.LENGTH_LONG,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 18.0
                                     );
                                  } else {
                                    Navigator.pop(context);
                                    AddNewUser(
                                        compName.text.toString(),
                                        passWd.text.toString(),
                                        mailId.text.toString(),
                                        phnNum.text.toString(),
                                        clientNm.text.toString(),
                                    );
                                  }
                                },
                                color: Colors.blue,
                              )),
                          Container(
                            padding: EdgeInsets.only(top: 10.0, left: 5),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ));
          },
        );
      },
    );
  }

//send mail
  void sendMailToClient(String mail , String pass) async {
    try {
      setState(() {
        mailId.text.toString();
        passWd.text.toString();
      });
      print(mailId);
      print(passWd);
      String username = 'durgadevi@mindmade.in';
      String password = 'Appu#001';
      final smtpServer = gmail(username, password);
      final equivalentMessage = Message()
        ..from = Address(username, 'DurgaDevi')
        ..recipients.add(Address(mailId.text.toString()))
        ..ccRecipients.addAll([Address('surya@mindmade.in'),])
      // ..bccRecipients.add('bccAddress@example.com')
        ..subject = 'Your Credentials ${formatter.format(DateTime.now())}'
        ..text = 'Dear Sir/Madam,\n\n'
            'Greetings from MindMade Customer Support Team!!! \n'
            'You have been registered as Client on MindMade Customer Support.\n'
            'To Login,go to https://mm-customer-support-ten.vercel.app/ then enter the following information:\n\n'
            'Email : ${mail}\n'
            'Password : ${pass}\n\n'
            'You can change your password once you logged in.\n\n'
            'Thanks & Regards, \nMindMade';
      // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";
      await send(equivalentMessage, smtpServer);
      print('Message sent: ' + send.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer Credentials send via mail'),
            backgroundColor: Colors.lightGreen,
            behavior: SnackBarBehavior.floating,
          )
      );
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send credentials!'),
              backgroundColor: Colors.red[200],
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }
  }

  //Default loader
  showAlert() {
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

  //Add new customer logic
  Future AddNewUser(String comp,String pass, String mail, String phn, String client) async {
    showAlert();
    // https://mindmadetech.in/public/images/file-1645099812344.png
    print(_image);
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('https://mindmadetech.in/api/customer/new'));
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields.addAll({
        'Companyname': comp,
        'Clientname': client,
        'Password': pass,
        'Email': mail,
        'Phonenumber': phn,
        'CreatedOn': formatter.format(DateTime.now()),
        'CreatedBy': '$createdBy'
      });
      request.files.add(await http.MultipartFile.fromPath('file', _image.path,
          filename: Path.basename(_image.path),
          contentType: MediaType.parse("image/$extention")));

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        print({
          'Companyname': comp,
          'Clientname': client,
          'Password': pass,
          'Email': mail,
          'Phonenumber': phn,
          'CreatedOn': formatter.format(DateTime.now()),
          'CreatedBy': '$createdBy'
        });
        String res = await response.stream.bytesToString();
        print(res);
        String s = '{"statusCode":400,"message":"Email already Exists!"}';
        if (res.contains(s)) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.close,color: Colors.white,),
                      Text(' EmailId already Exists!'),
                    ],
                  ),
                  backgroundColor:red,
                  behavior: SnackBarBehavior.floating,
                )
            );
        } else {
          Navigator.pop(context);
          setState(() {
            sendMailToClient(mail.toString(), pass.toString());
            searchController = new TextEditingController(text: "");
            compName = new TextEditingController(text: "");
            passWd = new TextEditingController(text: "");
            mailId = new TextEditingController(text: "");
            phnNum = new TextEditingController(text: "");
            clientNm = new TextEditingController(text: "");
            _image=File('');
            fetchCustomer();
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.done_all,color: Colors.white,),
                    Text(' Customer added successfully!'),
                  ],
                ),
                backgroundColor: green,
                behavior: SnackBarBehavior.floating,
              ),
          );
        }
      } else {
        Navigator.pop(context);
        print(await response.stream.bytesToString());
        print(response.statusCode);
        print(response.reasonPhrase);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.announcement_outlined,color: Colors.white,),
                  Text(" "+response.reasonPhrase.toString()),
                ],
              ),
              backgroundColor: red,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    } catch(ex){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.announcement_outlined,color: Colors.white,),
                Text(' Something went wrong'),
              ],
            ),
            backgroundColor: red,
            behavior: SnackBarBehavior.floating,
          )
      );
    }
  }
  //Getting customer list
  Future<void> fetchCustomer() async {
    showAlert();
    try{
      http.Response response =
      await http.get(Uri.parse("https://mindmadetech.in/api/customer/list"));
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        List b = body.where((element) => element['Isdeleted'] == 'n').toList();
        setState(() {
          retryVisible = false;
          Navigator.pop(context);
          data = b.map((e) => GetCustomer.fromJson(e)).toList();
          setState(() {
            data = data.reversed.toList();
          });
        });
      }else{
        setState(() {
          retryVisible = false;
        });
        Navigator.pop(context);
        onNetworkChecking();
      }
    }catch(ex){
      setState(() {
        retryVisible = true;
      });
      Navigator.pop(context);
      onNetworkChecking();
    }
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

  //Loading login prefs
  Future<void> getPref() async {
    var pref = await SharedPreferences.getInstance();
    if (pref != null) {
      createdBy = pref.getString('usertypeMail')!;
    }
    print("Created by = " + createdBy);
  }

  //Passing data to another screen
  void passDatatoScren(index)async {
    var pref = await SharedPreferences.getInstance();

    pref.remove('userId');
    pref.remove('cus_user');
    pref.remove('pass');
    pref.remove('email');
    pref.remove('phno');
    pref.remove('address');
    pref.remove('Cname');
    pref.remove('Clientname');
    pref.remove('Createdon');
    pref.remove('Createdby');
    pref.remove('Modifiedby');
    pref.remove('Modifiedon');
    pref.remove('Isdeleted');

    pref.setString('userId',data[index].usersId??'');
    pref.setString('cus_pass',data[index].Password??'');
    pref.setString('email',data[index].Email??'');
    pref.setString('phno',data[index].Phonenumber??'');
    pref.setString('address',data[index].Address??'');
    pref.setString('Cname',data[index].Companyname??'');
    pref.setString('Logo',data[index].Logo??'');
    pref.setString('Clientname',data[index].Clientname??'');
    pref.setString('Createdon',data[index].Createdon??'');
    pref.setString('Createdby',data[index].Createdby??'');
    pref.setString('Modifiedby',data[index].Modifiedby??'');
    pref.setString('Modifiedon',data[index].Modifiedon??'');
    pref.setString('Isdeleted',data[index].Isdeleted??'');

    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPage()),);
  }

  //Refesh list
  Future<void> refreshListener() async{
    setState(() {
      fetchCustomer();
    });
  }
  //endregion Functions

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imgPath = "";
  }
  @override
  void initState() {
// TODO: implement initState
    super.initState();
    Future.delayed(Duration
        .zero, () async {
      fetchCustomer();
    });
    getPref();
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dialogBuilder(context);
          print(MediaQuery.of(context).size.width);
        },
        child: Icon(
          Icons.person_add_alt_outlined ,
          size: 28,
        ),
        backgroundColor: Colors.blue,
      ),
      appBar: AppBar(
          leading: IconButton(
            onPressed: (){Navigator.pop(context);},
            icon:Icon(CupertinoIcons.back),
            iconSize: 30,
            splashColor: Colors.purpleAccent,
          ),
          centerTitle: true,
          backgroundColor: Color(0Xff146bf7),
          title:Text('Clients')
      ),
      body: SingleChildScrollView(
        child: Container(
          child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
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
                //Refrsh visible
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
                          fetchCustomer();
                        })),
                  ),
                ),
                //Designs
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.81,
                    child: RefreshIndicator(
                        onRefresh: refreshListener,
                        backgroundColor: Colors.blue,
                        color: Colors.white,
                        child: data.length>0?ListView.builder(
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return data[index].Companyname.toLowerCase().contains(searchText.toString().toLowerCase())
                                  ? Column(children: <Widget>[
                                ListTile(
                                  onTap: () {
                                    passDatatoScren(index);
                                  },
                                  leading: Container(
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundImage:
                                      NetworkImage(data[index].Logo),
                                    ),
                                  ),
                                  title:(data[index].Companyname.isNotEmpty)? Text(
                                    data[index].Companyname[0].toUpperCase() +
                                        data[index].Companyname.substring(1).toLowerCase(),
                                    style: TextStyle(fontSize: 17.5),
                                  ):Text('value not specified'),
                                  subtitle:(data[index].Email.isNotEmpty)?Text(data[index].Email.toString(),maxLines: 1,):Text('mail id not specified'),
                                  trailing: IconButton(
                                    onPressed: () {
                                      passDatatoScren(index);
                                    },
                                    icon: Icon(
                                      Icons.arrow_right,
                                      size: 35,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 0,
                                  color: Colors.black12,
                                ),
                              ])
                                  : Container();

                            }):Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Text('No data found!',style: TextStyle(fontSize: 25,color: Colors.deepPurple),),
                          ),
                        )
                    ))
              ]
          ),

        ),
      ),
    );
  }

}

class GetCustomer {
  String usersId;
  String Password;
  String Email;
  String Phonenumber;
  String Address;
  String Companyname;
  String Logo;
  String Clientname;
  String Createdon;
  String Createdby;
  String Modifiedon;
  String Modifiedby;
  String Isdeleted;

  GetCustomer(
      {required this.usersId,
        required this.Password,
        required this.Email,
        required this.Phonenumber,
        required this.Address,
        required this.Companyname,
        required this.Logo,
        required this.Clientname,
        required this.Createdby,
        required this.Createdon,
        required this.Modifiedby,
        required this.Modifiedon,
        required this.Isdeleted});

  factory GetCustomer.fromJson(Map<String, dynamic> json) {
    return GetCustomer(
        usersId: json['usersId'].toString(),
        Password: json['Password'].toString(),
        Email: json['Email'].toString(),
        Phonenumber: json['Phonenumber'].toString(),
        Address: json['Address'].toString(),
        Companyname: json['Companyname'].toString(),
        Logo: json['Logo'].toString(),
        Clientname: json['Clientname'].toString(),
        Createdby: json['CreatedBy'].toString(),
        Createdon: json['CreatedOn'].toString(),
        Modifiedby: json['ModifiedBy'].toString(),
        Modifiedon: json['ModifiedOn'].toString(),
        Isdeleted: json['Isdeleted'].toString());
  }
}



