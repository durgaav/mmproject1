import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as Path;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController Cmpname = TextEditingController();
  TextEditingController Clientname = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController phnoController = TextEditingController();
  TextEditingController domainController = TextEditingController();
  TextEditingController dsController = TextEditingController();

  List<File> files =[];
  List extensions =[];
  List unAppTic = [];
  List filterdByPhn = [];
  String imgPath = "";
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
  bool _obscured = true;
  bool imageremove = true;
  bool fileremove = true;
  String userType = '';
  bool filevisible = false;
  bool imgvisible = false;
  String status = 'No status';
  String emailId = '';

  OpenFiles(List<PlatformFile> files){
    ListView.builder(
        itemCount: files.length,
        itemBuilder: (BuildContext context , index){
          return ListTile(
            leading: Icon(Icons.image,color: Colors.green,size: 40,),
            title: Text(files[index].path.split('/').last,style: TextStyle(fontSize: 14),),
            trailing: IconButton(
              onPressed: (){
                print('hi');
                setState(() {
                  files.removeAt(index);
                });
              },
              icon: Icon(Icons.close,color: Colors.red,size: 30,),
            ),
          );
        });
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

  Future AddTicket(String cmp,String clname,String user,String passwrd,String email,
      String phno,String doname,String description) async {
    showAlert(context);
    var pref = await SharedPreferences.getInstance();
    final request = http.MultipartRequest(
        'POST', Uri.parse('https://mindmadetech.in/api/unregisteredcustomer/new')
    );
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields.addAll
        ({
        'Companyname': cmp,
        'Clientname': clname,
        'Username': user,
        'Password': passwrd,
        'Email': email,
        'Phonenumber': phno,
        'DomainName':doname,
        'Description':description,
        'CreatedOn': formatter.format(DateTime.now()),
      });
        request.files.add(await http.MultipartFile.fromPath('file', files[0].path,
            filename: Path.basename(files[0].path),
            contentType: MediaType.parse(extensions[0].toString())));

      http.StreamedResponse response = await request.send();
      String res = await response.stream.bytesToString();
      print(response.statusCode);
      if (response.statusCode == 200) {
        Navigator.of(context);
        print('ticket');
        if(res != 'Ticket added successfully'){
          pref.setString('unregmailid', mailController.text);
          setState(() {
            emailId = pref.getString('unregmailid')??'';
            Cmpname = TextEditingController();
            Clientname = TextEditingController();
            pass = TextEditingController();
            mailController = TextEditingController();
            phnoController = TextEditingController();
            userController = TextEditingController();
            domainController = TextEditingController();
            dsController = TextEditingController();
            extensions = [];
            files = [];
          });
          Fluttertoast.showToast(
              msg: 'Ticket added successfully!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 15.0
          );
        }else{
          Navigator.of(context);
          Fluttertoast.showToast(
              msg: 'Failed to added Ticket',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 15.0
          );
        }
      }
      else {
        Navigator.of(context);
        Fluttertoast.showToast(
            msg:await response.reasonPhrase.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 15.0
        );
        print(response.reasonPhrase);
      }
  }

  void showfiles(){
    if(files != null){
      imgvisible = true;
      filevisible = true;
    }
  }

  Future<void> getTickets() async{
    var pref = await SharedPreferences.getInstance();
    try{
      http.Response response;
      response = await http.get(Uri.parse("https://mindmadetech.in/api/unregisteredcustomer/list"));
      if(response.statusCode==200){
        unAppTic = jsonDecode(response.body);
        setState(() {
          filterdByPhn = unAppTic.where((element) => element['Email'].toLowerCase() ==
              emailId.toLowerCase()).toList();
          status = filterdByPhn[0]['Status'].toString();
          if(status.toLowerCase() == 'approved'){
            pref.remove('unregmailid');
          }else if(status.toLowerCase() == 'reject'){
            pref.remove('unregmailid');
          }
        });ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.lightGreen,
                content: Text('Status fetched.'))
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red,
                content: Text('Something wen wrong please try again.')
            )
        );
      }
    }catch(ex){

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
              content: Text('Failed to fetch status...')
          )
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
        Duration.zero, () async {
          var pref = await SharedPreferences.getInstance();
          setState(() {
            emailId = pref.getString('unregmailid')??'';
            userType = pref.getString('usertype')??'';
            if(emailId==null){
              setState(() {
                emailId = '';
              });
            }
            if(userType=='unreguser'){
              getTickets();
            }
          });
         showfiles();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color(0Xff146bf7),
        actions: [
          userType=="unreguser"?PopupMenuButton(
              icon: Icon(Icons.info_outline , size: 30,),
              itemBuilder: (context) =>
                  [
                    PopupMenuItem(
                        enabled: false,
                        child:Text("$emailId")
                    ),
                    PopupMenuItem(
                        child:Row(
                          children: [
                            status.toLowerCase()=="pending"?
                            Icon(Icons.autorenew , color: Colors.blueAccent,):
                            status.toLowerCase()=="approved"?
                            Icon(CupertinoIcons.check_mark_circled_solid , color: Colors.green,):
                            status.toLowerCase()=="reject"?
                            Icon(Icons.close_outlined , color: Colors.red,):
                            Container(),
                            Text(
                              status.toLowerCase()=='pending'?' '
                                  '$status...    ':' $status    ',
                              style: TextStyle(
                              color: Colors.black
                            ),)
                          ],
                        )
                    ),
                    PopupMenuItem(
                        enabled: true,
                        child:Text("Refresh..."),
                        onTap: (){
                          setState(() {
                            getTickets();
                          });
                        },
                    ),
                  ]
          ):Container()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
                child:Container(
                  padding: EdgeInsets.only(top:20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Company name',
                            labelText: 'Company name',
                            border: OutlineInputBorder(),
                          ),
                          controller:Cmpname ,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(height:10,),
                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Client name',
                            labelText: 'Client name',
                            border: OutlineInputBorder(),
                          ),
                          controller:Clientname ,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(height:10,),

                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Username',
                            labelText: 'UserName',
                            border: OutlineInputBorder(),
                          ),
                          controller:userController ,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(height:10,),

                      Container(
                        height: 45,
                        child: TextFormField(
                          controller: pass,
                          obscureText: _obscured,
                          decoration:  InputDecoration(
                            border: OutlineInputBorder(),
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
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),
                      SizedBox(height:10,),

                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Emailid',
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          controller: mailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(height:10,),

                      Container(
                        height: 65,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Phonenumber',
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          controller: phnoController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                        ),
                      ),
                      SizedBox(height:10,),

                      Container(
                        height: 45,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter a Domain Name',
                            labelText: 'Domain Name',
                            border: OutlineInputBorder(),
                          ),
                          controller: domainController,
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(height:10,),

                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Enter your Issue',
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 100,
                        minLines: 3,
                        controller: dsController,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height:10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: ElevatedButton(
                              onPressed: () async{
                                print("image path"+imgPath);
                                print("Entering to file picker........");
                                FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,
                                  type: FileType.custom,
                                  allowedExtensions: ['jpg','jpeg','png'],
                                );
                                PlatformFile file = result.files.first;
                                if (result!=null){
                                  setState(() {
                                    files = result.paths.map((path) => File(path)).toList();
                                  });
                                  for(int i = 0;i<files.length ; i++){
                                    extensions.add(lookupMimeType(files[i].path));
                                  }
                                  print(extensions);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                onPrimary: Colors.white,
                              ),child: Text('Choose Profile...'),
                            ),
                          ),
                          Container(
                            height: 60,
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(onPressed: () {
                              if(Cmpname.text.isEmpty||Clientname.text.isEmpty||userController.text.isEmpty||
                                  pass.text.isEmpty||mailController.text.isEmpty||phnoController.text.isEmpty||domainController.text.isEmpty||dsController.text.isEmpty){
                                Fluttertoast.showToast(
                                    msg:'Please enter all details',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 15.0
                                );
                              }else if(files.isEmpty){
                                Fluttertoast.showToast(
                                    msg:'Please Select at-least one file',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 15.0
                                );
                              } else{
                                setState(() {
                                  showfiles();
                                });
                                AddTicket(Cmpname.text.toString(), Clientname.text.toString(), userController.text.toString(),
                                    pass.text.toString(), mailController.text.toString(), phnoController.text.toString(),
                                    domainController.text.toString(), dsController.text.toString());
                              }
                            },
                              style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                onPrimary: Colors.white,
                              ),child: Text("send",style: TextStyle(fontSize: 17),),),
                          ),
                        ],
                      ),
                      Container(
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: files.length,
                            itemBuilder: (BuildContext context , index){
                              return ListTile(
                                leading: Icon(Icons.image,color: Colors.green,size: 40,),
                                title: Text(files[index].path.split('/').last,style: TextStyle(fontSize: 14),),
                                trailing: IconButton(
                                  onPressed: (){
                                    print('hi');
                                    setState(() {
                                      files.removeAt(index);
                                      if (files.length == -1) {
                                        imageremove = false;
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.close,color: Colors.red,size: 30,),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}

