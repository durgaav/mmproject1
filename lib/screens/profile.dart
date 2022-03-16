import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/admin/Customer.dart';
import 'package:mmcustomerservice/screens/admin/customerviewpage.dart';
import 'package:mmcustomerservice/screens/change_password.dart';
import 'package:mmcustomerservice/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  List<GetCustomer> data = [];
  String user='';

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


  Future<void> CusProfile() async{
    showAlert(context);
    try{
      http.Response response =
      await http.get(Uri.parse("https://mindmadetech.in/api/customers/list/$user"));
      print(response.statusCode);
      if(response.statusCode == 200){
        setState(() {
          List b = jsonDecode(response.body);
          data = b.map((e) => GetCustomer.fromJson(e)).toList();
        });
        Navigator.pop(context);
      }
    }catch(ex){
      print(ex);
      Navigator.pop(context);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero,() async{
      var pref = await SharedPreferences.getInstance();
      user = pref.getString('usertypeMail')!;
      CusProfile();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',style: TextStyle(color: Colors.white),),
        leading: IconButton(
          onPressed: (){Navigator.pop(context);},
          icon:Icon(CupertinoIcons.back,color: Colors.white,),
          iconSize: 30,
          splashColor: Colors.purpleAccent,
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Positioned(
                        child: Padding(
                          padding:EdgeInsets.symmetric(horizontal: 10,vertical: 70),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.7,
                            decoration: BoxDecoration(
                                color: Color(0Xffadcaf7),
                                borderRadius: BorderRadius.circular(20)
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 120,
                        top: 20,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100)
                          ),
                          child: CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(data[index].Logo)
                          ),
                        ),
                      ),
                      Positioned(
                        top: 200,
                        left: 35,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text('Email Id :',style: TextStyle(color: Colors.black45),),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(right: 150),
                                      margin: EdgeInsets.only(bottom: 15),
                                      child: (data[index].Email.isNotEmpty)?Text(data[index].Email,style: TextStyle(fontSize: 18),):Text('no datas')
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text('Phone number :  ',style: TextStyle(color: Colors.black45),),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(right: 150),
                                      margin: EdgeInsets.only(bottom: 15,),
                                      child: (data[index].Phonenumber.isNotEmpty)?Text(data[index].Phonenumber,style: TextStyle(fontSize: 18),):Text('no data')
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text('Company name :  ',style: TextStyle(color: Colors.black45),),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(right: 150),
                                      margin: EdgeInsets.only(bottom: 15),
                                      child:(data[index].Companyname.isNotEmpty)? Text(data[index].Companyname,style: TextStyle(fontSize: 18),):Text('no data')
                                  ),
                                ],
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 5,),
                                    child: Text('Client name :  ',style: TextStyle(color: Colors.black45),),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(right: 150),
                                      margin: EdgeInsets.only(bottom: 15),
                                      child: (data[index].Clientname.isNotEmpty)?Text(data[index].Clientname,style: TextStyle(fontSize: 18),):Text('no data')
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text('Password :  ',style: TextStyle(color: Colors.black45),),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(right: 150),
                                      child: (data[index].Password.isNotEmpty)?Text(data[index].Password,style: TextStyle(fontSize: 18),):Text('no data')
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //send
                      Positioned(
                          top:530,
                          left: 170,
                          child:RaisedButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangePassword()));
                            },
                            child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Icon(Icons.lock_outlined),
                        Text('Change password'),
                      ]
                          ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            ),
                            color: Colors.white,
                          )
                      )
                      //
                    ],
                  )
                ],
              );
            }
        ),
      ),
    );
  }
}