import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class Users {
  String? id;
  String? email;
  String? name;
  String? phone;


 // Users({this.id, this.email,  this.name,this.phone,});
  Users({required this.id, required this.email, required this.name, required this.phone});
  Users.fromSnapshot(DataSnapshot dataSnapshot) {

    id = dataSnapshot.key;
    Map<dynamic, dynamic> values =dataSnapshot.value as Map<dynamic, dynamic>;

    email = values['email'];
    name = values['name'];
    phone = values['phone'];
   // var data = dataSnapshot.value as Map?;
/*/
    if(data != null){
      email = data!["email"];
      name = data?["name"];
      phone = data?["phone"];
    }else {
      email = "a";
      name = "a";
      phone = "a";
    }*/

  }
}
