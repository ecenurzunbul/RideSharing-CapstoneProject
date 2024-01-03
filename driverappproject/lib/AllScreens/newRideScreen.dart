import 'package:flutter/cupertino.dart';
import 'dart:async';
//import 'package:drivers_app/AllWidgets/CollectFareDialog.dart';
import 'package:drivers_app/AllWidgets/progressDialog.dart';
import 'package:drivers_app/Assistants/assistantMethods.dart';
//import 'package:drivers_app/Assistants/mapKitAssistant.dart';
import 'package:drivers_app/Models/rideDetails.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../AllWidgets/CollectFareDialog.dart';
import '../Assistants/mapKitAssistant.dart';
class NewRideScreen extends StatefulWidget
{
  final RideDetails rideDetails;
  NewRideScreen({required this.rideDetails});
  
  
  

 static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}



class _NewRideScreenState extends State<NewRideScreen>
{
  final Completer<GoogleMapController> _controllerGoogleMap =
  Completer<GoogleMapController>();

  late GoogleMapController newRideGoogleMapController;

  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polyLineSet = Set<Polyline>();
  List<LatLng> polylineCorOrdinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geoLocator = Geolocator();
  //var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  late Position myPostion;

//BitmapDescriptor? animatingMarkerIcon;
 late BitmapDescriptor animatingMarkerIcon;

 String status ="accepted";
String durationRide="";
bool isRequestingDirection=false;

String btnTitle ="Arrived";
Color btnColor=Colors.blueAccent;
late Timer timer;
int durationCounter=0;



  void initState() {
    super.initState();
   // createIconMarker();
    acceptRideRequest();
  }

 /* void createIconMarker()
  {
    if(animatingMarkerIcon == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(4, 4));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios.png")
          .then((value)
      {
        animatingMarkerIcon = value;
      });
    }
  }*/

  Future<void> createIconMarker() async {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(4, 4));
      BitmapDescriptor? icon = await BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios.png");
      if (icon != null) {
        animatingMarkerIcon = icon;
      } else {
        print("icon NULL");
      }
    }
  }



  void getRideLiveLocationUpdates()
  {
    LatLng oldPos = LatLng(0, 0);

    rideStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      myPostion = position;
      LatLng mPostion = LatLng(position.latitude, position.longitude);
      print("/////////////////////***************");
      print(mPostion);

      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, myPostion.latitude, myPostion.latitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("animating"),
        position: mPostion,
        icon: animatingMarkerIcon,
        rotation: rot,
        infoWindow: InfoWindow(title: "Current Location"),
      );

      setState(() {
        CameraPosition cameraPosition = new CameraPosition(target: mPostion, zoom: 17);
        newRideGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet.removeWhere((marker)=> marker.markerId.value == "animating");
        markersSet.add(animatingMarker);
      });
     oldPos = mPostion;
     updateRideDetails();

      String? rideRequestId = widget.rideDetails.ride_request_id;
      Map locMap =
      {
        "latitude": currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude.toString(),
      };
      newRequestsRef.child(rideRequestId!).child("driver_location").set(locMap);
    });
  }


  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled:true,
            initialCameraPosition: NewRideScreen._kGooglePlex,

            myLocationEnabled: true,
            markers: markersSet,
            circles: circleSet,
            polylines: polyLineSet,

            onMapCreated: (GoogleMapController controller) async
            {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController=controller;

              setState(() {
                mapPaddingFromBottom=265.0;
              });

              var currentLatLng=LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickUpLatLng=widget.rideDetails.pickup;

            await  getPlaceDirection(currentLatLng, pickUpLatLng!);
            getRideLiveLocationUpdates();

            },

          ),


          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
            boxShadow:
            [
            BoxShadow(
            color: Colors.black38,
            blurRadius: 16.0,
            spreadRadius: 0.5,
            offset: Offset(0.7, 0.7),
            ),
            ],
            ),
            height: 270.0,

            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
              child: Column(
                          children: [

                       Text(
                  durationRide,

                style: TextStyle(fontSize: 14.0, fontFamily: "Brand Bold", color: Colors.deepPurple),
               ),

                 SizedBox(height: 6.0,),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                  Text(widget.rideDetails.rider_name!, style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),),
                     Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.phone_android),
                  ),

                   ],

                 ),
               SizedBox(height: 26.0,),
                            Row(
                              children: [
                                Image.asset("images/pickicon.png", height: 16.0, width: 16.0,),
                                SizedBox(width: 18.0,),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      widget.rideDetails.pickup_address!,
                                      style: TextStyle(fontSize: 18.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.0,),
               Row(
              children: [
                Image.asset("images/desticon.png", height: 16.0, width:16.0,),
                SizedBox(width: 16.0,),
                Expanded(
                child: Container(
                child: Text(
                        widget.rideDetails.dropoff_address!,
  style: TextStyle(fontSize: 18.0),
  overflow: TextOverflow.ellipsis,

  ),
  ))
              ],
  ),
       SizedBox(height: 26.0,),
        Padding(
                padding:EdgeInsets.symmetric(horizontal: 16.0 ),
              child: ElevatedButton(
                onPressed: () async {
               if(status == "accepted") {
                status = "arrived";
                String? rideRequestId = widget.rideDetails.ride_request_id;
                 newRequestsRef.child(rideRequestId!).child("status").set(status);

               setState(() {
                 btnTitle="Start Trip";
                 btnColor=Colors.green;
               });

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context)=> ProgressDialog(message: "Please wait...",),
                );
               await getPlaceDirection(widget.rideDetails.pickup!, widget.rideDetails.dropoff!);
                Navigator.pop(context);

               }
               else if(status == "arrived") {
                 status = "onride";
                 String? rideRequestId = widget.rideDetails.ride_request_id;
                 newRequestsRef.child(rideRequestId!).child("status").set(status);

                 setState(() {
                   btnTitle="End Trip";
                   btnColor=Colors.redAccent;
                 });

                 initTimer();

               }
              else if(status == "onride")
              {
                endTheTrip();
               }

                     },
                style: ElevatedButton.styleFrom(
                primary: btnColor, // Arka plan rengini belirleyin
              ),

                child: Padding(
                padding: EdgeInsets.all(17.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(btnTitle, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                    Icon(Icons.directions_car, color: Colors.white, size: 26.0,),
                  ],
                ),
              ),

              ),
        ),
                  ],

      ),
            ),
    ),
          ),
    ],),


    );
  }


  Future<void> getPlaceDirection(LatLng pickUpLatLng ,LatLng dropOffLatLng ) async
  {


    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait...",)
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);


    Navigator.pop(context);

    print("This is Encoded Points ::");
    print(details?.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinePoints.decodePolyline(details!.encodedPoints);

    polylineCorOrdinates.clear();

    if(decodedPolyLinePointsResult.isNotEmpty)
    {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        polylineCorOrdinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        print(decodedPolyLinePointsResult);
       // print("526563246565555555555555555555555555555");
       // print(polylinePoints);
       // print(polylineCorOrdinates);
        print("//////////*************aaaaaaaaaaaaaaaaaaaaaaaaaaaaassssssssssss*/////////");
      });
    }
    else {
      print("//////////**************/////////");
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylineCorOrdinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if(pickUpLatLng.latitude > dropOffLatLng.latitude  &&  pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    }
    else if(pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude), northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    }
    else if(pickUpLatLng.latitude > dropOffLatLng.latitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude), northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    }
    else
    {
      latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newRideGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
//sürücü sarı
    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),

      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );
