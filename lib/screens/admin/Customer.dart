
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mmcustomerservice/screens/admin/customerviewpage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';
import 'package:http_parser/http_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customer extends StatefulWidget {
  @override
  _CustomerState createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {

  //region Variables
  //Strings
  String extention = "*";
  String searchText = "";
  String imgPath = "";
  String createdBy = '';
  bool clearSearch = false;
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm:ss a');
  //Edittext
  TextEditingController searchController = new TextEditingController();
  TextEditingController compName = new TextEditingController(), usrNm = new TextEditingController(), passWd = new TextEditingController(),
      mailId = new TextEditingController(),
      phnNum = new TextEditingController(),clientNm = new TextEditingController(),projectCode = new TextEditingController(text: "MM000");
  //List and File
  File _image = new File("");
  List<GetCustomer> data = [];
  //true false
  bool refresh = false;
  bool retryVisible = false;
  //endregion Variables

  //region Functions

  //ADD new customer dialog
  void dialogBuilder(BuildContext context) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:<Widget> [
                        GestureDetector(
                            onTap: () async {
                              print("image path" + imgPath);
                              print("Entering to file picker........");
                              FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                                type: FileType.image,
                              );
                              PlatformFile file = result.files.first;
                              if (result != "") {
                                setState(() {
                                  imgPath = file.path.toString();
                                });
                                _image = new File(imgPath);
                                extention = file.extension;
                                print("this is image : " +
                                    _image.absolute.path.toString());
                              }
                            },
                            child: imgPath == ""
                                ? CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              backgroundImage:
                              AssetImage('assets/images/user.png'),
                            )
                                : CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              backgroundImage: FileImage(File('$imgPath')),
                            )),
                        Container(
                          padding: EdgeInsets.only(left: 5),
                          height: 40,
                          width: 140,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter project code',
                            ),
                            controller: projectCode,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your Companyname',
                        labelText: 'Company name',
                      ),
                      controller: compName,
                      keyboardType: TextInputType.text,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter client name',
                        labelText: 'Client name',
                      ),
                      controller: clientNm,
                      keyboardType: TextInputType.text,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Enter a Username',
                        labelText: 'Username',
                      ),
                      controller: usrNm,
                      keyboardType: TextInputType.text,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Password here',
                        labelText: 'Password',
                      ),
                      controller: passWd,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    TextField(
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
                        labelText: 'Phone number',
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
                                      usrNm.text.isEmpty ||
                                      passWd.text.isEmpty ||
                                      mailId.text.isEmpty ||
                                      phnNum.text.length < 10 ||
                                      _image.path == ''||clientNm.text.isEmpty||projectCode.text.length<5&&projectCode.text.isEmpty) {
                                    print("value not entered......");
                                    Fluttertoast.showToast(
                                        msg: 'Please check your values!',
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 15.0);
                                  } else {
                                    AddNewUser(
                                        compName.text.toString(),
                                        usrNm.text.toString(),
                                        passWd.text.toString(),
                                        mailId.text.toString(),
                                        phnNum.text.toString(),
                                        clientNm.text.toString(),
                                        projectCode.text.toString(),
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

  //Add new customer logic
  Future AddNewUser(String comp, String user, String pass, String mail, String phn, String client,String proCode,BuildContext context) async {
    showAlert(context);
    print("procode...."+proCode);
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('https://mindmadetech.in/api/customer/new'));
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields.addAll({
        'Companyname': comp,
        'Clientname': client,
        'Username': user,
        'Password': pass,
        'Email': mail,
        'Phonenumber': phn,
        'Projectcode':proCode,
        'Createdon': formatter.format(DateTime.now()),
        'Createdby': '$createdBy'
      });
      request.files.add(await http.MultipartFile.fromPath('file', _image.path,
          filename: Path.basename(_image.path),
          contentType: MediaType.parse("image/$extention")));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String res = await response.stream.bytesToString();
        if (res.contains("Username already Exists!")||res.contains("Projectcode already Exists!")) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true).pop();
          Fluttertoast.showToast(
              msg: "Username/ProjectCode already Exists!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 15.0
          );
          return response;
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            fetchCustomer();
          });
          Fluttertoast.showToast(
              msg: 'Customer added successfully!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 15.0
          );
        }
      } else {
        onNetworkChecking();
        print(await response.stream.bytesToString());
        print(response.statusCode);
        print(response.reasonPhrase);
        Fluttertoast.showToast(
            msg: response.reasonPhrase.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0);
      }
    }catch(ex){
      onNetworkChecking();
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
  //Getting customer list
  Future<void> fetchCustomer() async {
    showAlert(context);
    try{
      http.Response response =
      await http.get(Uri.parse("https://mindmadetech.in/api/customer/list"));
      if (response.statusCode == 200) {
        List body = jsonDecode(response.body);
        List b = body.where((element) => element['Isdeleted'] == 'n').toList();
        setState(() {
          retryVisible = false;
          Navigator.pop(context);
          data = b.map((e) => GetCustomer.fromJson(e)).toList();
        });
      }else{
        setState(() {
          retryVisible = false;
        });
        Navigator.pop(context);
        onNetworkChecking();
      }
    }catch(ex){
      setState(() {
        retryVisible = true;
      });
      Navigator.pop(context);
      onNetworkChecking();
    }
  }

  //Network
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
  //Network
  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      //networkStatus = "offline";
      return false;
    }
  }

  //Loading login prefs
  Future<void> getPref() async {
    var pref = await SharedPreferences.getInstance();
    if (pref != null) {
      createdBy = pref.getString('username')!;
    }
    print("Created by = " + createdBy);
  }

  //Passing data to another screen
  void passDatatoScren(index)async {
    var pref = await SharedPreferences.getInstance();

    pref.remove('userId');
    pref.remove('cus_user');
    pref.remove('pass');
    pref.remove('email');
    pref.remove('phno');
    pref.remove('address');
    pref.remove('Cname');
    pref.remove('Clientname');
    pref.remove('Createdon');
    pref.remove('Createdby');
    pref.remove('Modifiedby');
    pref.remove('Modifiedon');
    pref.remove('Isdeleted');
    pref.remove('proCode');

    pref.setString('userId',data[index].usersId??'');
    pref.setString('cus_user',data[index].Username??'');
    pref.setString('cus_pass',data[index].Password??'');
    pref.setString('email',data[index].Email??'');
    pref.setString('phno',data[index].Phonenumber??'');
    pref.setString('address',data[index].Address??'');
    pref.setString('Cname',data[index].Companyname??'');
    pref.setString('Logo',data[index].Logo??'');
    pref.setString('Clientname',data[index].Clientname??'');
    pref.setString('Createdon',data[index].Createdon??'');
    pref.setString('Createdby',data[index].Createdby??'');
    pref.setString('Modifiedby',data[index].Modifiedby??'');
    pref.setString('Modifiedon',data[index].Modifiedon??'');
    pref.setString('Isdeleted',data[index].Isdeleted??'');
    pref.setString('proCode',data[index].proectCode??'');

    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewPage()),);
  }

  //Refesh list
  Future<void> refreshListener() async{
    setState(() {
      fetchCustomer();
    });
  }
  //endregion Functions

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    imgPath = "";
  }
  @override
  void initState() {
// TODO: implement initState
    super.initState();
    Future.delayed(Duration
        .zero, () async {
      fetchCustomer();
    });
    getPref();
    () async {
      var _permissionStatus = await Permission.storage.status;
      if (_permissionStatus != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        setState(() {
          _permissionStatus = permissionStatus;
        });
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dialogBuilder(context);
          print(MediaQuery.of(context).size.width);
          //showAlert(context);
        },
        child: Icon(
          Icons.add,
          size: 28,
        ),
        backgroundColor: Colors.blue,
      ),
      appBar: AppBar(
        backgroundColor: Color(0Xff146bf7),
        title: Container(
          child: TextField(
            style: TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchText = value;
                if(searchText.length > 0){
                  clearSearch = true;
                }else{
                  clearSearch = false;
                  FocusScope.of(context).unfocus();
                }
              });
            },
            decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                hintText: 'Search...',
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                suffixIcon: Visibility(
                  visible: clearSearch,
                  child: IconButton(
                    color: Colors.white,
                    iconSize: 16,
                    icon: Icon(
                      Icons.close,
                    ),
                    onPressed: () {
                      setState(() {
                        searchText = "";
                        searchController.clear();
                        FocusScope.of(context).unfocus();
                        clearSearch = false;
                      });
                    },
                  ),
                )),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //Refrsh visible
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
                            fetchCustomer();
                          })),
                    ),
                  ),
                  //Designs
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: RefreshIndicator(
                        onRefresh: refreshListener,
                        backgroundColor: Colors.blue,
                        color: Colors.white,
                        child: data.length>0?ListView.builder(
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                                return data[index].Username.toLowerCase().contains(searchText.toString().toLowerCase())
                                    ? Column(children: <Widget>[
                                  ListTile(
                                    onTap: () {
                                      passDatatoScren(index);
                                    },
                                    leading: Container(
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                        NetworkImage(data[index].Logo),
                                      ),
                                    ),
                                    title: Text(
                                      data[index].Username[0].toUpperCase() +
                                          data[index]
                                              .Username
                                              .substring(1)
                                              .toLowerCase(),
                                      style: TextStyle(fontSize: 17.5),
                                    ),
                                    subtitle: Text(data[index].proectCode.toString()),
                                    trailing: IconButton(
                                      onPressed: () {
                                        passDatatoScren(index);
                                      },
                                      icon: Icon(
                                        Icons.arrow_right,
                                        size: 35,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.black12,
                                  ),
                                ])
                                    : Container();

                            }):Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Text('No data found!',style: TextStyle(fontSize: 25,color: Colors.deepPurple),),
                          ),
                        )
                      ))
                ]),

        ),
      ),
    );
  }

}

