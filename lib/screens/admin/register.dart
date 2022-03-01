import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
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

  File _Profileimg = new File("");
  String extention = "*";
  String imgPath = "";
  DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
  bool _obscured = true;


  Future AddTickets(String cmp,String clname,String user,String passwrd,String email,
      String phno,String doname,String description) async{
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('https://mindmadetech.in/api/unregisteredcustomer/new'));
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields.addAll({
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
      request.files.add(await http.MultipartFile.fromPath('file', _Profileimg.path, filename: Path.basename(_Profileimg.path),
          contentType: MediaType.parse("image/$extention")
        )
          );

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String res = await response.stream.bytesToString();
        if (res.contains("Username already Exists!")) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true).pop();
          Fluttertoast.showToast(
              msg: 'Username already Exists!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 15.0);
          return response;
        } else {
          // Navigator.of(context, rootNavigator: true).pop();
          // Navigator.of(context, rootNavigator: true).pop();
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

                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 25,top: 10,bottom: 20),
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: CircleAvatar(
                          backgroundColor: Colors.deepPurpleAccent,
                          radius: 50,
                          backgroundImage: FileImage(File('$imgPath')),
                        ),
                      ),
                      Positioned(
                        left: 85,
                          top: 75,
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                             // color: Colors.black54,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt_rounded),
                              onPressed: () async{

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
                                    _Profileimg = new File(imgPath);
                                    extention = file.extension;
                                    print("this is image : " +
                                        _Profileimg.absolute.path.toString());
                                  }
                                // child: imgPath == ""
                                // ? CircleAvatar(
                                // radius: 50,
                                // backgroundColor: Colors.white,
                                // backgroundImage:
                                // AssetImage('assets/images/user.png'),
                                // )
                                //     : CircleAvatar(
                                // radius: 50,
                                // backgroundColor: Colors.white,
                                // backgroundImage: FileImage(File('$imgPath')),
                                // )


                              },
                              color: Colors.black,
                              alignment: Alignment.center,
                            ),
                          ))
                    ],
                  ),

        Form(
        child:Container(
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


                Container(
                  height: 60,
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(onPressed: () {
                    AddTickets(Cmpname.text.toString(), Clientname.text.toString(), userController.text.toString(),
                        pass.text.toString(), mailController.text.toString(), phnoController.text.toString(),
                        domainController.text.toString(), dsController.text.toString());
                  },
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      onPrimary: Colors.white,
                    ),child: Text("send",style: TextStyle(fontSize: 17),),),
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
