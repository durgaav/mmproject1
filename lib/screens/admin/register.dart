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
  String imgPath = "";
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
  bool _obscured = true;
  bool imageremove = true;
  bool fileremove = true;
  bool filevisible = false;
  bool imgvisible = false;

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


  Future AddTicket(String cmp,String clname,String user,String passwrd,String email,
      String phno,String doname,String description) async {

    final request = http.MultipartRequest(
        'POST', Uri.parse('https://mindmadetech.in/api/unregisteredcustomer/new')
    );
   // showAlert(context);

    if(files.isEmpty){
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
      // request.files.add(await http.MultipartFile.fromPath('files', '/path/to/file'));
      http.StreamedResponse response = await request.send();
      String res = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        Navigator.pop(context);
        if(res.contains('Ticket added successfully')){
          setState(() {
            Cmpname = TextEditingController();
            Clientname = TextEditingController();
            pass = TextEditingController();
            mailController = TextEditingController();
            phnoController = TextEditingController();
            domainController = TextEditingController();
            dsController = TextEditingController();
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
            Cmpname = TextEditingController();
            Clientname = TextEditingController();
            pass = TextEditingController();
            mailController = TextEditingController();
            phnoController = TextEditingController();
            domainController = TextEditingController();
            dsController = TextEditingController();
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


  void showfiles(){
    if(files != null){
      imgvisible = true;
      filevisible = true;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
        Duration.zero, () async {
      showfiles();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color(0Xff146bf7),
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
                  hintText: 'Enter a Companyname',
                  labelText: 'Companyname',
                  // prefixIcon: Icon(Icons.lock_outline_rounded,
                  //     color: Colors.black45),
                  border: OutlineInputBorder(),
                ),
                controller:Cmpname ,
              ),
            ),
            SizedBox(height:10,),
            Container(
              height: 45,
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter a Clientname',
                  labelText: 'Clientname',
                    border: OutlineInputBorder(),
                    // prefixIcon: Icon(Icons.person,
                    //   color: Colors.black45),
                ),
                controller:Clientname ,
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
                    // prefixIcon: Icon(Icons.person,
                    //   color: Colors.black45),
                ),
                controller:userController ,
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
                  // prefixIcon: Icon(Icons.lock_outline_rounded,
                  //     color: Colors.black45),
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
                  // prefixIcon: Icon(Icons.mail,
                  //     color: Colors.black45),
                ),
                controller: mailController,
              ),
            ),
            SizedBox(height:10,),

            Container(
              height: 45,
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter a Phonenumber',
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  // prefixIcon: Icon(Icons.phone,
                  //     color: Colors.black45),
                ),
                controller: phnoController,
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
                  // prefixIcon: Icon(Icons.lock_outline_rounded,
                  //     color: Colors.black45),
                ),
                controller: domainController,
              ),
            ),
            SizedBox(height:10,),

            TextFormField(
              decoration: InputDecoration(
                  hintText: 'Enter your Issue',
                  labelText: 'Description',
                border: OutlineInputBorder(),
                // prefixIcon: Icon(Icons.lock_outline_rounded,
                //     color: Colors.black45),
              ),
              maxLines: 100,
              minLines: 3,
              controller: dsController,
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
                            },
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              onPrimary: Colors.white,
                            ),child: Text('Choose File'),
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
                        }else{
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
