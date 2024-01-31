// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Viewnotes extends StatefulWidget {
  final notes;
  const Viewnotes({this.notes,super.key});

  @override
  State<Viewnotes> createState() => _ViewnotesState();
}

class _ViewnotesState extends State<Viewnotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.grey[800],title:         Text("${widget.notes["title"]}" ,style: GoogleFonts.alice(textStyle: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),),),),
      body: ListView(
        children: [
  
          Text("${widget.notes["note"]}" ,style: GoogleFonts.robotoSlab(textStyle: TextStyle(fontSize: 20)),),
          widget.notes['imageurl'] == null? Text(""):Image(image: NetworkImage("${widget.notes['imageurl']}"))
        ],
      ), 
    );
  }
}