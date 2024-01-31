// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:untitled/home/Homepage.dart';
import '../lod/load.dart';
import 'package:path/path.dart';
class Addnotes extends StatefulWidget {
  
  const Addnotes({super.key});

  @override
  State<Addnotes> createState() => _AddnotesState();
}
GlobalKey<FormState> formstat =GlobalKey<FormState>();
addnote(context)async{
  var formdata = formstat.currentState;
  if(formdata != null&&formdata.validate()){
    gettoload(context);
    formdata.save();
     if (file == null) {
      imageurl = null;
    }
    await notesref.add({
      "title" : title,
      "note" : note,
      "imageurl" : imageurl
      ,"uid" : FirebaseAuth.instance.currentUser?.uid
    }
    
    ).then((value){
      Navigator.of(context).pushReplacementNamed("homepage");
    }).catchError((e){
      print("===========================================================$e");
    });
    

  }
}
CollectionReference notesref = FirebaseFirestore.instance.collection("notes");

File? file;
var title;
var note;
var imageurl;
class _AddnotesState extends State<Addnotes> {
  void initState() {
    super.initState();
    // Reset values to null when the user enters the Add Note page
    title = null;
    note = null;
    imageurl = null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.grey[700],onPressed: () async{
        await addnote(context);
      },tooltip: "add note",child: Icon(Icons.note_add_outlined) ,),
      appBar: AppBar(backgroundColor: Colors.grey[800], title: Text("Add note"), leading: IconButton(onPressed: () {
        Navigator.of(context).pushReplacementNamed("homepage");
      }, icon: Icon(Icons.arrow_back))),
      body: Container(margin: EdgeInsets.fromLTRB(10, 0, 10, 0 ),
        child: Form(key: formstat,
        child: Column(
          children: [
            SizedBox(height: 20,),
            Theme(
               data: Theme.of(context)
                                  .copyWith(primaryColor: Colors.redAccent,),
              child: TextFormField(validator: (value) {
                if(value!.length <= 0){
                  return "title cant be null";
                }
              },onSaved: (newValue) {
                title = newValue;
              },maxLength: 20, maxLines: 1,
              
                decoration: InputDecoration(label: Text("title")
                ,focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)) ,
                borderSide: BorderSide(width: 1.5,color: Color.fromARGB(255, 163, 163, 163))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)) ,
                borderSide: BorderSide(width: 1.5,color: Color.fromARGB(255, 0, 0, 0))) 
                ,prefixIcon: Icon(Icons.notes)),
                
              ),
            ),SizedBox(height: 20,),
            TextFormField(validator: (value) {
              if(value!.length <= 0){
                return "note cant be null";
              }},onSaved: (newValue) {
              note = newValue;
            },maxLength: 200, maxLines: 4, minLines: 1,
              decoration: InputDecoration(label: Text("note")
              ,focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)) ,
              borderSide: BorderSide(width: 1.5,color: Color.fromARGB(255, 163, 163, 163))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)) ,
              borderSide: BorderSide(width: 1.5,color: Color.fromARGB(255, 0, 0, 0))) 
              ,prefixIcon: Icon(Icons.note ,)),
            ),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800],),onPressed: () {
              showImage(context);
            }, child: Text("add image"))
          ],
        ),
          ),
      )
    );
  }
}

void showImage(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(10),
        height: 150,
        child: Column(
          children: [
            Text(
              'Please choose an image',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),SizedBox(height: 20,),
            InkWell(
              child: Row(
                children: [
                  Icon(Icons.photo , size: 30,),
                  SizedBox(width: 10,),
                  Text('From Gallery' ,style: TextStyle(fontSize: 22),),
                ],
              ),
              onTap: () async{
                var picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                               if(picked!=null){
                                gettoload(context);
                file = File(picked.path);
                var ramd = Random().nextInt(999999);
                var imagename ="$ramd" + basename(picked.path);
                var ref = FirebaseStorage.instance.ref("images").child(imagename);
                
                await ref.putFile(file!);
                imageurl = await ref.getDownloadURL();  
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                
               }else{}
                // Handle gallery selection here
              },
            ),
            SizedBox(height: 20,),
            InkWell(
              child: Row(
                children: [
                  Icon(Icons.camera , size: 30,),
                  SizedBox(width: 10,),
                  Text('From Camera' ,style: TextStyle(fontSize: 22)),
                  
                  
                ],
              ),
              onTap: () async {var picked =await ImagePicker().pickImage(source: ImageSource.camera);
               if(picked!=null){
                gettoload(context);
                file = File(picked.path);
                var ramd = Random().nextInt(999999);
                var imagename ="$ramd" + basename(picked.path);
                var ref = FirebaseStorage.instance.ref("images").child(imagename);
                Navigator.of(context).pop();
                await ref.putFile(file!);
                imageurl = await ref.getDownloadURL();  
                 Navigator.of(context).pop();
                Navigator.of(context).pop();
                
               }else{}
                // Handle camera selection here
              },
            ),
          ],
        ),
      );
    },
  );
}
