// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lod/load.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}
  GlobalKey<FormState> formst = GlobalKey<FormState>();
var username;
var email;
var password;

class _LoginState extends State<Login> {
  login()async{
  var formdata = formst.currentState;
  if(formdata!.validate()){
    var formdata = formst.currentState;
    formdata?.save();
    try {
      gettoload(context);
  UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password
  );
  return userCredential;
} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    
    Navigator.of(context).pop();
    showDialog(context: context, builder: (context) {
      return GiffyDialog.image(
        Image.asset("images/dog.gif" )
         ,title: Text("No user found for that email." ,style: GoogleFonts.lato(
    textStyle: TextStyle(fontWeight: FontWeight.bold ,color: Colors.black87),)),
        elevation: 20,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)),
               actions: [
         MaterialButton(
           onPressed: () => Navigator.pop(context, 'CANCEL'),
           splashColor:Color.fromARGB(255, 255, 0, 0) ,
           child: Text('CANCEL' ,style: GoogleFonts.lato(
    textStyle: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 141, 43, 43)),)),
         ),
       ],actionsPadding: EdgeInsets.fromLTRB(0, 0, 18, 10)
      );
      
    },);
   
  } else if (e.code == 'wrong-password') {
       
    Navigator.of(context).pop();
    showDialog(context: context, builder: (context) {
      return GiffyDialog.image(
        Image.asset("images/gif.gif" )
         ,title: Text("Wrong password provided for that user" ,style: GoogleFonts.lato(
    textStyle: TextStyle(fontWeight: FontWeight.bold ,color: Colors.black87),)),
        elevation: 20,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)),
               actions: [
         MaterialButton(
           onPressed: () => Navigator.pop(context, 'CANCEL'),
           splashColor:Color.fromARGB(255, 255, 0, 0) ,
           child: Text('CANCEL' ,style: GoogleFonts.lato(
    textStyle: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 141, 43, 43)),)),
         ),
       ],actionsPadding: EdgeInsets.fromLTRB(0, 0, 18, 10)
      );
    },);
    
  }else{
    print(e.code);
  }
}
  }}
  gettoken()async{
    CollectionReference sir = FirebaseFirestore.instance.collection("users");
    await sir.where("email",isEqualTo: email).get().then((value) {
      value.docs.forEach((element) async{
        SharedPreferences va = await SharedPreferences.getInstance();
        var userData =  element.data() as Map<String, dynamic>; 
        va.setString("ido", await userData["documentId"] );
        va.setString("uso",await userData["username"]);
      });
    }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 160,),
          UnconstrainedBox(
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                          "images/uno.png"),
                      fit: BoxFit.cover)),
            ),
          ),
          
          Container(
            padding: EdgeInsets.all(10),
            child: Form(key: formst
                ,child: Column(
              children: [
                TextFormField(onSaved: (newValue) {
                  email=newValue;
                },validator: (value) {
                    RegExp test = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                    if (test.hasMatch(value!)==false){
                      return "please enter valid email";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      labelText: "Email"),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(onSaved: (newValue) {
                 password = newValue;
                },
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      labelText: "Password" , )
                      ,
                ),
                Container(margin: EdgeInsets.all(7),child: Row(children: [
                  Text("if you dont have account ")
                  ,InkWell(child: Text("Click Here" ,style: TextStyle(color: Color.fromARGB(255, 117, 61, 124) ,fontWeight: FontWeight.bold),),onTap: () {
                    Navigator.of(context).pushReplacementNamed("signup");
                  },)
                ],),),
                Container(  
                  child: ElevatedButton(
                    onPressed: ()async {
                     var respose = await login();
                     if (respose != null){
                      await gettoken();
                      Navigator.of(context).pushReplacementNamed("homepage");
                     }
                     else if(respose == null){
                      
                     }
                    },
                    child: Text("Login"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 45, 0, 48),
                        foregroundColor: Color.fromARGB(255, 255, 111, 111)),
                  ),
                )
              ],
            )),
          )
        ],
      ),
    );
  }
}
