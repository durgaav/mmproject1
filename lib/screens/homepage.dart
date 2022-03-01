import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mmcustomerservice/screens/admin/notifyScreen.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'mainmenus.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  //region Global variables
  int notifyUnSeenCount = 0;
  int teamCount = 0;
  int ticketCount = 0;
  int clientCount = 0;

  double opacity = 0.0;
  String usertype = "";
  bool admin = false;
  bool users = false;
  bool team = false;
  String currentUser = '';
  String proCode = '';
  bool notiIconVisi = false;
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm:ss a');

  TextEditingController emailController = TextEditingController();
  TextEditingController phnoController = TextEditingController();
  TextEditingController domainController = TextEditingController();
  TextEditingController dsController = TextEditingController();

  String dropdownValue = "select category";
  final List<String> datas = [
    "images",
    "pdf",
    'zip','doc',
    'docx',"select category"
  ];
  PlatformFile? file;

  //file upload
  String extention = "*";
  // File _image = new File("");
//  File _datas = new File("");
  String imgPath = "";
  // List<File> _images = <File>[];
  //List <File> _dataList = [];
  List<File> files =[];
  bool imageremove = true;
  bool fileremove = true;
  bool filevisible = false;
  bool imgvisible = false;

  //

//endregion

  //region Logics
  Future<void> fetchAllCounting() async {
    showAlert(context);
    try {
      http.Response response = await http.get(Uri.parse("https://mindmadetech.in/api/dashboard/allcounts"));
      if (response.statusCode == 200) {
        Map<String, dynamic> map = new Map<String, dynamic>.from(jsonDecode(response.body));
        clientCount = map['customer'];
        teamCount = map['team'];
        ticketCount = map['tickets'];
        //notifyUnSeenCount
        notifyUnSeenCount = map['notifyunseen'];
        setState(() {
          if(notifyUnSeenCount==0){
            opacity = 0.0;
          }else{
            opacity = 1.0;
          }
          //tap again - false
          admin = true;
          notiIconVisi=true;
        });
        Navigator.pop(context);
      }
      else {
        //tap again - visible
        Navigator.pop(context);
        onNetworkChecking();
      }
    }
    catch(Exception)
    {
      //tap again - visible
      Navigator.pop(context);
      onNetworkChecking();
    }
  }

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
                        color: Colors.deepPurpleAccent,
                      ),
                      Text(' please wait...',style: TextStyle(fontSize: 18),),
                    ],
                  )
              )
          );
        }
    );
  }

  Future<void> fetchClientDetails() async{
    http.Response response = await http.get(Uri.parse("https://mindmadetech.in/api/customer/list"));
    if(response.statusCode==200){
      List list = jsonDecode(response.body);
      List filterUser = list.where((element) => element['Username']=="$currentUser").toList();
      setState(() {
        proCode = filterUser.map((e) => e['Projectcode']).toString().replaceAll("(", "").replaceAll(")", "");
      });
      print(proCode);
    }
  }

  Future screenVisibility() async{
    var pref = await SharedPreferences.getInstance();
    String userType = pref.getString('usertype') ?? '';
    String currentUserStr = pref.getString('username')  ?? '';
    if(userType=="admin"){
      setState(() {
        usertype = userType;
        currentUser = currentUserStr;
      });
      fetchAllCounting();
    }
    else if(userType=="team"){
      setState(() {
        team = true;
        notiIconVisi=false;
        usertype = userType;
        currentUser = currentUserStr;
      });
    }
    else{
      setState(() {
        users = true;
        notiIconVisi=false;
        usertype = userType;
        currentUser = currentUserStr;
        fetchClientDetails();
      });
    }
    print(admin.toString()+users.toString()+team.toString());
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


  // void selectfile(BuildContext context) {
  //   //Navigator.of(context);
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (context) {
  //         return Container(
  //           height: 150,
  //           color: Colors.white,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: [
  //               Container(
  //                 child: Text('Select file type',
  //                   style: TextStyle(
  //                       fontSize: 18, fontWeight: FontWeight.bold),),
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   GestureDetector(
  //                       onTap: () {
  //                         setState(() {
  //                           dropdownValue = 'pdf';
  //                           picker();
  //                           print(dropdownValue);
  //                         });
  //                       },
  //                       child: Column(
  //                         children: [
  //                           Container(
  //                             width: 50,
  //                             height: 50,
  //                             child: Image(
  //                               image: AssetImage(
  //                                   'assets/images/pdficon.png'),),
  //                           ),
  //                           Container(
  //                             padding: EdgeInsets.only(top: 5),
  //                             child: Text('PDF',
  //                               style: TextStyle(fontWeight: FontWeight.bold),),
  //                           )
  //                         ],
  //                       )
  //                   ),
  //                   GestureDetector(
  //                       onTap: () {
  //                         setState(() {
  //                           dropdownValue = 'images';
  //                           picker();
  //                           print(dropdownValue);
  //
  //                         });
  //                       },
  //                       child: Column(
  //                         children: [
  //                           Container(
  //                             width: 50,
  //                             height: 50,
  //                             child: Image(
  //                               image: AssetImage('assets/images/image.jpeg'),),
  //                           ),
  //                           Container(
  //                             padding: EdgeInsets.only(top: 5),
  //                             child: Text('Images',
  //                               style: TextStyle(fontWeight: FontWeight.bold),),
  //                           )
  //                         ],
  //                       )
  //                   ),
  //                   GestureDetector(
  //                       onTap: () {
  //                         dropdownValue = 'doc';
  //                         picker();
  //                         print(dropdownValue);
  //                       },
  //                       child: Column(
  //                         children: [
  //                           Container(
  //                             width: 50,
  //                             height: 50,
  //                             child: Image(
  //                               image: AssetImage('assets/images/doc.jpeg'),),
  //                           ),
  //                           Container(
  //                             padding: EdgeInsets.only(top: 5),
  //                             child: Text('Documnet',
  //                               style: TextStyle(fontWeight: FontWeight.bold),),
  //                           )
  //                         ],
  //                       )
  //                   ),
  //                   GestureDetector(
  //                       onTap: () {
  //                         dropdownValue = 'zip';
  //                         picker();
  //                         print(dropdownValue);
  //                       },
  //                       child: Column(
  //                         children: [
  //                           Container(
  //                             width: 50,
  //                             height: 50,
  //                             child: Image(
  //                               image: AssetImage('assets/images/zip.jpeg'),),
  //                           ),
  //                           Container(
  //                             padding: EdgeInsets.only(top: 5),
  //                             child: Text('Zip',
  //                               style: TextStyle(fontWeight: FontWeight.bold),),
  //                           )
  //                         ],
  //                       )
  //                   ),
  //
  //                 ],
  //               )
  //
  //             ],
  //           ),
  //         );
  //       });
  // }
  //
  void picker() async{
    print("image path"+imgPath);
    print("Entering to file picker........");
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true,);
    PlatformFile file = result.files.first;

    if(result!=""){
      imgPath = file.path.toString();
      // _datas = File(imgPath);
      // _dataList.add(File(imgPath));
      files = result!.paths.map((path) => File(path!)).toList();
      print(files);
      extention = file.extension;
      // print (_dataList.toString());

    }
  }

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
                  // if (_images.length == -1) {
                  //   imageremove = false;
                });
              },
              icon: Icon(Icons.close,color: Colors.red,size: 30,),
            ),
          );
        });
  }


  Future AddNewTicket(String Username, String Email, String Phonenumber,
      String DomainName, String Description, BuildContext context) async {
    print("Exten........." + Username);
    //showAlert(context);
    final request = http.MultipartRequest(
        'POST', Uri.parse('https://mindmadetech.in/api/tickets/new')
    );

    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields.addAll
      ({
      'Username': Username,
      'Email': Email,
      'Phonenumber': Phonenumber,
      'DomainName': DomainName,
      'Projectcode':'$proCode',
      'Description': Description,
      'Cus_CreatedOn':formatter.format(DateTime.now()),
    });

    if(files!=null) {
      int i=0;
      for(i = 0; i < files.length; i++) {
        int rowcount = i;
        File singleImage = files[rowcount];
        print(singleImage);
        print("Imagessssss");
        if(files.contains('.jpg')||files.contains('.png')||files.contains('svg')||files.contains('jpeg')){
          request.files.add(
              await http.MultipartFile.fromPath(
                  'files', singleImage.path, filename: Path.basename(singleImage.path),
                  contentType: MediaType.parse("image/$extention")
              ));
        }else if(files.contains('.docx')){
          request.files.add(
              await http.MultipartFile.fromPath(
                  'files', singleImage.path, filename: Path.basename(singleImage.path),
                  contentType: MediaType.parse(
                      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                  )
              ));
        }else if(files.contains('.zip')){
          request.files.add(
              await http.MultipartFile.fromPath(
                  'files', singleImage.path, filename: Path.basename(singleImage.path),
                  contentType: MediaType.parse("application/$extention")
              ));
        }
      }
    }else if(files==null){
      print('no selected images');
    }
    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      String res = await response.stream.bytesToString();
      // Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Ticket added successfully!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 15.0
      );
      print("Image Uploaded");
      return res;
    } else {
      // Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Failed to add Ticket',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0
      );
      print("Upload Failed");
    }
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  // Future AddNewTicket(String Username, String Email, String Phonenumber,
  //     String DomainName, String Description, BuildContext context) async {
  //   print("Exten........." + Username);
  //   showAlert(context);
  //   final request = http.MultipartRequest(
  //       'POST', Uri.parse('https://mindmadetech.in/api/tickets/new')
  //   );
  //
  //   request.headers['Content-Type'] = 'multipart/form-data';
  //   request.fields.addAll
  //     ({
  //     'Username': Username,
  //     'Email': Email,
  //     'Phonenumber': Phonenumber,
  //     'DomainName': DomainName,
  //     'Projectcode':'$proCode',
  //     'Description': Description,
  //     'Cus_CreatedOn':formatter.format(DateTime.now()),
  //   });
  //
  //   // if(dropdownValue == "images") {
  //   //   int i=0;
  //   //   for(i = 0; i < _images.length; i++) {
  //   //     int rowcount = i;
  //   //     File singleImage = _images[rowcount];
  //   //     print(singleImage);
  //   //     print("Imagessssss");
  //   //     request.files.add(
  //   //         await http.MultipartFile.fromPath(
  //   //             'files', singleImage.path, filename: Path.basename(singleImage.path),
  //   //             contentType: MediaType.parse("image/$extention")
  //   //         ));
  //   //   }
  //   // }
  //   // else if(dropdownValue == "docx"){
  //   //   int i=0;
  //   //   for(i = 0; i < _dataList.length; i++) {
  //   //     int rowcount = i;
  //   //     File singleImage = _dataList[rowcount];
  //   //     print(singleImage);
  //   //     print("docxxx");
  //   //     request.files.add(
  //   //         await http.MultipartFile.fromPath(
  //   //             'files', singleImage.path, filename: Path.basename(singleImage.path),
  //   //             contentType: MediaType.parse(
  //   //                 "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  //   //             )
  //   //         )
  //   //     );
  //   //   }
  //   // }
  //   // else if(dropdownValue == "doc"){
  //   //   int i=0;
  //   //   for(i = 0; i < _dataList.length; i++) {
  //   //     int rowcount = i;
  //   //     File singleImage = _dataList[rowcount];
  //   //     print(singleImage);
  //   //     print("doccc");
  //   //     request.files.add(
  //   //         await http.MultipartFile.fromPath(
  //   //             'files', singleImage.path, filename: Path.basename(singleImage.path),
  //   //             contentType: MediaType.parse("application/$extention")
  //   //         )
  //   //     );
  //   //   }
  //   // }
  //   // else if(dropdownValue == "pdf"){
  //   //   int i=0;
  //   //   for(i = 0; i < _dataList.length; i++) {
  //   //     int rowcount = i;
  //   //     File singleImage = _dataList[rowcount];
  //   //     print(singleImage);
  //   //     print("pdfff");
  //   //     request.files.add(
  //   //         await http.MultipartFile.fromPath(
  //   //             'files', singleImage.path, filename: Path.basename(singleImage.path),
  //   //             contentType: MediaType.parse("application/$extention")
  //   //         )
  //   //     );
  //   //   }
  //   // }
  //   // else if(dropdownValue == "zip"){
  //   //   int i=0;
  //   //   for(i = 0; i < _dataList.length; i++) {
  //   //     int rowcount = i;
  //   //     File singleImage = _dataList[rowcount];
  //   //     print(singleImage);
  //   //     print("zip...");
  //   //     request.files.add(
  //   //         await http.MultipartFile.fromPath(
  //   //             'files', singleImage.path, filename: Path.basename(singleImage.path),
  //   //             contentType: MediaType.parse("application/x-zip-compressed")
  //   //         )
  //   //     );
  //   //   }
  //   //   print("zip....");
  //   // }
  //
  //   http.StreamedResponse response = await request.send();
  //   print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     String res = await response.stream.bytesToString();
  //     Navigator.pop(context);
  //     Fluttertoast.showToast(
  //         msg: 'Ticket added successfully!',
  //         toastLength: Toast.LENGTH_LONG,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.green,
  //         textColor: Colors.white,
  //         fontSize: 15.0
  //     );
  //     print("Image Uploaded");
  //     return response;
  //   } else {
  //     Navigator.pop(context);
  //     Fluttertoast.showToast(
  //         msg: 'Failed to add Ticket',
  //         toastLength: Toast.LENGTH_LONG,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 15.0
  //     );
  //     print("Upload Failed");
  //   }
  //   response.stream.transform(utf8.decoder).listen((value) {
  //     print(value);
  //   });
  // }

  //endregion

  void showfiles(){
    if(files != null){
      imgvisible = true;
      filevisible = true;
    }
  }
  //endregion

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration
        .zero, () async {
      screenVisibility();
      showfiles();
    });
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController userController = TextEditingController(text: "$currentUser");
    return Scaffold(
        drawer:MainMenus(usertype: usertype, currentUser: currentUser),
        appBar: AppBar(
            backgroundColor: Color(0Xff146bf7),
            title: Text('Dashboard'),
            actions: <Widget>[
              IconButton(
                padding: EdgeInsets.only(right: 20),
                icon: const Icon(Icons.refresh,size: 27,),
                onPressed: (){
                  setState(() {
                    screenVisibility();
                  });
                },
              ),
              Visibility(
                visible: notiIconVisi,
                child: Container(
                  child: Stack(
                    children:<Widget> [
                      IconButton(
                        padding: EdgeInsets.only(right: 20),
                        icon: const Icon(Icons.add_alert,size: 30,),
                        onPressed: (){
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>NotifScreen()),);
                        },
                      ),
                      Positioned(
                        top: 4,
                        right: 10,
                        child: Opacity(
                          opacity:opacity,
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context)=>NotifScreen()),);
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 10,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text("$notifyUnSeenCount",style: TextStyle(color:Colors.white,fontSize: 10,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ),

            ]
        ),

        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 1.0,
            padding: EdgeInsets.symmetric(vertical: 40),
            color: Color(0XFFebf2fa),
            child:
            (users == true) ?SingleChildScrollView(
                child: Form(
                    child:Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                              hintText: 'Enter a Username',
                              labelText: 'UserName',
                            ),
                            controller:userController ,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter a Emailid',
                              labelText: 'Email',
                            ),
                            controller: emailController,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter a Number',
                              labelText: 'Phone Number',
                            ),
                            controller: phnoController,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter a Domain Name',
                              labelText: 'Domain Name',
                            ),
                            controller: domainController,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                hintText: 'Enter your Issue',
                                labelText: 'Description'
                            ),
                            maxLines: 100,
                            minLines: 3,
                            controller: dsController,
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
                                child: Text('Choose file',style: TextStyle(fontSize: 17),),
                              ),

                              ElevatedButton(onPressed: () {
                                if(currentUser.isEmpty||emailController.text.isEmpty||dsController.text.isEmpty||
                                    domainController.text.isEmpty||phnoController.text.length<10
                                ){
                                  print("value not entered......");
                                  Fluttertoast.showToast(
                                      msg: 'Please enter all detailes!',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 15.0
                                  );
                                }else {
                                  AddNewTicket(
                                      userController.text.toString(),
                                      emailController.text.toString(),
                                      phnoController.text.toString(),
                                      domainController.text.toString(),
                                      dsController.text.toString(), context);
                                }
                                filevisible =  false;
                                imgvisible = false;
                              },
                                style: ElevatedButton.styleFrom(
                                  shape: StadiumBorder(),
                                  onPrimary: Colors.white,
                                ),child: Text("submit",style: TextStyle(fontSize: 17),),),
                            ],
                          ),

                          Container(
                            height: 250,
                            child: ListView.builder(
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
                          // Visibility(
                          //     visible: imgvisible,
                          //     child: Column(
                          //       children: [
                          //         Container(
                          //           child:Text("Images",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          //         ),
                          //         Container(
                          //           height:200,
                          //           width:double.infinity,
                          //           child:GridView.builder(
                          //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          //                 crossAxisCount: 3,
                          //                 mainAxisSpacing: 10,),
                          //               itemCount: _images.length,
                          //               padding: EdgeInsets.all(8.0),
                          //               itemBuilder: (BuildContext context, int index) {
                          //                 return Container(
                          //                     margin: EdgeInsets.only(right: 10),
                          //                     width: 72,
                          //                     child:Stack(
                          //                       children: [
                          //                         Container(
                          //                             width: 320,
                          //                             child: GestureDetector(
                          //                                 child: Image.file(_images[index], fit: BoxFit.cover))
                          //                         ),
                          //                         Positioned(
                          //                           right: 0.1,
                          //                           child: InkWell(
                          //                             child: Icon(
                          //                               Icons.remove_circle,
                          //                               size: 20,
                          //                               color: Colors.red,
                          //                             ),
                          //                             onTap: () {
                          //                               _images.removeAt(index);
                          //                               setState(() {
                          //                                 if (_images.length == -1) {
                          //                                   imageremove = false;
                          //                                 }});
                          //                             },),
                          //                         )
                          //                       ],
                          //                     )
                          //                 );}
                          //           ),
                          //         )
                          //       ],
                          //     )
                          // ),
                          // Visibility(
                          //     visible: filevisible,
                          //     child:Column(
                          //       children: [
                          //         Container(
                          //           padding: EdgeInsets.only(top:5),
                          //           child:Text("Other files",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          //         ),
                          //         Container(
                          //           height:200,
                          //           width:double.infinity,
                          //           child:ListView.builder(
                          //               scrollDirection: Axis.horizontal,
                          //               itemCount: _dataList.length,
                          //               padding: EdgeInsets.all(8.0),
                          //               itemBuilder: (BuildContext context,
                          //                   int index) {
                          //                 return Container(
                          //                     margin: EdgeInsets.only(right: 10),
                          //                     width: 72,
                          //                     child: Stack(
                          //                         children: <Widget>[
                          //                           Container(
                          //                               height: 70,
                          //                               color: Colors.white,
                          //                               child:
                          //                               (_dataList.contains('pdf'))?
                          //                               //Text("pdffff",style: TextStyle(color: Colors.red),):
                          //                               Image(image: AssetImage('assets/images/pdficon.png'),) :
                          //                               (_dataList.contains('zip'))?
                          //                               Image(image: AssetImage('assets/images/zip.jpeg')) :
                          //                               (_dataList.contains('doc'))?
                          //                               Image(image: AssetImage('assets/images/doc.jpeg')):
                          //                               (_dataList.contains('docx'))?
                          //                               Image(image: AssetImage('assets/images/doc.jpeg')):Container()
                          //                           ),
                          //                           Positioned(
                          //                             right: 0.1,
                          //                             child: InkWell(
                          //                               child: Icon(
                          //                                 Icons.remove_circle,
                          //                                 size: 20,
                          //                                 color: Colors.red,
                          //                               ),
                          //                               onTap: () {
                          //                                 _dataList.removeAt(index);
                          //                                 setState(() {
                          //                                   if (_dataList.length == -1) {
                          //                                     fileremove = false;
                          //                                   }
                          //                                 });
                          //                               },
                          //                             ),
                          //                           )
                          //                         ]
                          //                     )
                          //                 );}
                          //           ),
                          //         )
                          //       ],
                          //     )
                          // )
                        ],
                      ),
                    )
                )
            ):
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                          ),
                        ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            child: (team == true) ? Text("Tickets Assigned",
                              style: TextStyle(fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),) :
                            Text("No of Tickets",
                              style: TextStyle(fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),)
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 20),

                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: (team == true) ? Text("10",
                                    style: TextStyle(
                                        fontSize: 32, fontWeight: FontWeight.bold,
                                        color: Color(0XFF0949b0)),) :
                                  Text("$ticketCount",
                                    style: TextStyle(
                                        fontSize: 32, fontWeight: FontWeight.bold,
                                        color: Color(0XFF0949b0)),),
                                ),
                                Container(
                                    child: Icon(Icons.confirmation_number_sharp,
                                      color: Colors.blue, size: 48,)
                                ),
                              ]
                          ),
                        ),
                        Container(
                          child: Text("Last Ticket No",
                            style: TextStyle(color: Colors.black54),),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30,),

                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,),
                        ]
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: (team == true) ? Text("Tickets In progress",
                              style: TextStyle(fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),) :
                            Text("No of Users",
                              style: TextStyle(fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 20),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[

                                  Container(
                                    child: (team == true) ? Text("5",
                                      style: TextStyle(fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0XFF0949b0)),) :
                                    Text("$clientCount",
                                      style: TextStyle(fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0XFF0949b0)),),
                                  ),
                                  Container(
                                      child: Icon(Icons.groups_sharp,
                                        color: Colors.blue, size: 48,)
                                  ),
                                ]
                            ),
                          ),

                          Container(
                            child: Text("Last Ticket No",
                              style: TextStyle(color: Colors.black54),),
                          ),

                        ]
                    ),
                  ),

                  SizedBox(height: 30,),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    width: 300,
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                          ), //BoxShadow
                        ]
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: (team == true) ? Text("Tickets Completed",
                              style: TextStyle(fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),) :
                            Text("Team members ",
                              style: TextStyle(fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 20),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: (team == true) ? Text("7",
                                      style: TextStyle(fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0XFF0949b0)),) :
                                    Text("$teamCount",
                                      style: TextStyle(fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0XFF0949b0)),),
                                  ),
                                  Container(
                                      child: Icon(Icons
                                          .confirmation_number_outlined,
                                        color: Colors.blue, size: 48,)
                                  ),
                                ]
                            ),
                          ),
                          Container(
                            child: Text("Last Ticket No",
                              style: TextStyle(color: Colors.black54),),
                          ),
                        ]
                    ),

                  ),
                ],
              ),
            )
        ));
  }
}

