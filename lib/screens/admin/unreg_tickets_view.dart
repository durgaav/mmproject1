import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UnRegTickets_View extends StatefulWidget {
  const UnRegTickets_View({Key? key}) : super(key: key);

  @override
  _UnRegTickets_ViewState createState() => _UnRegTickets_ViewState();
}

class _UnRegTickets_ViewState extends State<UnRegTickets_View> {
  String cmpyname='';
  String cliname='';
  String username='';
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


  Future <void> getData() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      registerId= pref.getString('registerId')!;
      cmpyname= pref.getString('cmpyname')!;
      cliname= pref.getString('cliname')!;
      username=pref.getString('username')!;
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
                            style: TextStyle(fontSize: 15,color: Colors.blue))),
                        FlatButton(onPressed: (){
                          setState(() {
                            ApproveTicket(registerId,status='Reject',context);
                          });
                          print('$status');
                          Navigator.of(context).pop();

                        }, child: Text('Reject',
                            style: TextStyle(fontSize: 15,color: Colors.blue))),
                        FlatButton(onPressed: (){
                          setState(() {
                            ApproveTicket(registerId,status='Approved',context);
                          });
                          print('$status');
                          Navigator.of(context).pop();

                        }, child: Text('Approve',
                            style: TextStyle(fontSize: 15,color: Colors.blue))),

                      ],
                    )

                  ],
                )
            );
          }
      );
  }

  // Future AddUnRegUser(String cmpyname, String username, String pass, String email, String phonenumber, String cliname,BuildContext context) async {
  //   try {
  //     final request = http.MultipartRequest(
  //         'POST', Uri.parse('https://mindmadetech.in/api/customer/new'));
  //     request.headers['Content-Type'] = 'multipart/form-data';
  //     request.fields.addAll({
  //       'Companyname': cmpyname,
  //       'Clientname': cliname,
  //       'Username': username,
  //       'Password': pass,
  //       'Email': email,
  //       'Phonenumber': phonenumber,
  //       'Createdon': formatter.format(DateTime.now()),
  //      // 'Createdby': '$createdBy'
  //     });
  //     request.files.add(await http.MultipartFile.fromPath('file', _image.path,
  //         filename: Path.basename(_image.path),
  //         contentType: MediaType.parse("image/$extention")));
  //
  //     http.StreamedResponse response = await request.send();
  //     if (response.statusCode == 200) {
  //       String res = await response.stream.bytesToString();
  //       if (res.contains("Username already Exists!")) {
  //         Navigator.of(context, rootNavigator: true).pop();
  //         Navigator.of(context, rootNavigator: true).pop();
  //         Fluttertoast.showToast(
  //             msg: 'Username already Exists!',
  //             toastLength: Toast.LENGTH_LONG,
  //             gravity: ToastGravity.BOTTOM,
  //             timeInSecForIosWeb: 1,
  //             backgroundColor: Colors.red,
  //             textColor: Colors.white,
  //             fontSize: 15.0);
  //         return response;
  //       } else {
  //         Navigator.of(context, rootNavigator: true).pop();
  //         Navigator.of(context, rootNavigator: true).pop();
  //         setState(() {
  //           fetchCustomer();
  //         });
  //         Fluttertoast.showToast(
  //             msg: 'Customer added successfully!',
  //             toastLength: Toast.LENGTH_LONG,
  //             gravity: ToastGravity.BOTTOM,
  //             timeInSecForIosWeb: 1,
  //             backgroundColor: Colors.green,
  //             textColor: Colors.white,
  //             fontSize: 15.0
  //         );
  //       }
  //     } else {
  //       onNetworkChecking();
  //       print(await response.stream.bytesToString());
  //       print(response.statusCode);
  //       print(response.reasonPhrase);
  //       Fluttertoast.showToast(
  //           msg: response.reasonPhrase.toString(),
  //           toastLength: Toast.LENGTH_LONG,
  //           gravity: ToastGravity.BOTTOM,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.red,
  //           textColor: Colors.white,
  //           fontSize: 15.0);
  //     }
  //   }catch(ex){
  //     onNetworkChecking();
  //     Fluttertoast.showToast(
  //         msg: 'Something went wrong',
  //         toastLength: Toast.LENGTH_LONG,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 15.0);
  //   }
  // }



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
     print(response.statusCode);
     if (response.statusCode == 200) {
       String s = await response.stream.bytesToString();
       if("$status"== 'Reject'){
         Fluttertoast.showToast(
             msg: 'Reject Successfully',
             toastLength: Toast.LENGTH_LONG,
             gravity: ToastGravity.BOTTOM,
             timeInSecForIosWeb: 1,
             backgroundColor: Colors.green,
             textColor: Colors.white,
             fontSize: 15.0
         );
       }else if("$status"=='Approved'){

         Fluttertoast.showToast(
             msg: 'Approved successfully!',
             toastLength: Toast.LENGTH_LONG,
             gravity: ToastGravity.BOTTOM,
             timeInSecForIosWeb: 1,
             backgroundColor: Colors.red,
             textColor: Colors.white,
             fontSize: 15.0
         );
       }
     }
   }catch(Exception){
     print(Exception);
     Fluttertoast.showToast(
         msg: 'Something went wrong',
         toastLength: Toast.LENGTH_LONG,
         gravity: ToastGravity.BOTTOM,
         timeInSecForIosWeb: 1,
         backgroundColor: Colors.red,
         textColor: Colors.white,
         fontSize: 15.0);
   }
    }




@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    print('$registerId');
    print('$status');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets View'),
        backgroundColor: Color(0Xff146bf7),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ApproveDailog(context);
        }, label: Text('Approve'),
        icon: Icon(Icons.beenhere_outlined ),
        
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top:20,left: 20,bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top:5,right: 15,bottom: 17),
                    child:CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(logo),),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:10),
                    child: Text(username[0].toUpperCase()+username.substring(1),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  )
                ],
              ),
              Container(
                child: Text('Register Id',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(registerId, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('User Name',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(username, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Company Name',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(cmpyname, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Client Name',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(cliname, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Password',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(pass, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Email Id',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(email, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Phone Number',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(phonenumber, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Domain Name',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(domainname, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Description',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(description, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Status',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),

              Container(
                child: Text(status, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Created On',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(createdon, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Admin Updated On',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(adm_updatedon, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),
              Divider(),
              Container(
                child: Text('Admin Updated By',style: TextStyle(
                    fontSize: 15, color: Colors.black45),
                ),
              ),
              Container(
                child: Text(adm_updatedby, style: TextStyle(fontSize: 17, color: Color(0XFF333333)),),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