//yolcu
    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),

      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  
  
  
  void acceptRideRequest()//????????
  {
    String? rideRequestId = widget.rideDetails.ride_request_id;
    newRequestsRef.child(rideRequestId!).child("status").set("accepted");
    newRequestsRef.child(rideRequestId).child("driver_name").set(driversInformation?.name);
    newRequestsRef.child(rideRequestId).child("driver_phone").set(driversInformation?.phone);
    newRequestsRef.child(rideRequestId).child("driver_id").set(driversInformation?.id);
    newRequestsRef.child(rideRequestId).child("car_details").set('${driversInformation?.car_color} - ${driversInformation?.car_model}');

    Map locMap =
    {
      "latitude": currentPosition.latitude.toString(),
      "longitude": currentPosition.longitude.toString(),
    };
    newRequestsRef.child(rideRequestId).child("driver_location").set(locMap);

    driversRef.child(currentfirebaseUser!.uid).child("history").child(rideRequestId).set(true);
  }

  void updateRideDetails() async
  {
    if(isRequestingDirection == false)
    {
      isRequestingDirection = true;

      if(myPostion == null)
      {
        return;
      }

      var posLatLng = LatLng(myPostion.latitude, myPostion.longitude);
      LatLng? destinationLatLng;

      if(status == "accepted")
      {
        destinationLatLng = widget.rideDetails.pickup;
      }
      else
      {
        destinationLatLng = widget.rideDetails.dropoff;
      }

      var directionDetails = await AssistantMethods.obtainPlaceDirectionDetails(posLatLng, destinationLatLng!);
      if(directionDetails != null)
      {
        print(directionDetails);
        setState(() {
          durationRide = directionDetails.durationText;
        });
      }

      isRequestingDirection = false;
    }
  }
  void initTimer()
  {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter = durationCounter + 1;
    });
  }

  endTheTrip() async
  {
    timer.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)=> ProgressDialog(message: "Please wait...",),
    );

    var currentLatLng = LatLng(myPostion.latitude, myPostion.longitude);

    var directionalDetails = await AssistantMethods.obtainPlaceDirectionDetails(widget.rideDetails.pickup!, currentLatLng);

    Navigator.pop(context);

    int fareAmount = AssistantMethods.calculateFares(directionalDetails!);

    String? rideRequestId = widget.rideDetails.ride_request_id;
    newRequestsRef.child(rideRequestId!).child("fares").set(fareAmount.toString());
    newRequestsRef.child(rideRequestId).child("status").set("ended");
    rideStreamSubscription.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)=> CollectFareDialog(paymentMethod: widget.rideDetails.payment_method!, fareAmount: fareAmount,),
    );

    saveEarnings(fareAmount);
  }
  void saveEarnings(int fareAmount) {

          driversRef.child(currentfirebaseUser?.uid ?? '')
              .child("earnings")
              .once()
              .then((DatabaseEvent event) {
            DataSnapshot snapshot = event.snapshot;
            if (snapshot.value != null) {
              double oldEarnings = double.parse(snapshot.value.toString());
              double totalEarnings = fareAmount + oldEarnings;

              driversRef.child(currentfirebaseUser?.uid ?? '')
                  .child("earnings")
                  .set(totalEarnings.toStringAsFixed(2));
            }
            else {
              double totalEarnings = fareAmount.toDouble();
              driversRef.child(currentfirebaseUser?.uid ?? '')
                  .child("earnings")
                  .set(totalEarnings.toStringAsFixed(2));
            }
          });
        }

  }


