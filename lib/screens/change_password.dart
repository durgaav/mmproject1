import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);
  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool showPass = false;
  TextEditingController newPass = new TextEditingController();
  TextEditingController renewPass = new TextEditingController();
  String email = '';

  Future<void> getPrefs() async{
    var pref = await SharedPreferences.getInstance();
    setState(() {
      email = pref.getString('usertypeMail')??'';
    });
  }

  Future<void> changePassword(String password) async{
    print('final password $password $email');
    showAlert();
    try{
      http.Response response = await http.put(Uri.parse("https://mindmadetech.in/api/forgotpassword/reset_password"),
      headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String , dynamic>{
        "Email":"$email",
        "Password":"$password"
      }),);
      if(response.statusCode==200){
        if(response.body.contains("Password Changed Successfully")){
          Navigator.of(context,rootNavigator: true).pop(context);
          Navigator.of(context,rootNavigator: true).pop(context);
          Navigator.of(context,rootNavigator: true).pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.green,
                content: Row(
                  children: [
                    Icon(Icons.done_all_rounded,color: Colors.white,),
                    Text(' Password changed successfully')
                  ],
                )
            )
          );
        }else{
          Navigator.of(context,rootNavigator: true).pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: Colors.red,
                  content: Row(
                    children: [
                      Icon(Icons.close_rounded,color: Colors.white,),
                      Text(' Password change failed')
                    ],
                  )
              )
          );
        }

        print(response.body);
      }
    }catch(ex){
      print(ex);
      Navigator.of(context,rootNavigator: true).pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Row(
                children: [
                  Icon(Icons.wifi_outlined,color: Colors.white,),
                  Text(' Something went wrong!')
                ],
              )
          )
      );
    }
  }

  void showAlert(){
    showDialog(
      barrierDismissible: false,
      context: context, builder: (context){
       return AlertDialog(
         title: Text('Please wait'),
         content : Row(
           children: [
             CircularProgressIndicator(),
             Text('  Changing Password...')
           ],
         ),
       );
     }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero ,() async{
      getPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){Navigator.pop(context);},
          icon:Icon(CupertinoIcons.back),
          iconSize: 30,
          splashColor: Colors.purpleAccent,
        ),
        title: Text('Change Password'),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(6),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                  height: 180,
                  image: AssetImage("assets/images/changepass.png")
              ),
              Container(
                margin: EdgeInsets.only(top:20,left: 10 , right: 10),
                child: TextField(
                  maxLength: 6,
                  controller: newPass,
                  obscureText: showPass==true?false:true,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                    contentPadding: EdgeInsets.all(5),
                    hintText: "Type New Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:10,left: 10 , right: 10),
                child: TextField(
                  maxLength: 6,
                  controller:renewPass,
                  obscureText: showPass==true?false:true,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                    contentPadding: EdgeInsets.all(5),
                    hintText: "Re-Type New Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: showPass,
                      onChanged: (bool? value) {
                        setState(() {
                          showPass = value!;
                        });
                      },
                    ),
                    InkWell
                      (
                        onTap: (){
                          setState(() {
                            if(showPass==true){
                              showPass = false;
                            }else{
                              showPass = true;
                            }
                          });
                        },
                        child: Text("Show Password")
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(top:15),
                height: 45,
                width: 110,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)
                    ),
                    color: Colors.blueAccent,
                    onPressed: (){
                      if(newPass.text.toString()!=renewPass.text.toString()){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: Colors.red,
                                content: Row(
                                  children: [
                                    Icon(Icons.close_rounded,color: Colors.white,),
                                    Text(' Passwords are not match!')
                                  ],
                                )
                            )
                        );
                      }
                      else if(newPass.text.isEmpty||renewPass.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: Colors.red,
                                content: Row(
                                  children: [
                                    Icon(Icons.close_rounded,color: Colors.white,),
                                    Text(' Password fields are empty!')
                                  ],
                                )
                            )
                        );
                    }
                      else if(newPass.text.length<6&&renewPass.text.length<6){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(' Set password at least 6 length')
                            )
                        );
                     }
                      else{
                        print("Correct password");
                        print(email);
                        FocusScope.of(context).unfocus();
                        changePassword(renewPass.text.toString());
                      }
                    },
                    child: Text('Change',style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