class GetCustomer {
  String usersId;
  String Username;
  String Password;
  String Email;
  String Phonenumber;
  String Address;
  String Companyname;
  String Logo;
  String Clientname;
  String Createdon;
  String Createdby;
  String Modifiedon;
  String Modifiedby;
  String Isdeleted;
  String proectCode;

  GetCustomer(
      {required this.usersId,
      required this.Username,
        required this.proectCode,
      required this.Password,
      required this.Email,
      required this.Phonenumber,
      required this.Address,
      required this.Companyname,
      required this.Logo,
      required this.Clientname,
      required this.Createdby,
      required this.Createdon,
      required this.Modifiedby,
      required this.Modifiedon,
      required this.Isdeleted});

  factory GetCustomer.fromJson(Map<String, dynamic> json) {
    return GetCustomer(
        proectCode: json['Projectcode'].toString(),
        usersId: json['usersId'].toString(),
        Username: json['Username'].toString(),
        Password: json['Password'].toString(),
        Email: json['Email'].toString(),
        Phonenumber: json['Phonenumber'].toString(),
        Address: json['Address'].toString(),
        Companyname: json['Companyname'].toString(),
        Logo: json['Logo'].toString(),
        Clientname: json['Clientname'].toString(),
        Createdby: json['Createdby'].toString(),
        Createdon: json['Createdon'].toString(),
        Modifiedby: json['Modifiedby'].toString(),
        Modifiedon: json['Modifiedon'].toString(),
        Isdeleted: json['Isdeleted'].toString());
  }
}
