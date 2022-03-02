
import 'dart:convert';
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:form_field_validator/form_field_validator.dart';
  import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/admin/register.dart';
  import 'package:mmcustomerservice/screens/homepage.dart';
  import 'package:fluttertoast/fluttertoast.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  
  class LoginPage extends StatefulWidget {
    const LoginPage({Key? key}) : super(key: key);
    @override
    _LoginPageState createState() => _LoginPageState();
  }
  
  class _LoginPageState extends State<LoginPage> {

    //region Global variables
    final _formKey = GlobalKey<FormState>();
  
  //region Validator
    final userValidator =
        MultiValidator([RequiredValidator(errorText: 'Cannot be blank')]);
  
    final passValidator =
        MultiValidator([RequiredValidator(errorText: 'Cannot be blank')]);
  //endregion
  
    //login controller
    TextEditingController username = TextEditingController();
    TextEditingController password = TextEditingController();
    //Password show/hide
    bool _obscured = true;
  
    //endregion
  
    //region logics
    Future OnLogin(String user, String pass) async {
      var pref = await SharedPreferences.getInstance();
      if(user == 'ad'||user == 'tm'){
        Fluttertoast.showToast(
            msg: 'Must Enter suffix value',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 15.0);
      }else {
        showAlert(context);
        String username = user;
        List<String> splitUser = username.split('_');
        String url = "";
        String currentUser = "";
        String password = "";
        String userType = "";
        setState(() {
          if (splitUser[0] == "ad") {
            url = "https://mindmadetech.in/api/admin/validate";
            currentUser = splitUser[1];
            password = pass;
            userType = "admin";
          } else if (splitUser[0] == "tm") {
            url = "https://mindmadetech.in/api/team/validate";
            currentUser = splitUser[1];
            password = pass;
            userType = "team";
          } else {
            url = "https://mindmadetech.in/api/customer/validate";
            currentUser = user;
            password = pass;
            userType = "client";
          }
        });
        print("user..." + currentUser + " " + password + " " + url);
        try {
          print("1");
          http.Response response = await http.post(
              Uri.parse(url),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8'
              },
              body: jsonEncode(<String, String>{
                "username": currentUser,
                "password": password,
              }));
          print("2");
          print(response.statusCode);
          print(response.body);
          if (response.statusCode == 200) {
            Map<String, dynamic> map =
            new Map<String, dynamic>.from(jsonDecode(response.body));
            if (map['message'].toString() == "Login Succeed") {
              pref.setString('usertype', userType);
              pref.setString('username', currentUser);
              pref.setString("loggedIn", "true");
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
              Fluttertoast.showToast(
                  msg: 'Login successful!',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 15.0);
            } else {
              Navigator.pop(context);
              Fluttertoast.showToast(
                  msg: 'Username/Password Incorrect!',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 15.0);
            }
          } else {
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: 'Something went wrong!',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 15.0);
          }
        } catch (Exception) {
          print(Exception);
          Navigator.pop(context);
          onNetworkChecking();
        }
      }
    }
  
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
                  color: Colors.deepPurpleAccent,
                ),
                Text(
                  '  Please wait...',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            )));
          });
    }
  
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
                    margin: EdgeInsets.only(top: 45),
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
                          controller: username,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.alternate_email_outlined,
                                color: Colors.black45),
                            hintText: 'Username',
                          ),
                          validator: userValidator,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 25, top: 20, right: 25),
                        child: TextFormField(
                          controller: password,
                          validator: passValidator,
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
                              // Icon(_obscured ? Icons.visibility_off : Icons.visibility,color: Colors.black),
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
                              final FormState? form = _formKey.currentState;
                              OnLogin(username.text.toString(),
                                  password.text.toString());
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              primary: black,
                              onPrimary: Colors.white,
                            ),
                          )),
                      Container(
                        width:double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Un register user?'
                              ,style: TextStyle(color: Colors.black,fontSize: 16),),
                            TextButton(child: Text('Register'
                              ,style: TextStyle(color: Colors.red,fontSize: 16,decoration: TextDecoration.underline),),
                              onPressed: (){
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
