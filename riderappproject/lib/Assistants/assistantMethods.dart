import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:test_aappp/Assistants/requestAsistant.dart';
import 'package:test_aappp/DataHandler/appData.dart';
import 'package:test_aappp/Models/address.dart';
import 'package:test_aappp/configMaps.dart';

import '../Models/allUsers.dart';
import '../Models/directDetails.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAsistant.getRequest(url);

    if (response != "failed") {
      //placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
      st3 = response["results"][0]["address_components"][4]["long_name"];
      st4 = response["results"][0]["address_components"][3]["long_name"];
      placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

      Address userPickUpAddres = new Address(
          placeFormattedAddress: '',
          placeName: '',
          placeId: '',
          latitude: null,
          longitude: null);
      userPickUpAddres.longitude = position.longitude;
      userPickUpAddres.latitude = position.latitude;
      userPickUpAddres.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddres);
    }
    return placeAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";
print(directionUrl);
print("***" *20);
    var res = await RequestAsistant.getRequest(directionUrl);
    if (res == "failed") {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails(
        distanceValue: null,
        durationValue: null,
        distanceText: '',
        durationText: '',
        encodedPoints: '');

    if(res["routes"].length>0 ) {
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
    }
    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    double distancTraveledFare =
        (directionDetails.distanceValue! / 1000) * 0.20;
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
  static void getCurrentOnlineUserInfo() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String userId = firebaseUser?.uid ?? "";
    print("userid bu//*/*/*/*/*/***************************");
    print(userId);
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child('users').child(userId);
    reference.once().then((snapshot) {
      if (snapshot.snapshot.value != null) {
        userCurrentInfo = Users.fromSnapshot(snapshot.snapshot);
        print("**********");
        print(userCurrentInfo);
      } else {
        print("*****************");
      }
    });
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }

  static sendNotificationToDriver(
      String token, context, String ride_request_id) async {
    print("BİLDİRİMİ GÖNDERME BUTONU");
    print("şuraya gönderilecek $token");

    var destionation =
        Provider.of<AppData>(context, listen: false).dropOffLocation;
    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverToken,
    };

    Map notificationMap = {
      'body': 'DropOff Address, ${destionation?.placeName}',
      'title': 'New Ride Request'
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_request_id': ride_request_id,
    };

    Map sendNotificationMap = {
      "notification": notificationMap,
      "data": dataMap,
      "priority": "high",
      "to": token,
    };

    Uri uri = Uri.parse('https://fcm.googleapis.com/fcm/send');
    var res = await http.post(
      uri,
      headers: headerMap,
      body: jsonEncode(sendNotificationMap),
    );
    if (res.statusCode == 200) {
      // İstek başarıyla tamamlandı
      print('Bildirim başarıyla gönderildi.');
    } else {
      // İstek hatalı bir şekilde tamamlandı
      print('Bildirim gönderimi başarısız oldu. Yanıt kodu: ${res.statusCode}');
      print('Yanıt: ${res.body}');
    }
  }
}
