import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';

class ViewPage extends StatefulWidget {
  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  String usersId='';
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

  //region Var
  Color green =Color(0xff198D0F);
  Color red = Color(0xffE33C3C);


  var controller = TextEditingController();
  var _image = new File("");
  String extention="*";
  String networkImg = "";
  String imgPath = "";
  String createdBy = '';
  String datetmFor = DateTime.now().toString();
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
  String dateTime = '';

  bool _dialVisible = true;

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
                    Text('  Alert!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
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
        createdBy = pref.getString('usertypeMail')!;
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
    try{
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
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.done_all,color: Colors.white,),
                    Text('Customer deleted successfully!'),
                  ],
                ),
                backgroundColor: green,
                behavior: SnackBarBehavior.floating,
              )
          );
          Navigator.of(context,rootNavigator: true).pop();
        }else{
          Navigator.of(context,rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.announcement_outlined,color: Colors.white,),
                    Text('Failed to remove!'),
                  ],
                ),
                backgroundColor: red,
                behavior: SnackBarBehavior.floating,
              )
          );
        }
      }
      else {
        print(response.reasonPhrase);
        Navigator.of(context,rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.announcement_outlined,color: Colors.white,),
                  Text( response.reasonPhrase.toString()),
                ],
              ),
              backgroundColor: red,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }catch(ex){
      Navigator.pop(context);
      onNetworkChecking(context);
      print(ex);
    }
  }


  //Network
  onNetworkChecking(context) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
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
  //Network

  Future<void> getdata()async {
    var pref = await SharedPreferences.getInstance();
    setState(() {
      usersId = pref.getString('userId').toString();
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
    });
  }

  //Update the user details
  Future<void> updateUser(String cmp, String pass, String mailid,String phone, String client , BuildContext context) async {
    showAlert(context);
    try{
      var request = http.MultipartRequest('PUT', Uri.parse('https://mindmadetech.in/api/customer/update/$usersId'));
      if(_image.path==""){
        request.fields.addAll({
          'Logo': Logo,
          'Companyname':cmp,
          'Clientname':client,
          'Password':pass,
          'Email': mailid,
          'Phonenumber': phone,
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
          'Password':pass,
          'Email': mailid,
          'Phonenumber': phone,
          'Createdon': Createdon,
          'Createdby': Createdby,
          'Modifiedon': formatter.format(DateTime.now()),
          'Modifiedby': createdBy
        });
      }

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String res = await response.stream.bytesToString();
        if(res.contains("Customer details updated successfully")){
          _image == File("");
          Navigator.of(context,rootNavigator: true).pop();
          Navigator.of(context,rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.done_all,color: Colors.white,),
                    Text( 'Changes saved!'),
                  ],
                ),
                backgroundColor: green,
                behavior: SnackBarBehavior.floating,
              )
          );
          setState(() {
            usersId = usersId;
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
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.announcement_outlined,color: Colors.white,),
                    Text('Something went wrong!'),
                  ],
                ),
                backgroundColor:red,
                behavior: SnackBarBehavior.floating,
              )
          );
        }
      }
      else {
        print(response.reasonPhrase);
        Navigator.of(context,rootNavigator: true).pop();
        Navigator.of(context,rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.announcement_outlined,color: Colors.white,),
                  Text(response.reasonPhrase.toString()),
                ],
              ),
              backgroundColor:red,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }catch(ex){
      Navigator.pop(context);
      onNetworkChecking(context);
      print(ex);
    }
  }
  //endregion Functions

