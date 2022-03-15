import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/admin/Customer.dart';
import 'package:mmcustomerservice/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  List<GetCustomer> data = [];

  Future<void> CusProfile() async{
    var pref = await SharedPreferences.getInstance();
    String user = pref.getString('usertypeMail')!;

    try{
      http.Response response =
      await http.get(Uri.parse("https://mindmadetech.in/api/customers/list/$user"));
      print(response.statusCode);
      if(response.statusCode == 200){
        List b = jsonDecode(response.body);
        data = b.map((e) => GetCustomer.fromJson(e)).toList();
      }
    }catch(ex){
      print(ex);
    }
  }
 @override
  void initState() {
    // TODO: implement initState
   Future.delayed(Duration.zero,() async{
       CusProfile();
   });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        logout(context);
        }, label: Text('LogOut'),icon: Icon(Icons.logout),),
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Stack(
          children: [
            IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back)),
            Container(
              margin: EdgeInsets.only(top:220),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight:Radius.circular(500)),
                color: Colors.white
              ),
            ),
            Positioned(
              top: 150,
              left: 10,
              child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(data[0].Logo)
                    ),
                  ),

                ),
            Positioned(
              top: 300,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email Id',style: TextStyle(color: Colors.black45),),
                      Container(
                          margin: EdgeInsets.only(top: 15,bottom: 15),
                          child: (data[0].Email.isNotEmpty)?Text(data[0].Email,style: TextStyle(fontSize: 18),):Text('no datas')
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone number',style: TextStyle(color: Colors.black45),),
                      Container(
                          margin: EdgeInsets.only(top: 15,bottom: 15),
                          child: (data[0].Phonenumber.isNotEmpty)?Text(data[0].Phonenumber,style: TextStyle(fontSize: 18),):Text('no data')
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Company name',style: TextStyle(color: Colors.black45),),
                      Container(
                          margin: EdgeInsets.only(top: 15,bottom: 15),
                          child:(data[0].Companyname.isNotEmpty)? Text(data[0].Companyname,style: TextStyle(fontSize: 18),):Text('no data')
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Client name',style: TextStyle(color: Colors.black45),),
                      Container(
                          margin: EdgeInsets.only(top: 15,bottom: 15),
                          child: (data[0].Clientname.isNotEmpty)?Text(data[0].Clientname,style: TextStyle(fontSize: 18),):Text('no data')
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Password',style: TextStyle(color: Colors.black45),),
                      Container(
                          margin: EdgeInsets.only(top: 15,bottom: 15),
                          child: (data[0].Password.isNotEmpty)?Text(data[0].Password,style: TextStyle(fontSize: 18),):Text('no data')
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> logout(BuildContext context) async {
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
                  'Are you sure you will be logged out!.',
                  style: TextStyle(fontSize: 18),
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
                        var loginPref = await SharedPreferences.getInstance();
                        loginPref.setString("loggedIn", "false");
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                        print(loginPref.getString('loggedIn').toString());
                      },
                      child: Text('Logout now',
                          style: TextStyle(fontSize: 16, color: Colors.blue)))
                ],
              ));
        });
  }

}
