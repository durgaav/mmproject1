import 'package:flutter/material.dart';
import 'package:mmcustomerservice/screens/admin/Customer.dart';
import 'package:mmcustomerservice/screens/admin/notifyScreen.dart';
import 'package:mmcustomerservice/screens/admin/register.dart';
import 'package:mmcustomerservice/screens/admin/unregister_tickets.dart';
import 'package:mmcustomerservice/screens/data.dart';
import 'package:mmcustomerservice/screens/login.dart';
import 'package:mmcustomerservice/screens/admin/team.dart';
import 'package:mmcustomerservice/screens/ticketpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class MainMenus extends StatefulWidget {
  String usertype;
  String currentUser;
  MainMenus({required this.usertype, required this.currentUser, required});
  @override
  _MainMenusState createState() => _MainMenusState(
        usertype: usertype,
        currentUser: currentUser,
      );
}

class _MainMenusState extends State<MainMenus> {
  String usertype;
  String currentUser;
  _MainMenusState({
    required this.usertype,
    required this.currentUser,
  });

  bool isHover = false;
  bool isHover1 = false;
  bool isHover2 = false;
  bool isHover3 = false;
  bool usersMenu = false;
  bool teamMenu = false;
  bool ticketMenu = false;
  int timeNow = DateTime.now().hour;
  String greetings = '';
  String greetsUsr='';
  bool nonRegister = false;

  String greetingMessage() {
      if (timeNow <= 12) {
        return "Good Morning";
      }
      else if ((timeNow > 12) && (timeNow <= 16)) {
        return "Good Afternoon";
      }
      else if ((timeNow > 16) && (timeNow < 20)) {
        return "Good Evening";
      }
      else {
        return "Good Night";
      }
    }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    greetingMessage();

    print("Current user........"+currentUser);

    setState(() {
      greetings = greetingMessage();
      Future.delayed(Duration.zero, () async {
        setState(() {
          if (usertype == "admin") {
            usersMenu = true;
            teamMenu = true;
            nonRegister = true;
            ticketMenu = true;
          } else {
            ticketMenu = true;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    greetsUsr = currentUser.split(" ").first;
    var counts = context.watch<Data>().getcounter();
    String count = '';
    if(counts == 0){
      setState(() {
        count="";
      });
    }else{
      setState(() {
        count = '$counts';
      });
    }

    return Drawer(
        child:Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 15),
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/drawerpic.jpg'),
                      fit: BoxFit.fill
                    )
                  ),
                  width: double.infinity,
                  height: 185,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 15),
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: CircleAvatar(
                          backgroundColor: Colors.deepPurpleAccent,
                          radius: 35,
                          child: Text(
                            currentUser.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 15, left: 15),
                        child: Text(
                          '$greetings ,' +'\n${greetsUsr[0].toUpperCase() + greetsUsr.substring(1).toLowerCase()}...!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),

                Visibility(
                  visible: usertype=='admin'?true:false,
                  child: Column(
                    children: [
                      ListTile(
                        hoverColor: Colors.blueAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Customer()),
                          );
                        },
                          leading: Icon(Icons.groups_sharp,size: 27,),
                          title: Text('Clients',style: TextStyle(
                            color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                          ),),
                        ),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TeamList()),
                          );
                        },
                        leading: Icon(Icons.face_retouching_natural,size: 27,),
                        title: Text('Team',style: TextStyle(
                            color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                        ),),
                      ),
                      ListTile(
                        hoverColor: Colors.blueAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotifScreen()),
                          );
                        },
                        trailing: Text("$count",style: TextStyle(
                            color: Colors.red,fontSize: 14
                        )),
                        leading: Icon(Icons.notifications,size: 27,),
                        title: Text('Notifications',style: TextStyle(
                            color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                        ),),
                      ),
                    ],
                  ),
                ),


                Visibility(
                  visible: ticketMenu,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Tickets(
                                usertype: usertype,
                                currentUser: currentUser)),
                      );
                    },
                    leading: Icon(Icons.connect_without_contact_rounded ,size: 27,),
                    title: Text('Tickets',style: TextStyle(
                        color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                    ),),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10 , right: 10),
                  height: 0.8,
                  color: Colors.black12,
                ),

                Visibility(
                  visible: usertype=='admin'?true:false,
                  child: Column(
                    children: [
                      ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UnRegister_Tickets(
                                      usertype: usertype,
                                  currentUser: currentUser,)),
                            );
                          },
                          leading: Icon(Icons.hail_outlined,size: 27,),
                          title: Text('Un Register Tickets',style: TextStyle(
                              color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                          ),),
                        ),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register()),
                          );
                        },
                        leading: Icon(Icons.add,size: 27,),
                        title: Text('Add New Ticket',style: TextStyle(
                            color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15
                        ),),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10 , right: 10),
                        height: 0.8,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                ),

                ListTile(
                  onTap: (){
                    logout(context);
                  },
                  leading: Icon(Icons.exit_to_app,size: 27,),
                  title: Text('Logout',style: TextStyle(
                      color: Colors.redAccent,fontWeight: FontWeight.bold,fontSize: 15
                  ),),
                ),

              ],
            ),
          ),
        ],
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
