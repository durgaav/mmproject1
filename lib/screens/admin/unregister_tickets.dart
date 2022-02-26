import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmcustomerservice/screens/admin/unreg_tickets_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnRegister_Tickets extends StatefulWidget {
  String usertype='';
  String currentUser='';
  UnRegister_Tickets({required this.usertype, required this.currentUser, required});

@override
  _UnRegister_TicketsState createState() => _UnRegister_TicketsState(  usertype: usertype, currentUser: currentUser,);

}

class _UnRegister_TicketsState extends State<UnRegister_Tickets> {
  String usertype='';
  String currentUser='';
  _UnRegister_TicketsState({required this.usertype, required this.currentUser, });


  List<GetUnreg> unRegTickets = [];
  bool retryVisible = false;

  Future<void> fetchRegTickets() async {
    try {
      http.Response response;
      if(usertype=='admin'){
        response =
        await http.get(Uri.parse("https://mindmadetech.in/api/unregisteredcustomer/list"));
      }else{
        return null;
      }

      print(response.statusCode);
      if (response.statusCode == 200) {
        List body = [];
        setState(() {
          //tap again - visible
          body = jsonDecode(response.body);
          unRegTickets = body.map((e) => GetUnreg.fromJson(e)).toList();
        });
      }
      else {
      //  Navigator.pop(context);
        onNetworkChecking();
      }
    }
    catch (Exception) {
      //tap again - visible
      print(Exception);
      setState(() {
        retryVisible = true;
      });
    //  Navigator.pop(context);
      onNetworkChecking();
    }
  }


  onNetworkChecking() async {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(
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

  Future<void> refreshListener() async{
    setState(() {
      fetchRegTickets();
    });
  }

  Future<void> ticketsDataToView(int index) async {
    var pref = await SharedPreferences.getInstance();
    pref.remove('registerId');
    pref.remove('cmpname');
    pref.remove('cliname');
    pref.remove('username');
    pref.remove('pass');
    pref.remove('logo');
    pref.remove('email');
    pref.remove('phonenumber');
    pref.remove('domainname');
    pref.remove('description');
    pref.remove('createdon');
    pref.remove('status');
    pref.remove('registerId');
    pref.remove('adm_updatedon');
    pref.remove('adm_updatedby');

    pref.setString('registerId',unRegTickets[index].registerId??'');
    pref.setString('cmpyname',unRegTickets[index].companyname??'');
    pref.setString('cliname',unRegTickets[index].clientname??'');
    pref.setString('username',unRegTickets[index].username??'');
    pref.setString('pass',unRegTickets[index].password??'');
    pref.setString('logo',unRegTickets[index].logo??'');
    pref.setString('email',unRegTickets[index].email??'');
    pref.setString('phonenumber',unRegTickets[index].phonenumber??'');
    pref.setString('domainname',unRegTickets[index].domainName??'');
    pref.setString('description',unRegTickets[index].description??'');
    pref.setString('createdon',unRegTickets[index].createdOn??'');
    pref.setString('status',unRegTickets[index].status??'');
    pref.setString('adm_updatedon',unRegTickets[index].admUpdatedOn??'');
    pref.setString('adm_updatedby',unRegTickets[index].admUpdatedBy??'');



    Navigator.push(context,MaterialPageRoute(builder: (context)=>UnRegTickets_View()));
  }


    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      fetchRegTickets();
    });
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets List'),
        backgroundColor: Color(0Xff146bf7),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: RefreshIndicator(
            onRefresh: refreshListener,
            backgroundColor: Colors.blue,
            color: Colors.white,
            child: Column(
              children: [
                Visibility(
                  visible: retryVisible,
                  child : Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: InkWell(
                        child:Text("Load Failed, Tap here to retry !",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        onTap: () => setState(()
                        {
                          fetchRegTickets();
                        })),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    itemCount: unRegTickets.length,
                      itemBuilder: (BuildContext context,int index){
                    return Container(
                      child:
                      ListTile(
                        onTap: (){
                          ticketsDataToView(index);
                        },
                        leading: CircleAvatar(backgroundImage: NetworkImage(unRegTickets[index].logo),),
                          title: Text(unRegTickets[index].username[0].toUpperCase()+unRegTickets[index].username.substring(1), style: TextStyle(
                              fontSize: 17.5),),
                        subtitle: Text(unRegTickets[index].createdOn),
                        trailing: IconButton(
                          onPressed: () {
                            ticketsDataToView(index);
                          },
                          icon: Icon(
                            Icons.arrow_right, size: 35,
                            color: Colors.blueAccent,),
                        ),
                      ),
                    );
                  })
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class GetUnreg {
  String registerId ='' ;
  String companyname='';
  String clientname='';
  String username='';
  String password='';
  String logo='';
  String email='';
  String phonenumber='';
  String domainName='';
  String description='';
  String createdOn='';
  String status='';
  String admUpdatedOn='';
  String admUpdatedBy='';

  GetUnreg(
      {required this.registerId,
        required this.companyname,
        required this.clientname,
        required this.username,
        required this.password,
        required this.logo,
        required this.email,
        required this.phonenumber,
        required this.domainName,
        required this.description,
        required this.createdOn,
        required this.status,
        required this.admUpdatedOn,
        required this.admUpdatedBy});

  GetUnreg.fromJson(Map<String, dynamic> json) {
    registerId = json['registerId'].toString();
    companyname = json['Companyname'];
    clientname = json['Clientname'];
    username = json['Username'];
    password = json['Password'];
    logo = json['Logo'];
    email = json['Email'];
    phonenumber = json['Phonenumber'];
    domainName = json['DomainName'];
    description = json['Description'];
    createdOn = json['CreatedOn'];
    status = json['Status'];
    admUpdatedOn = json['Adm_UpdatedOn'];
    admUpdatedBy = json['Adm_UpdatedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['registerId'] = this.registerId;
    data['Companyname'] = this.companyname;
    data['Clientname'] = this.clientname;
    data['Username'] = this.username;
    data['Password'] = this.password;
    data['Logo'] = this.logo;
    data['Email'] = this.email;
    data['Phonenumber'] = this.phonenumber;
    data['DomainName'] = this.domainName;
    data['Description'] = this.description;
    data['CreatedOn'] = this.createdOn;
    data['Status'] = this.status;
    data['Adm_UpdatedOn'] = this.admUpdatedOn;
    data['Adm_UpdatedBy'] = this.admUpdatedBy;
    return data;
  }
}