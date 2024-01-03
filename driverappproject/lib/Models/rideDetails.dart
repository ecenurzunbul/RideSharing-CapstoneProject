import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetails
{
  String ?pickup_address;
  String ?dropoff_address;
  LatLng ? pickup;
  LatLng ? dropoff;
  String? ride_request_id;
  String ? payment_method;
  String ? rider_name;
  String ? rider_phone;

  RideDetails({required this.pickup_address, required this.dropoff_address, required this.pickup, required this.dropoff,
    required this.ride_request_id, required this.payment_method, required this.rider_name, required this.rider_phone});

  String toString() {
    return 'RideDetails { pickupAddress: $pickup_address, dropoffAddress: $dropoff_address,rider_name:$rider_name }';
  }


  RideDetails.fromSnapshot(DataSnapshot dataSnapshot) {

    //id = dataSnapshot.key;
    Map<dynamic, dynamic> values =dataSnapshot.value as Map<dynamic, dynamic>;

    pickup_address = values['pickup_address'];
    dropoff_address = values['dropoff_address'];
    rider_name = values['rider_name'];
     pickup=values['pickup'];
    dropoff=values['dropoff'];
     ride_request_id=values['ride_request_id'];
    payment_method=values['payment_method'];
     rider_phone=values['rider_phone'];
}}