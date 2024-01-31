// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ffi';

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/auth/login.dart';
import 'package:untitled/auth/Signup.dart';
import 'package:untitled/curd/addnotes.dart';
import 'package:untitled/curd/editnotes.dart';
import 'package:untitled/home/Homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

bool? islogin;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var sl = FirebaseAuth.instance.currentUser;
  if (sl == null) {
    islogin = false;
  } else {
    islogin = true;
  }
  runApp(Runapp());
}

class Runapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData().copyWith(
          colorScheme: ThemeData()
              .colorScheme
              .copyWith(primary: Color.fromARGB(255, 0, 67, 122)),
        ),
        debugShowCheckedModeBanner: false,
        home: islogin == false ? Login() : Homepage(),
        routes: {
          "login": (context) => Login(),
          "signup": (context) => Signup(),
          "homepage": (context) => Homepage(),
          "addnotes": (context) => Addnotes(),
          "editnotes": (context) => Editnotes()
        });
  }
}

class splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: "images/gif.gif",
      nextScreen: islogin == false ? Login() : Homepage(),
      splashIconSize: 300,
      centered: true,
      splashTransition: SplashTransition.fadeTransition,
        
    );
  }
}

class Test extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return testState();
  }
}

class testState extends State<Test> with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  List<Widget> widgetbody = [
    Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                  "https://i.pinimg.com/564x/5e/d7/0c/5ed70c882c58c396a65f62addc2e37c6.jpg"),
              fit: BoxFit.cover)),
    ),
  ];

  TextEditingController name = TextEditingController();
  GlobalKey<FormState> forma = GlobalKey<FormState>();

  @override
  final sc = ScrollController();
  void initState() {
    sc.addListener(() {
      print(sc.offset);
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: serch());
                },
                icon: Icon(Icons.search_rounded))
          ],
        ),
        body: Container(
          child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container();
                  },
                );
              },
              child: Text("click me")),
        ));
  }
}

class serch extends SearchDelegate {
  @override
  List names = [
    "ray ",
    "sirine ",
    "ryoko ",
    'abdulwahed ',
  ];
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text("$query");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List filternames =
        names.where((element) => element.startsWith(query)).toList();
    return ListView.builder(
      itemCount: query == "" ? names.length : filternames.length,
      itemBuilder: (context, i) {
        return MaterialButton(
          onPressed: () {
            query = query == "" ? names[i] : filternames[i];
            showResults(context);
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: query == ""
                ? Text("${names[i]}",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
                : Text("${filternames[i]}",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
