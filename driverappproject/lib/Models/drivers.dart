import 'package:firebase_database/firebase_database.dart';

class Drivers
{
  String? name;
  String? phone;
  String ? email;
  String ? id;
  String ? car_color;
  String ? car_model;
  String ? car_number;

  Drivers({required this.name, required this.phone, required this.email, required this.id, required this.car_color, required this.car_model, required this.car_number,});




  Drivers.fromSnapshot(DataSnapshot dataSnapshot){
  Map<dynamic, dynamic> values =dataSnapshot.value as Map<dynamic, dynamic>;
  {

    id = dataSnapshot.key!;
    phone = values["phone"];
    email = values["email"];
    name = values["name"];
    car_color = values["car_details"]["car_color"];
    car_model = values["car_details"]["car_model"];
    car_number = values["car_details"]["car_number"];
  }
}}