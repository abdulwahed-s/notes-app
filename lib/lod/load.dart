// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

gettoload(context) {showDialog(context: context, builder: (context) {
  return AlertDialog(
    backgroundColor: Color.fromARGB(255, 46, 46, 46),
    content:Container(height: 170, width: 170 ,decoration: BoxDecoration(image: DecorationImage(image:  AssetImage("images/lod.gif") ,fit: BoxFit.cover)), 
    ) ,
  );
},);}