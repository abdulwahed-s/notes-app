// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:untitled/home/Homepage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lod/load.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}
 final GlobalKey<FormState> formsta = GlobalKey<FormState>();
var username;
var email;
var password;
DocumentReference? documentReference; 


save()async{
  SharedPreferences va = await SharedPreferences.getInstance();
  va.setString("ido", documentReference!.id);
  va.setString("uso", username);
}

class _SignupState extends State<Signup> {
  signup() async{
  var formdata = formsta.currentState;
  if(formdata!.validate()){
    formdata.save();
    try { gettoload(context);
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password
  );
  return userCredential;
} on FirebaseAuthException catch (e) {
      
    Navigator.of(context).pop();
 if (e.code == 'email-already-in-use') {
   AwesomeDialog(context: context,
   dialogType: DialogType.error
   ,title: "The account already exists for that email."

   ).show();
   
  }
} catch (e) {
  print(e);
}
  }else{

  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 150,),
          UnconstrainedBox(
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                          "images/uno.png"),
                      fit: BoxFit.cover))
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Form(key: formsta,
                child: Column(
              children: [
                TextFormField(
                  onSaved: (value) {
                    username = value;
                  },
                  validator: (value) {
                    if(value!.length > 20){
                      return "username cant be longer then 20 letter";
                    }
                     if(value.length < 2){
                      return "username cant be less then 2 letter";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      labelText: "Username"),
                ),
                SizedBox(
                  height: 20,
                ),
                 TextFormField(
                  onSaved: (value) {
                    email = value;
                  },
                  validator: (value) {
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
                      labelText: "Email" , )
                ),SizedBox(
                  height: 20,
                ),
                TextFormField(onSaved: (value) {
                    password = value;
                  },
                  validator: (value) {
                    RegExp test = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                    if (test.hasMatch(value!)==false){
                      return "please enter strong password";
                    }
                    return null;
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
                  Text("if you have account ")
                  ,InkWell(child: Text("Click Here" ,style: TextStyle(color: Color.fromARGB(255, 117, 61, 124) ,fontWeight: FontWeight.bold),),onTap: () {
                    Navigator.of(context).pushReplacementNamed("login");
                  },)
                ],),),
                Container(  
                  child: ElevatedButton(
                    onPressed: () async {
                      String? token = await FirebaseMessaging.instance.getToken();
                     var response = await signup();
                     if (response != null){
                      CollectionReference users = FirebaseFirestore.instance.collection("users");
                       documentReference = await users.add({
                        "username" : username,
                        "password" : password
                        ,"email" : email
                        ,"token" : token
                        ,
                      });
                       String documentId = documentReference!.id;
                       await documentReference!.update({"documentId": documentId});
                      save();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return Homepage();
                      },));
                     }
                     else if(response == null){
                     }
                    },
                    child: Text("Sign up"),
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
