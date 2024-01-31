// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/auth/login.dart';
import 'package:untitled/curd/editnotes.dart';
import 'package:untitled/home/Viewnote.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/lod/load.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    super.key,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

CollectionReference notesref = FirebaseFirestore.instance.collection("notes");

class _HomepageState extends State<Homepage> {
  File? file;
  var uso;
  var imageurll;
  var imarl;
  File? bfile;
  var profileBannerUrl;
  bool hasFunctionRun = false;
  var idoc;
  getid() async {
    SharedPreferences va = await SharedPreferences.getInstance();
    setState(() {
      idoc = va.getString("ido");
      uso = va.getString("uso");
    });
  }

  getiamge() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(idoc)
        .get()
        .then((userDocument) {
      final data = userDocument.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('profile_banner')) {
        profileBannerUrl = data['profile_banner'];

        setState(() {});
      } else {
        profileBannerUrl =
            "https://images.unsplash.com/photo-1602498456745-e9503b30470b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&h=500&q=60";
      }
      setState(() {});
    });
  }

  void startRepeatingTimer() {
    Timer.periodic(Duration(hours: 1), (timer) {
      // This function will be called every second
      // You can add your code here to perform the desired task
      setState(() {
        hasFunctionRun = true;
      });
      getiamge();
    });
  }

  @override
  void initState() {
    getid();
    getiamge();
    Future.delayed(Duration(milliseconds: 1), () {
      if (!hasFunctionRun) {
        getiamge();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text("notes"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("${uso}"),
              accountEmail: Text("${FirebaseAuth.instance.currentUser!.email}"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Color.fromARGB(0, 92, 50, 172),
                child: ClipOval(
                  child: FirebaseAuth.instance.currentUser!.photoURL == null
                      ? Image.asset("images/cat.jpg")
                      : Image.network(
                          "${FirebaseAuth.instance.currentUser!.photoURL}",
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage("$profileBannerUrl"))),
            ),
            ListTile(
              leading: Icon(Icons.add_photo_alternate_outlined),
              title: Text("choose profile picture"),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                iconSize: 50,
                                onPressed: () async {
                                  var pimg = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pimg != null) {
                                    gettoload(context);
                                    file = File(pimg.path);
                                    var ramd = Random().nextInt(999999);
                                    var imagename =
                                        "$ramd${basename(pimg.path)}";
                                    var ref = FirebaseStorage.instance
                                        .ref("images")
                                        .child(imagename);
                                    await ref.putFile(file!);
                                    imageurll = await ref.getDownloadURL();

                                    await FirebaseAuth.instance.currentUser!
                                        .updatePhotoURL(imageurll);
                                        
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  } else {}
                                },
                                icon: Icon(Icons.photo_library_outlined)),
                            Text(
                              "choose image from gallery",
                              style: GoogleFonts.alice(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                        Spacer(
                          flex: 2,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                iconSize: 50,
                                onPressed: () async {
                                  var pimg = await ImagePicker()
                                      .pickImage(source: ImageSource.camera);
                                  if (pimg != null) {
                                    gettoload(context);
                                    file = File(pimg.path);
                                    var ramd = Random().nextInt(999999);
                                    var imagename =
                                        "$ramd${basename(pimg.path)}";
                                    var ref = FirebaseStorage.instance
                                        .ref("images")
                                        .child(imagename);
                                    await ref.putFile(file!);
                                    imageurll = await ref.getDownloadURL();

                                    await FirebaseAuth.instance.currentUser!
                                        .updatePhotoURL(imageurll);
                                    
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  } else {}
                                },
                                icon: Icon(Icons.camera_enhance_outlined)),
                            Text(
                              "choose image from camera",
                              style: GoogleFonts.alice(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.width_full),
              title: Text("choose profile banner"),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                iconSize: 50,
                                onPressed: () async {
                                  var pimg = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pimg != null) {
                                    gettoload(context);
                                    bfile = File(pimg.path);
                                    var ramd = Random().nextInt(999999);
                                    var imagename =
                                        "$ramd${basename(pimg.path)}";
                                    var ref = FirebaseStorage.instance
                                        .ref("images")
                                        .child("banner")
                                        .child(imagename);
                                    await ref.putFile(bfile!);
                                    imarl = await ref.getDownloadURL();

                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc("${idoc}")
                                        .update({'profile_banner': imarl});

                                    getiamge();
                                    
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  } else {}
                                },
                                icon: Icon(Icons.photo_library_outlined)),
                            Text(
                              "choose image from gallery",
                              style: GoogleFonts.alice(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                        Spacer(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                iconSize: 50,
                                onPressed: () async {
                                  var pimg = await ImagePicker()
                                      .pickImage(source: ImageSource.camera);
                                  if (pimg != null) {
                                    gettoload(context);
                                    bfile = File(pimg.path);
                                    var ramd = Random().nextInt(999999);
                                    var imagename =
                                        "$ramd${basename(pimg.path)}";
                                    var ref = FirebaseStorage.instance
                                        .ref("images")
                                        .child("banner")
                                        .child(imagename);
                                    await ref.putFile(bfile!);
                                    imarl = await ref.getDownloadURL();

                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc("${idoc}")
                                        .update({'profile_banner': imarl});

                                    getiamge();
                                  
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  } else {}
                                },
                                icon: Icon(Icons.camera_enhance_outlined)),
                            Text(
                              "choose image from camera",
                              style: GoogleFonts.alice(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        )
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).restorablePushReplacementNamed("login");
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "add note",
        backgroundColor: Colors.grey[800],
        onPressed: () {
          Navigator.of(context).pushNamed("addnotes");
        },
        child: Icon(Icons.add),
      ),
      body: Container(
          child: FutureBuilder(
        future: notesref
            .where("uid", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                return Dismissible(
                    onDismissed: (direction) {
                      notesref
                          .doc(
                            snapshot.data!.docs[index].id,
                          )
                          .delete();
                    },
                    key: UniqueKey(),
                    child: listnotes(
                      a: snapshot.data!.docs[index],
                      docid: snapshot.data!.docs[index].id,
                    ));
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }
        },
      )),
    );
  }
}

class listnotes extends StatelessWidget {
  final a;
  final docid;

  listnotes({this.a, this.docid});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return Viewnotes(
              notes: a,
            );
          },
        ));
      },
      child: Card(
        child: ListTile(
          title: Text("${a['title']}"),
          subtitle: Text("${a['note']}"),
          trailing: IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Editnotes(docid: docid, list: a),
                ));
              },
              icon: Icon(Icons.edit)),
          leading: a["imageurl"] == null
              ? null
              : Image(
                  image: NetworkImage("${a["imageurl"]}"),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
