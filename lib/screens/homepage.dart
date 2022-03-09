
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mmcustomerservice/screens/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mmcustomerservice/screens/admin/notifyScreen.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'mainmenus.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';

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
  var counts = 0;
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm:ss a');


  List countList = [];
  int cmCount=0;
  int countIn =0;
  int nCount =0;


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
  List extensions =[];
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
        counts = map['notifyunseen'];
        setState(() {
          if(counts==0){
            opacity = 0.0;
          }else{
            context.read<Data>().setCount(counts);
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

  Future<void> Counttk() async {
    print('Current user...... $currentUser');
    showAlert(context);
    try {
      http.Response res =
      await http.get(Uri.parse(
          'https://mindmadetech.in/api/tickets/Teamtickets/$currentUser'));
      if (res.statusCode == 200) {
        List body = json.decode(res.body);
        countList = body.toList();
        List comCount = body.where((e) => e['Status'].toLowerCase() == 'completed').toList();

        List inCounts = body.where((e) => e['Status'].toLowerCase() == 'inprogress').toList();

        List newCount = body.where((e) => e['Status'].toLowerCase() == 'new').toList();

        setState(() {
          cmCount = comCount.length;
          print(comCount.length);
          print('completed' + ' $cmCount');

          countIn = inCounts.length;
          print(inCounts.length);
          print('Inprogress' + '$countIn');

          nCount = newCount.length;
          print(newCount.length);
          print('Assign' + '$nCount');
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
        Counttk();
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


  Future AddNewTicket(String Username, String Email, String Phonenumber,
      String DomainName, String Description, BuildContext context) async {

    final request = http.MultipartRequest(
        'POST', Uri.parse('https://mindmadetech.in/api/tickets/new')
    );
    showAlert(context);

    if(files.isEmpty){
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
      // request.files.add(await http.MultipartFile.fromPath('files', '/path/to/file'));
      http.StreamedResponse response = await request.send();
      String res = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        Navigator.pop(context);
        if(res.contains('Ticket added successfully')){
          setState(() {
            emailController = new TextEditingController(text: "");
            phnoController = new TextEditingController(text: "");
            domainController = new TextEditingController(text: "");
            dsController = new TextEditingController(text: "");
          });
          Fluttertoast.showToast(
              msg:res.replaceAll("{", "").replaceAll("}", ""),
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
        Navigator.pop(context);
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
    }else{
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
      for(int i =0 ; i<files.length ;i++){
        request.files.add(await http.MultipartFile.fromPath('files', files[i].path,
            filename: Path.basename(files[i].path),
            contentType: MediaType.parse(extensions[i].toString())
        ));
      }
      // request.files.add(await http.MultipartFile.fromPath('files', '/path/to/file'));
      http.StreamedResponse response = await request.send();
      String res = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        Navigator.pop(context);
        if(res.contains('Ticket added successfully')){
          setState(() {
            emailController = new TextEditingController(text: "");
            phnoController = new TextEditingController(text: "");
            domainController = new TextEditingController(text: "");
            dsController = new TextEditingController(text: "");
            extensions = [];
            files = [];
          });

          Fluttertoast.showToast(
              msg:res.replaceAll("{", "").replaceAll("}", ""),
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
        Navigator.pop(context);
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

  }

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
    Future.delayed(
        Duration.zero, () async {
      screenVisibility();
      showfiles();
    });
  }
  @override
  Widget build(BuildContext context) {
    counts = context.watch<Data>().getcounter();
    TextEditingController userController = TextEditingController(text: "$currentUser");
    return WillPopScope(
      onWillPop: () async{
        showDialog(
            barrierDismissible: false,
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
                        Text('  Exit Alert!',
                            style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    content: Text(
                      'Are you sure to leave this app?',
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
                          onPressed: (){
                            SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
                          },
                          child: Text('Exit',
                              style: TextStyle(fontSize: 16, color: Colors.red)))
                    ],
                  ));
            });
        return false;
      },
      child: Scaffold(
          drawer:MainMenus(usertype: usertype, currentUser: currentUser),
          appBar: AppBar(
              backgroundColor: Color(0Xff146bf7),
              title: Text('Dashboard'),
              actions: <Widget>[
                usertype!="client"
                    ?IconButton(
                  padding: EdgeInsets.only(right: 20),
                  icon: const Icon(Icons.refresh,size: 27,),
                  onPressed: (){
                    setState(() {
                      screenVisibility();
                    });
                  },
                )
                    :IconButton(
                  padding: EdgeInsets.only(right: 20),
                  icon: const Icon(Icons.exit_to_app,size: 27,),
                  onPressed: (){
                    SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
                  },
                ),
                Visibility(
                  visible: notiIconVisi,
                  child: Container(
                    child: Stack(
                      children:<Widget> [
                        IconButton(
                          padding: EdgeInsets.only(right: 20),
                          icon: const Icon(Icons.notifications,size: 30,),
                          onPressed: (){
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context)=>NotifScreen()),);
                          },
                        ),
                        Positioned(
                          top: 4,
                          right: 10,
                          child: Opacity(
                            opacity:counts!=0?1.0:0.0,
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
                                  child:Text("$counts",style: TextStyle(color:Colors.white,fontSize: 10,fontWeight: FontWeight.bold),),
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
              height: MediaQuery.of(context).size.height,
              color: Color(0XFFffffff),
              child:SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    (users == true)?
                    Column(
                      children: [
                        Text('Create New Ticket',style: TextStyle(
                          fontSize: 20
                        ),),
                        SizedBox(
                          height: 20,
                        ),
                        SingleChildScrollView(
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
                                          hintText: 'Enter a Email Id',
                                          labelText: 'Email',
                                        ),
                                        controller: emailController,
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
                                                    content: Text('Please fill correct values'),
                                                  backgroundColor: Colors.red[600],
                                                )
                                              );
                                            }else{
                                              AddNewTicket(
                                                  userController.text.toString(),
                                                  emailController.text.toString(),
                                                  phnoController.text.toString(),
                                                  domainController.text.toString(),
                                                  dsController.text.toString(), context );
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
                        )
                      ],
                    ):
                    Container(
                      width: MediaQuery.of(context).size.width,
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
                                          child: (team == true) ? Text("$nCount",
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
                                            child: (team == true) ? Text('$countIn',
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
                                            child: (team == true) ? Text('$cmCount',
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
                    ),
                  ],
                ),
              )

          )),
    );
  }
}


