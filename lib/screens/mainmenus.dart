import 'package:flutter/material.dart';
import 'package:mmcustomerservice/screens/admin/Customer.dart';
import 'package:mmcustomerservice/screens/admin/register.dart';
import 'package:mmcustomerservice/screens/admin/unregister_tickets.dart';
import 'package:mmcustomerservice/screens/login.dart';
import 'package:mmcustomerservice/screens/admin/team.dart';
import 'package:mmcustomerservice/screens/ticketpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return Drawer(
        child: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 15),
                  alignment: Alignment.centerLeft,
                  color: Colors.blue,
                  width: double.infinity,
                  height: 145,
                  child: Column(
                    children: <Widget>[
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
                          '$greetings ,' +' ${currentUser[0].toUpperCase() + currentUser.substring(1).toLowerCase()}!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ListTile(
                  leading: Icon(Icons.groups_sharp),
                  title: Text('Clients'),
                ),


                Visibility(
                  visible: usersMenu,
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.only(left: 30),
                    child: MouseRegion(
                      onHover: (h) {
                        setState(() {
                          isHover = true;
                        });
                      },
                      onExit: (h) {
                        setState(() {
                          isHover = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        child: AnimatedDefaultTextStyle(
                          style: TextStyle(
                            color: isHover ? Colors.blue : Colors.black,
                            fontSize: 20,
                          ),
                          duration: Duration(milliseconds: 150),
                          child: InkWell(
                            highlightColor: Colors.black12,
                            borderRadius: BorderRadius.circular(60.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Customer()),
                              );
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20, bottom: 20, top: 15),
                                    child: Icon(
                                      Icons.groups_sharp,
                                      color:
                                          isHover ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 25, bottom: 20, top: 15),
                                    child: Text(
                                      'Clients',
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: teamMenu,
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.only(left: 30, top: 15),
                    child: MouseRegion(
                      onHover: (o) {
                        setState(() {
                          isHover1 = true;
                        });
                      },
                      onExit: (o) {
                        setState(() {
                          isHover1 = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        child: AnimatedDefaultTextStyle(
                          style: TextStyle(
                            color: isHover1 ? Colors.blue : Colors.black,
                            fontSize: 20,
                          ),
                          duration: Duration(milliseconds: 150),
                          child: InkWell(
                            highlightColor: Colors.black12,
                            borderRadius: BorderRadius.circular(60.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TeamList()),
                              );
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20, bottom: 20, top: 15),
                                    child: Icon(
                                      Icons.people,
                                      color:
                                          isHover1 ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 25, bottom: 20, top: 15),
                                    child: Text(
                                      'Team',
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: ticketMenu,
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.only(left: 30, top: 15),
                    child: MouseRegion(
                      onHover: (v) {
                        setState(() {
                          isHover2 = true;
                        });
                      },
                      onExit: (v) {
                        setState(() {
                          isHover2 = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        child: AnimatedDefaultTextStyle(
                          style: TextStyle(
                            color: isHover2 ? Colors.blue : Colors.black,
                            fontSize: 20,
                          ),
                          duration: Duration(milliseconds: 150),
                          child: InkWell(
                            highlightColor: Colors.black12,
                            borderRadius: BorderRadius.circular(60.0),
                            onTap: () {
                              print("Current user........"+currentUser);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Tickets(
                                        usertype: usertype,
                                        currentUser: currentUser)),
                              );
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20, bottom: 20, top: 15),
                                    child: Icon(
                                      Icons.confirmation_number_sharp,
                                      color:
                                          isHover2 ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 25, bottom: 20, top: 15),
                                    child: Text(
                                      'Tickets',
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: nonRegister,
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.only(left: 30, top: 15),
                    child: MouseRegion(
                      onHover: (v) {
                        setState(() {
                          isHover3 = true;
                        });
                      },
                      onExit: (v) {
                        setState(() {
                          isHover3 = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        child: AnimatedDefaultTextStyle(
                          style: TextStyle(
                            color: isHover3 ? Colors.blue : Colors.black,
                            fontSize: 20,
                          ),
                          duration: Duration(milliseconds: 150),
                          child: InkWell(
                            highlightColor: Colors.black12,
                            borderRadius: BorderRadius.circular(60.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UnRegister_Tickets(
                                        usertype: usertype,
                                        currentUser: currentUser)),
                              );
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20, bottom: 20, top: 15),
                                    child: Icon(
                                      Icons.dns_sharp,
                                      color:
                                      isHover3 ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 25, bottom: 20, top: 15),
                                    child: Text(
                                      'Other Tickets',
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: nonRegister,
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.only(left: 30, top: 15),
                    child: MouseRegion(
                      onHover: (v) {
                        setState(() {
                          isHover3 = true;
                        });
                      },
                      onExit: (v) {
                        setState(() {
                          isHover3 = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        child: AnimatedDefaultTextStyle(
                          style: TextStyle(
                            color: isHover3 ? Colors.blue : Colors.black,
                            fontSize: 20,
                          ),
                          duration: Duration(milliseconds: 150),
                          child: InkWell(
                            highlightColor: Colors.black12,
                            borderRadius: BorderRadius.circular(60.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register()),
                              );
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20, bottom: 20, top: 15),
                                    child: Icon(
                                      Icons.person_add_alt,
                                      color:
                                      isHover3 ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 25, bottom: 20, top: 15),
                                    child: Text(
                                      'Add Client',
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10,bottom: 20),
            child: FloatingActionButton.extended(
              onPressed: () {
                logout(context);
              },
              label: Text("Logout"),
              icon: Icon(Icons.logout),
            ),
          ),
        ],
      ),
    ));
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