//edit dialog
  void showeditDialog(context) {
    TextEditingController compName = new TextEditingController(text: "$Companyname")
    ,  passWd = new TextEditingController(text: "$password") ,
        mailId  = new TextEditingController(text: "$email"),
        phnNum = new TextEditingController(text: "$phonenumber"),clientNm = new TextEditingController(text: "$Clientname");
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
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          //_FilePicker();
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                            type: FileType.image,
                          );
                          PlatformFile file = result.files.first;
                          if (result != null) {
                            setState(() {
                              _image = new File(file.path);
                              imgPath = file.path.toString();
                            });
                            extention = file.extension;
                            print("this is image : " +
                                _image.absolute.path.toString());
                          }
                        },
                        child: imgPath == "" ? CircleAvatar(
                          backgroundImage: NetworkImage(Logo),
                          radius: 45,
                        ) : CircleAvatar(
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
                        hintText: 'Enter a Clientname',
                        labelText: 'Client name',
                      ),
                      controller: clientNm,
                      keyboardType: TextInputType.text,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Password here',
                        labelText: 'Password',
                      ),
                      controller: passWd,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Email here',
                        labelText: 'Email',
                      ),
                      controller: mailId,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter a phone number',
                        labelText: 'Phonenumber',
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
                                  if (compName.text.isEmpty ||
                                      passWd.text.isEmpty ||
                                      mailId.text.isEmpty ||
                                      phnNum.text.length < 10 ||
                                      clientNm.text.isEmpty
                                  ) {
                                    print("value not entered......");
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Row(
                                          children: [
                                            Icon(Icons.article_outlined,color: Colors.white,),
                                            Text('please check the values!'),
                                          ],
                                        ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        )
                                    );
                                  } else {
                                    updateUser(
                                        compName.text.toString(),
                                        passWd.text.toString(),
                                        mailId.text.toString(),
                                        phnNum.text.toString(),
                                        clientNm.text.toString(),
                                        context
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
//

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
    return Scaffold(
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          visible: _dialVisible,
          curve: Curves.bounceIn,
          overlayColor: Colors.black12,
          overlayOpacity: 0.5,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 8.0,
          shape: CircleBorder(),
          children: [
            SpeedDialChild(
                child: Icon(Icons.edit,color: Colors.green,size: 27,),
                backgroundColor: Colors.white,
                label: 'Update',
                labelStyle: TextStyle(fontSize: 17.0),
                onTap: () =>  showeditDialog(context)
            ),
            SpeedDialChild(
                child: Icon(Icons.delete_forever,color: Colors.red,size: 27,),
                backgroundColor: Colors.white,
                label: 'delete',
                labelStyle: TextStyle(fontSize:17.0),
                onTap: () => deleteDialog(context)

            ),
          ],
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
                child: IconButton(
                  onPressed: (){Navigator.pop(context);},
                  icon:Icon(CupertinoIcons.back),
                  iconSize: 30,
                  splashColor: Colors.purpleAccent,
                ),
              ),
              Positioned(
                top:65,
                left: 22,
                child:  SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child:Companyname.isEmpty?Text('Value not specified',
                          style: TextStyle(fontSize: 18, color: Color(0XFF333333)),): Text(
                          '${Companyname[0].toUpperCase() + Companyname.substring(1).toLowerCase()}',
                          style: TextStyle(fontSize: 22, color: Colors.white),),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child:email.isEmpty?Text('Value not specified',
                            style: TextStyle(fontSize: 18, color: Color(0XFF333333)),): Text(this.email,style: TextStyle(fontSize: 16,color: Colors.white,))),

                      Container(
                          padding: EdgeInsets.only(top: 5),
                          child: phonenumber.isEmpty?Text('Value not specified',
                            style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):Text(this.phonenumber, style: TextStyle(fontSize: 16, color: Colors.white,),)),
                    ],
                  ),
                ),),
              Positioned(
                top:110,
                // right: 100,
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
                        backgroundImage: NetworkImage(this.Logo)
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
                      //shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: Icon(Icons.description_rounded),
                          title: Text("User ID", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:usersId.isEmpty?Text('Value not specified',
                            style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):Text(this.usersId, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.person_circle ),
                          title: Text("Client name", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:Clientname.isEmpty?Text('Value not specified',
                            style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):Text(this.Clientname, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                          leading: Icon(Icons.lock),
                          title: Text("Password", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:password.isEmpty?Text('Value not specified',
                            style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):Text(this.password, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.time ),
                          title: Text("Created on", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:Createdon.isEmpty?Text('Value not specified',
                            style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):Text(this.Createdon, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.doc_person_fill ),
                          title: Text("Created by", style: TextStyle(fontSize: 15, color: Colors.black45),),
                          subtitle:Createdby.isEmpty?Text('Value not specified',
                            style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):Text(this.Createdby, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),),
                        ),
                        ListTile(
                            leading: Icon(CupertinoIcons.time_solid ),
                            title: Text("Modified on", style: TextStyle(fontSize: 15, color: Colors.black45),),
                            subtitle:Modifiedon.isEmpty?Text('Not yet modified.',
                              style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):
                            Text(Modifiedon, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),)
                        ),
                        ListTile(
                            leading: Icon(CupertinoIcons.doc_person),
                            title: Text("Modified by", style: TextStyle(fontSize: 15, color: Colors.black45),),
                            subtitle:Modifiedby.isEmpty?Text('Not yet modified.',
                              style: TextStyle(fontSize: 18, color: Color(0XFF333333)),):
                            Text(Modifiedby, style: TextStyle(fontSize: 18, color: Color(0XFF333333)),)
                        ),

                      ],
                    ),
                  ),
                ),
              )
            ]
        ));

  }




}
//background design using paint
class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 220);
    path.quadraticBezierTo(
        size.width / 4, 160 /*180*/, size.width / 2, 175);
    path.quadraticBezierTo(
        3 / 4 * size.width, 190, size.width, 130);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
//

