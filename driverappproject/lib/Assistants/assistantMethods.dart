

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';
import 'package:drivers_app/Assistants/requestAsistant.dart';
import 'package:drivers_app/DataHandler/appData.dart';
import 'package:drivers_app/Models/address.dart';
import 'package:drivers_app/configMaps.dart';

import '../Models/allUsers.dart';
import '../Models/directDetails.dart';

class AssistantMethods {
  /*
  static Future<String> searchCoordinateAddress(Position position,
      context) async
  {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
        .latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAsistant.getRequest(url);

    if (response != "failed") {
      //placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
      st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

      Address userPickUpAddres = new Address(placeFormattedAddress: '',
          placeName: '',
          placeId: '',
          latitude: null,
          longitude: null);
      userPickUpAddres.longitude = position.longitude;
      userPickUpAddres.latitude = position.latitude;
      userPickUpAddres.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(
          userPickUpAddres);
    }
    return placeAddress;
  }*/

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async
  {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition
        .latitude},${initialPosition.longitude}&destination=${finalPosition
        .latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAsistant.getRequest(directionUrl);
    if (res == "failed") {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails(distanceValue: null,
        durationValue: null,
        distanceText: '',
        durationText: '',
        encodedPoints: '');

    directionDetails.encodedPoints =
    res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
    res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
    res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
    res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
    res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    double distancTraveledFare = (directionDetails.distanceValue! / 1000) *
        0.20;
    double totalFareAmount = timeTraveledFare + distancTraveledFare;

    //Local Currency
    //1$ = 160 RS
    //double totalLocalAmount = totalFareAmount * 160;

    return totalFareAmount
        .truncate(); //totalFareAmount değeri kesirli kısmından kurtulmak için truncate fonksiyonuyla tam sayıya dönüştürülür.
  }

/*
  static void getCurrentOnlineUserInfo() async
  {
   firebaseUser=await FirebaseAuth.instance.currentUser;
   String? userId= firebaseUser?.uid;
   DatabaseReference reference=FirebaseDatabase.instance.reference().child("users").child(userId!);

   // reference.once().then((DataSnapshot dataSnapshot)
   DataSnapshot dataSnapshot = (await reference.once()) as DataSnapshot;
   {
  if(dataSnapshot.value != null)
    {
      userCurretInfo= Users.fromSnapshot(dataSnapshot);
    }
      };
  }

  }*/

  static void disableHomeTabLiveLocationUpdates()
  {
    homeTabPageStreamSubscription.pause();
    Geofire.removeLocation(currentfirebaseUser!.uid);
  }

  static void enableHomeTabLiveLocationUpdates()
  {
    homeTabPageStreamSubscription.resume();
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude, currentPosition.longitude);
  }

}


