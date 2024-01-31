// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import '../lod/load.dart';
import 'package:path/path.dart';
class Editnotes extends StatefulWidget {
  final docid;
  final list;
  
  const Editnotes({this.docid ,super.key ,this.list});

  @override
  State<Editnotes> createState() => _EditnotesState();
}

final GlobalKey<FormState> formstatee =GlobalKey<FormState>();
CollectionReference notesref = FirebaseFirestore.instance.collection("notes");
File? file;
var title;
var note;
var imageurl;

class _EditnotesState extends State<Editnotes> {
  editnotes(context)async{
var formdata = formstatee.currentState;
  if(file == null){
      if(formdata != null&&formdata.validate()){
    gettoload(context);
    formdata.save();
    await notesref.doc(widget.docid).update({
      "title" : title,
      "note" : note
      ,"uid" : FirebaseAuth.instance.currentUser?.uid
    }
    
    ).then((value){
      Navigator.of(context).pushReplacementNamed("homepage");
    }).catchError((e){
      print("$e");
    });
    

}

  }else if(file != null){  if(formdata != null&&formdata.validate()){
    gettoload(context);
    formdata.save();
    await notesref.doc(widget.docid).update({
      "title" : title,
      "note" : note,
      "imageurl" : imageurl
      ,"uid" : FirebaseAuth.instance.currentUser?.uid
    }
    
    ).then((value){
      Navigator.of(context).pushReplacementNamed("homepage");
    }).catchError((e){
      print("$e");
    });
    
}
}}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.grey[700],onPressed: () async{
        await editnotes(context);
      },tooltip: "edit note",child: Icon(Icons.edit) ,),
      appBar: AppBar(backgroundColor: Colors.grey[800], title: Text("Edit note"),),
      body: Container(margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Form(key: formstatee,
        child: Column(
          children: [
            SizedBox(height: 20,),
            TextFormField(initialValue: widget.list["title"],validator: (value) {
              if(value!.length <= 0){
                return "title cant be null";
              }
            },onSaved: (newValue) {
              title = newValue;
            },maxLength: 20, maxLines: 1,
            
              decoration: InputDecoration(label: Text("title")
              ,focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)) ,
              borderSide: BorderSide(width: 1.5,color: Color.fromARGB(255, 0, 84, 153))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)) ,
              borderSide: BorderSide(width: 1.5,color: Color.fromARGB(255, 52, 46, 53))) 
              ,prefixIcon: Icon(Icons.notes)),
              
            ),SizedBox(height: 20,),
            TextFormField(initialValue: widget.list["note"],validator: (value) {
              if(value!.length <= 0){
                return "note cant be null";
              }},onSaved: (newValue) {
              note = newValue;
            },maxLength: 200, maxLines: 4, minLines: 1,
              decoration: InputDecoration(label: Text("note")
              ,focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)) ,
              borderSide: BorderSide(width: 1.5,color: Color.fromARGB(255, 0, 84, 153))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10) ,bottomRight: Radius.circular(10)) ,
              borderSide: BorderSide(width: 1.5,color: Color.fromARGB(255, 52, 46, 53))) 
              ,prefixIcon: Icon(Icons.note)),
            ),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800],),onPressed: () {
              showImage(context);
            }, child: Text("edit image"))
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
                file = File(picked.path);
                var ramd = Random().nextInt(999999);
                var imagename ="$ramd" + basename(picked.path);
                var ref = FirebaseStorage.instance.ref("images").child(imagename);
                Navigator.of(context).pop();
                await ref.putFile(file!);
                imageurl = await ref.getDownloadURL();  
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
                file = File(picked.path);
                var ramd = Random().nextInt(999999);
                var imagename ="$ramd" + basename(picked.path);
                var ref =FirebaseStorage.instance.ref("images").child(imagename);
                if (context.mounted) Navigator.of(context).pop();
                await ref.putFile(file!);
                imageurl = await ref.getDownloadURL();  
                
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
