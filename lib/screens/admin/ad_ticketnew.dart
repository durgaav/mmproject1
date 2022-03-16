import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdticketNew extends StatefulWidget {
  const AdticketNew({Key? key}) : super(key: key);

  @override
  _AdticketNewState createState() => _AdticketNewState();
}


class _AdticketNewState extends State<AdticketNew> {

  Color green =Color(0xff198D0F);
  Color red = Color(0xffE33C3C);

  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');

  TextEditingController emailController = TextEditingController();
  TextEditingController phnoController = TextEditingController();
  TextEditingController domainController = TextEditingController();
  TextEditingController dsController = TextEditingController();

  PlatformFile? file;

  //file upload
  String extention = "*";
  String imgPath = "";
  List<File> files =[];
  List extensions =[];
  bool imageremove = true;
  bool fileremove = true;
  bool filevisible = false;
  bool imgvisible = false;
  //

//default loader
  showAlert(BuildContext context){
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Container(
              child: AlertDialog(
                  content:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:<Widget> [
                      CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                      Text(' Please wait...',style: TextStyle(fontSize: 18),),
                    ],
                  )
              )
          );
        }
    );
  }
  //end loader

  //network checking
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
  //end




  //file picker
  void picker() async{
    print("image path"+imgPath);
    print("Entering to file picker........");
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg','jpeg','png','zip','doc','docx','rar'],
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
  }
//end picker

  //file open
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
  //end open file


  //add new ticket
  Future AddNewTicket(String Email, String Phonenumber,
      String DomainName, String Description) async {
    showAlert(context);
      var pref = await SharedPreferences.getInstance();
      String  currentuser = pref.getString('usertype')??'';
      String currentUserStr = pref.getString('usertypeMail')  ?? '';
    try{
      final request = http.MultipartRequest(
          'POST', Uri.parse('https://mindmadetech.in/api/tickets/new')
      );
      print(files);
      if(files.isEmpty && currentuser == 'admin'){
        request.headers['Content-Type'] = 'multipart/form-data';
        request.fields.addAll
          ({
          'Email': Email,
          'Phonenumber': Phonenumber,
          'DomainName': DomainName,
          'Description': Description,
          'Cus_CreatedOn':'null',
          'Adm_CreatedOn':formatter.format(DateTime.now()),
          'Adm_CreatedBy':'$currentUserStr'
        });
        http.StreamedResponse response = await request.send();
        String res = await response.stream.bytesToString();
        if (response.statusCode == 200) {
          print(res);
          if(res.contains('{"statusCode":200,"message":"Submitted Successfully"}')){
            Navigator.pop(context);
            setState(() {
              emailController = new TextEditingController(text: "");
              phnoController = new TextEditingController(text: "");
              domainController = new TextEditingController(text: "");
              dsController = new TextEditingController(text: "");
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.done_all,color: Colors.white,),
                      Text(' Ticket added successfully'),
                    ],
                  ),
                  backgroundColor:green,
                  behavior: SnackBarBehavior.floating,
                )
            );
          }
        }
        else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.announcement_outlined,color: Colors.white,),
                    Text(    response.reasonPhrase.toString()),
                  ],
                ),
                backgroundColor:red,
                behavior: SnackBarBehavior.floating,
              )
          );
          print(response.reasonPhrase);
        }
      }else if(files.isNotEmpty && currentuser == 'admin'){
        print(files);
        request.headers['Content-Type'] = 'multipart/form-data';
        request.fields.addAll
          ({
          'Email': Email,
          'Phonenumber': Phonenumber,
          'DomainName': DomainName,
          'Description': Description,
          'Cus_CreatedOn':'null',
          'Adm_CreatedOn':formatter.format(DateTime.now()),
          'Adm_CreatedBy':'$currentUserStr'
        });
        for(int i =0 ; i<files.length ;i++){
          request.files.add(await http.MultipartFile.fromPath('files', files[i].path,
              filename: Path.basename(files[i].path),
              contentType: MediaType.parse(extensions[i].toString())
          ));
        }
        http.StreamedResponse response = await request.send();
        String res = await response.stream.bytesToString();
        if (response.statusCode == 200) {
          if(res.contains('{"statusCode":200,"message":"Submitted Successfully"}')){
            setState(() {
              emailController = new TextEditingController(text: "");
              phnoController = new TextEditingController(text: "");
              domainController = new TextEditingController(text: "");
              dsController = new TextEditingController(text: "");
              extensions = [];
              files = [];
            });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.done_all,color: Colors.white,),
                      Text('   Ticket added successfully'),
                    ],
                  ),
                  backgroundColor: green,
                  behavior: SnackBarBehavior.floating,
                )
              );
            Navigator.pop(context);

          }
        }
        else {
          Navigator.pop(context);
          onNetworkChecking();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.announcement_outlined,color: Colors.white,),
                    Text(  response.reasonPhrase.toString()),
                  ],
                ),
                backgroundColor:red,
                behavior: SnackBarBehavior.floating,
              )
          );
          print(response.reasonPhrase);
        }
      }

    }catch(ex){
      Navigator.pop(context);
      onNetworkChecking();
    }
  }
//endregion


  void showfiles(){
    if(files != null){
      imgvisible = true;
      filevisible = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: (){Navigator.pop(context);},
            icon:Icon(CupertinoIcons.back),
            iconSize: 30,
            splashColor: Colors.purpleAccent,
          ),
          backgroundColor: Color(0Xff146bf7),
        title: Text('New Ticket',style: TextStyle(fontFamily: 'Poppins'),),
        ),
      body:Container(
        child:   SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text('Create New Ticket',style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),),
              SizedBox(
                height: 20,
              ),
              Form(
                      child:Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter a Email Id',
                                  labelText: 'Email Id',
                                ),
                                controller:emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Enter Number',
                                labelText: 'Phone Number',
                              ),
                              controller: phnoController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,

                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Enter a Domain Name',
                                labelText: 'Domain Name',
                              ),
                              controller: domainController,
                              keyboardType: TextInputType.url,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter your Issue here',
                                  labelText: 'Description'
                              ),
                              maxLines: 100,
                              minLines: 3,
                              controller: dsController,
                              keyboardType: TextInputType.text,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(onPressed: () async {
                                  setState(() {
                                    showfiles();
                                  });
                                  picker();
                                },
                                  style: ElevatedButton.styleFrom(
                                    shape: StadiumBorder(),
                                    onPrimary: Colors.white,
                                  ),
                                  child: Text('Choose file...',style: TextStyle(fontSize: 17),),
                                ),

                                ElevatedButton(onPressed: () {
                                  if(emailController.text.isEmpty||
                                      phnoController.text.isEmpty||
                                      domainController.text.isEmpty||
                                      dsController.text.isEmpty||phnoController.text.length<10){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Fields cannot be blank'),
                                          backgroundColor: red,
                                        )
                                    );
                                  }else{
                                    AddNewTicket(
                                        emailController.text.toString(),
                                        phnoController.text.toString(),
                                        domainController.text.toString(),
                                        dsController.text.toString() );
                                  }
                                },
                                  style: ElevatedButton.styleFrom(
                                    shape: StadiumBorder(),
                                    onPrimary: Colors.white,
                                  ),child: Text("submit",style: TextStyle(fontSize: 17),),),
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
      )
    );
  }
}
