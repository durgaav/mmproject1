
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/admin/register.dart';
import 'package:mmcustomerservice/screens/email_activity.dart';
import 'package:mmcustomerservice/screens/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //region Global variables
  final _formKey = GlobalKey<FormState>();

  //login controller
  TextEditingController mailController = TextEditingController();
  TextEditingController password = TextEditingController();
  //Password show/hide
  bool _obscured = true;
  //endregion

//region logic
  Future OnLogin(String mail,String pass) async {
    String mailController = mail;
    String password = pass;
    showAlert(context);
    try {
      http.Response response = await http.post(
          Uri.parse('https://mindmadetech.in/api/login/validate'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: jsonEncode(<String, String>{
            "Email":mailController,
            "Password":password,
          }));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var pref = await SharedPreferences.getInstance();
        Map<String, dynamic> map =
        new Map<String, dynamic>.from(jsonDecode(response.body));
        String  user = map['type'].toString();
        print(user);
        print(map['message'].toString());
        if (map['message'].toString() == "Login Succeed") {
          pref.setString("usertype", user)??'';
          pref.setString('usertypeMail', mail)??'';
          pref.setString("loggedIn", "true");
          print("Pref usertype......"+pref.getString("usertype").toString());
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.done_all,color: Colors.white,),
                    Text('  Login successful!'),
                  ],
                ),
                backgroundColor: Color(0xff198D0F),
                behavior: SnackBarBehavior.floating,
              )
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.alternate_email_outlined,color: Colors.white,),
                    Text('  Invalid - Email or Password!'),
                  ],
                ),
                backgroundColor: Color(0xffE33C3C),
                behavior: SnackBarBehavior.floating,
              )
          );
        }
      }else{
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_outlined,color: Colors.white,),
                  Text('  Something went wrong!'),
                ],
              ),
              backgroundColor: Color(0xffE33C3C),
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }catch(ex){
      print(ex);
      Navigator.pop(context);
      onNetworkChecking();
    }
  }
//end region

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
                        color:Colors.blueAccent,
                      ),
                      Text(
                        '  Please wait...',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  )));
        });
  }
  //end loader

  //network checking
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
        content: Text('Something went wrong!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        margin: EdgeInsets.only(left: 100, right: 100, bottom: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
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
  //end network checking

  //endregion logics

  @override
  Widget build(BuildContext context) {
    Color black = Color(0Xff146bf7);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 60),
                  child: Image(
                    image: AssetImage('assets/images/loginimg.png'),
                  )),
              Container(
                margin: EdgeInsets.only(left: 25, top: 30),
                child: Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 25, top: 25, right: 25),
                          child: TextFormField(
                            controller: mailController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.alternate_email_outlined,
                                  color: Colors.black45),
                              hintText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: 25, top: 20, right: 25),
                          child: TextFormField(
                            controller: password,
                            obscureText: _obscured,
                            decoration:  InputDecoration(
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.lock_outline_rounded,
                                  color: Colors.black45),
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
                          ),
                        ),
                        Container(
                            width: 304,
                            height: 50,
                            margin: EdgeInsets.only(top: 30, bottom: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(mailController.toString());
                                print(emailValid);
                                if(emailValid!=true){
                                  Fluttertoast.showToast(
                                    msg: 'Enter a valid email id',
                                    backgroundColor: Colors.red,
                                  );
                                }if(mailController.text.toString() == ''||password.text.toString()==''){
                                  FocusScope.of(context).unfocus();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.close_outlined,color: Colors.white,),
                                            Text('  Fields cannot be empty!'),
                                          ],
                                        ),
                                        backgroundColor: Color(0xffE33C3C),
                                        behavior: SnackBarBehavior.floating,
                                      )
                                  );
                                }else{
                                  final FormState? form = _formKey.currentState;
                                  FocusScope.of(context).unfocus();
                                  OnLogin(mailController.text.toString(),
                                      password.text.toString());
                                }
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                primary: black,
                                onPrimary: Colors.white,
                              ),
                            )),

                        TextButton(
                            onPressed: (){
                              Navigator.push(context,
                              MaterialPageRoute(builder: (context)=> EmailACtivity())
                              );
                            },
                            child:Text('Forget password')
                        ),

                        Container(
                          width:double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Un register user?'
                                ,style: TextStyle(color: Colors.black,fontSize: 16),),
                              TextButton(child: Text('Register'
                                ,style: TextStyle(color: Colors.red,fontSize: 16,decoration: TextDecoration.underline),),
                                onPressed: () async{
                                  var pref = await SharedPreferences.getInstance();
                                  pref.setString('usertype', 'unreguser');
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context)=>Register()),);
                                },),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


