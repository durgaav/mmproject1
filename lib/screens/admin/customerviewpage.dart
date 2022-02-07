import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ViewPage extends StatefulWidget {
  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  String usersId='';
  String username='';
  String password='';
  String phonenumber='';
  String address='';
  String Companyname='';
  String email='';
  String Logo='';
  String Clientname='';
  String Createdon='';
  String Createdby='';
  String Modifiedon='';
  String Modifiedby='';
  String Isdeleted='';
  String proCode = '';

  //region Var
  var controller = TextEditingController();
  var _image = new File("");
  String extention="*";
  String networkImg = "";
  String imgPath = "";
  String createdBy = '';
  String datetmFor = DateTime.now().toString();
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm:ss a');
  String dateTime = '';
  //endregion Var

  //region Functions

  //User delete dialog
  Future<void> deleteDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(
              child: AlertDialog(
                title:Row(
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
                content: Text('Customer details will be deleted.',
                  style: TextStyle(fontSize: 17),),
                actions: [
                  FlatButton(onPressed: (){
                    Navigator.of(context,rootNavigator: true).pop();
                  }, child: Text('No',
                      style: TextStyle(fontSize: 16,color: Colors.blue))),
                  FlatButton(onPressed: (){
                    deleteCustomer(usersId,context);
                  }, child: Text('Delete',
                      style: TextStyle(fontSize: 16,color: Colors.blue)))
                ],
              )
          );
        }
    );
  }

  //Login prefs load
  Future<void> getPref() async{
    var pref = await SharedPreferences.getInstance();
    if(pref!=null){
      setState(() {
        createdBy = pref.getString('username')!;
      });
    }
    print("Created by = "+createdBy);
  }

  //Default loader
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

  //Function for delete user
  Future<void> deleteCustomer(String usersId,BuildContext context) async {
    print(usersId);
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT', Uri.parse('https://mindmadetech.in/api/customer/delete/$usersId'));
    request.body = json.encode(<String,String>{
      "Isdeleted": "y"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String s = await response.stream.bytesToString();
      if(s.contains("Is deleted : y")){
        Navigator.of(context,rootNavigator: true).pop();
        Fluttertoast.showToast(
            msg: 'Customer deleted successfully!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 15.0
        );
        Navigator.of(context,rootNavigator: true).pop();
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>Customer(isDel:"y")));
      }else{
        Navigator.of(context,rootNavigator: true).pop();
        Fluttertoast.showToast(
            msg: 'Failed to remove!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0
        );
      }
    }
    else {
      print(response.reasonPhrase);
      Navigator.of(context,rootNavigator: true).pop();
      Fluttertoast.showToast(
          msg: response.reasonPhrase.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0
      );
    }
  }

  Future<void> getdata()async {
    var pref = await SharedPreferences.getInstance();
    setState(() {
      usersId = pref.getString('userId').toString();
      username =pref.getString('cus_user').toString();
      password = pref.getString('cus_pass').toString();
      email = pref.getString('email').toString();
      phonenumber = pref.getString('phno').toString();
      address = pref.getString('address').toString();
      Companyname = pref.getString('Cname').toString();
      Logo = pref.getString('Logo').toString();
      Clientname = pref.getString('Clientname').toString();
      Createdon= pref.getString('Createdon').toString();
      Createdby = pref.getString('Createdby').toString();
      Modifiedby = pref.getString('Modifiedby').toString();
      Modifiedon= pref.getString('Modifiedon').toString();
      Isdeleted = pref.getString('Isdeleted').toString();
      proCode = pref.getString('proCode').toString();
    });
  }

  //Update the user details
  Future<void> updateUser(String cmp, String usr, String pass, String mailid,String phone, String client , BuildContext context) async {
    showAlert(context);
    var request = http.MultipartRequest('PUT', Uri.parse('https://mindmadetech.in/api/customer/update/$usersId'));
    if(_image.path==""){
      request.fields.addAll({
        'Logo': Logo,
        'Companyname':cmp,
        'Clientname':client,
        'Username': usr,
        'Password':pass,
        'Email': mailid,
        'Phonenumber': phone,
        'Projectcode':'$proCode',
        'Createdon': Createdon,
        'Createdby': Createdby,
        'Modifiedon': formatter.format(DateTime.now()),
        'Modifiedby': createdBy
      });
    }else{
      request.files.add(
          await http.MultipartFile.fromPath('file', _image.path,filename:basename(_image.path) ,
              contentType: MediaType.parse("image/$extention")
          )
      );
      request.fields.addAll({
        'Companyname':cmp,
        'Clientname':client,
        'Username': usr,
        'Password':pass,
        'Email': mailid,
        'Phonenumber': phone,
        'Createdon': Createdon,
        'Createdby': Createdby,
        'Projectcode':'$proCode',
        'Modifiedon': formatter.format(DateTime.now()),
        'Modifiedby': createdBy
      });
    }

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String res = await response.stream.bytesToString();
      //print(await response.stream.bytesToString());
      if(res.contains("Customer details updated successfully")){
        _image == File("");
        Navigator.of(context,rootNavigator: true).pop();
        Navigator.of(context,rootNavigator: true).pop();
        Fluttertoast.showToast(
            msg: 'Changes saved!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 15.0
        );
        setState(() {
          usersId = usersId;
          username= usr;
          password= pass;
          phonenumber= phone;
          address= address;
          Companyname= cmp;
          email= mailid;
          Logo= Logo;
          Clientname= client;
          Createdon= Createdon;
          Createdby= Createdby;
          Modifiedon= formatter.format(DateTime.now());
          Modifiedby= createdBy;
        });
      }else{
        _image == File("");
        Navigator.of(context,rootNavigator: true).pop();
        Navigator.of(context,rootNavigator: true).pop();
        Fluttertoast.showToast(
            msg: 'Something went wrong!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0
        );
      }
    }
    else {
      print(response.reasonPhrase);
      Navigator.of(context,rootNavigator: true).pop();
      Navigator.of(context,rootNavigator: true).pop();
      Fluttertoast.showToast(
          msg: response.reasonPhrase.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 15.0
      );
    }
  }
  //endregion Functions

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imgPath = '';
    print('diposed the activity....');
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
    getdata();
    setState((){
      dateTime = formatter.format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController compName = new TextEditingController(text: "$Companyname")
    , usrNm = new TextEditingController(text: "$username") , passWd = new TextEditingController(text: "$password") ,
        mailId  = new TextEditingController(text: "$email"),
        phnNum = new TextEditingController(text: "$phonenumber"),clientNm = new TextEditingController(text: "$Clientname");
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0Xff146bf7),
          title: Text('${username[0].toUpperCase() + username.substring(1).toLowerCase()}'),
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: CircleAvatar(
                                      radius: 40,
                                      backgroundImage: NetworkImage(this.Logo)
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    '${username[0].toUpperCase() + username.substring(1).toLowerCase()}',
                                    style: TextStyle(
                                        fontSize: 19, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                  scrollable: true,
                                                  content:Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Center(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            //_FilePicker();
                                                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                              type: FileType.image,
                                                              //allowedExtensions: ['jpg','png','jpeg'],
                                                            );
                                                            PlatformFile file = result.files.first;
                                                            if(result!=null){
                                                              setState(() {
                                                                _image = new File(file.path);
                                                                imgPath = file.path.toString();
                                                              });
                                                              extention = file.extension;
                                                              print("this is image : "+_image.absolute.path.toString());
                                                            }
                                                          },
                                                          child:imgPath==""?CircleAvatar(
                                                            backgroundImage: NetworkImage(Logo),
                                                            radius: 45,
                                                          ):CircleAvatar(
                                                            backgroundImage: FileImage(File('$imgPath')),
                                                            radius: 45,
                                                          ),
                                                        ),
                                                      ),

                                                      TextFormField(
                                                        decoration: const InputDecoration(
                                                          hintText: 'Enter your Company name',
                                                          labelText: 'Company name',
                                                        ),
                                                        controller: compName,
                                                        keyboardType: TextInputType.text,
                                                      ),
                                                      TextFormField(
                                                        decoration: const InputDecoration(
                                                          hintText: 'Enter a Username',
                                                          labelText: 'Username',
                                                        ),
                                                        controller: usrNm,
                                                        keyboardType: TextInputType.text,
                                                        //initialValue: '$username',
                                                      ),
                                                      TextFormField(
                                                        decoration: const InputDecoration(
                                                          hintText: 'Enter a Clientname',
                                                          labelText: 'Client name',
                                                        ),
                                                        controller: clientNm,
                                                        keyboardType: TextInputType.text,
                                                        //initialValue: '$username',
                                                      ),
                                                      TextFormField(
                                                        decoration: const InputDecoration(
                                                          hintText: 'Password here',
                                                          labelText: 'Password',
                                                        ),
                                                        controller: passWd,
                                                        keyboardType: TextInputType.visiblePassword,
                                                        //initialValue: '$password',
                                                      ),
                                                      TextFormField(
                                                        decoration: const InputDecoration(
                                                          hintText: 'Email here',
                                                          labelText: 'Email',
                                                        ),
                                                        controller: mailId,
                                                        keyboardType: TextInputType.emailAddress,
                                                        //initialValue: '$email',
                                                      ),
                                                      TextFormField(
                                                        decoration: const InputDecoration(
                                                          hintText: 'Enter a phone number',
                                                          labelText: 'Phonenumber',
                                                        ),
                                                        controller: phnNum,
                                                        maxLength: 10,
                                                        keyboardType: TextInputType.phone,
                                                        //initialValue: '$phonenumber',
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
                                                                    if(compName.text.isEmpty||usrNm.text.isEmpty||passWd.text.isEmpty||
                                                                        mailId.text.isEmpty||phnNum.text.length<10||clientNm.text.isEmpty
                                                                    ){
                                                                      Fluttertoast.showToast(
                                                                          msg: 'please check the values!',
                                                                          toastLength: Toast.LENGTH_LONG,
                                                                          gravity: ToastGravity.BOTTOM,
                                                                          timeInSecForIosWeb: 1,
                                                                          backgroundColor: Colors.red,
                                                                          textColor: Colors.white,
                                                                          fontSize: 15.0
                                                                      );
                                                                      print("value not entered......");
                                                                      //Navigator.pop(context);
                                                                      // ScaffoldMessenger.of(context).showSnackBar(
                                                                      //   SnackBar(content: Text('please check the values!'),
                                                                      //   backgroundColor: Colors.red,
                                                                      //     behavior: SnackBarBehavior.floating,
                                                                      //   )
                                                                      // );
                                                                    }else{
                                                                      updateUser(compName.text.toString()
                                                                          ,usrNm.text.toString(),passWd.text.toString(),
                                                                          mailId.text.toString(),phnNum.text.toString(),clientNm.text.toString(),context
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
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      deleteDialog(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 20, left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    "Project Code :",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black45),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                    this.proCode,
                                    style: TextStyle(
                                        fontSize: 18, color: Color(0XFF333333)),
                                  ),
                                ),
                                Divider(
                                  color: Colors.black12,
                                ),
                                Container(
                                  child: Text(
                                    "User ID :",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black45),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                    this.usersId,
                                    style: TextStyle(
                                        fontSize: 18, color: Color(0XFF333333)),
                                  ),
                                )
                              ],
                            )),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Company name:",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black45),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  this.Companyname,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left:0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        "Client name:",
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.black45),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text(
                                        this.Clientname,
                                        style: TextStyle(
                                            fontSize: 18, color: Color(0XFF333333)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.black12,
                              ),
                              Container(
                                child: Text(
                                  "Username:",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black45),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  '${username[0].toUpperCase() + username.substring(1).toLowerCase()}',
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Password:",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black45),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  this.password,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Phone number:",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black45),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  this.phonenumber,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  "Email ID:",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black45),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  this.email,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Created on:",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black45),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  this.Createdon,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Created by:",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black45),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  this.Createdby,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Modified on:",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black45),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child:Modifiedon=='null'?Text(
                                  'Not yet modified.',
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                ):Text(
                                  Modifiedon,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                )
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "Modified by:",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black45),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Modifiedby=='null'?Text(
                                  'Not yet modified.',
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                ):Text(
                                  Modifiedby,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0XFF333333)),
                                )
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                ])));
  }

}

