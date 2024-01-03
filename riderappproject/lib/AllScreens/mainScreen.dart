import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:test_aappp/AllScreens/searchScreen.dart';
import 'package:test_aappp/AllWidgets/Divider.dart';
import 'package:test_aappp/Assistants/assistantMethods.dart';
import 'package:test_aappp/Assistants/geoFireAssistant.dart';
import 'package:test_aappp/DataHandler/appData.dart';
import 'package:test_aappp/Models/nearbyAvailableDrivers.dart';
import 'package:test_aappp/configMaps.dart';

import '../AllWidgets/noDriverAvailableDialog.dart';
import '../AllWidgets/progressDialog.dart';
import '../Models/directDetails.dart';
import '../main.dart';
import 'loginScreen.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  //DirectionDetails tripDirectiondetails;   buraya sonradan bak
  DirectionDetails tripDirectiondetails = DirectionDetails(
      distanceValue: 0,
      durationValue: 0,
      distanceText: '',
      durationText: '',
      encodedPoints: '');
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

//Scaffold bileşeninin state'ini kontrol etmek için kullanılır ve anahtarın kullanılması, Scaffold
// bileşenindeki durumu güncellemek ve yeniden oluşturmak için bir yöntem olarak kullanılabilir.

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300.0;
  double driverDetailsContainerHeight = 0;

  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;

  late DatabaseReference rideRequestRef;

  BitmapDescriptor? nearByIcon;

  late List<NearbyAvailableDrivers> availableDrivers;

  String state = "normal";

  //StreamSubscription<Event> rideStreamSubscription;

  @override
  void initState() {
    // TODO: implement initState
   // rideRequestRef = FirebaseDatabase.instance.reference().child("Ride Requests").push();
    super.initState();

    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();
    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    print(
        "##################################################################848484");
    Map pickUpLocMap = {
      "latitude": pickUp?.latitude.toString(),
      "longitude": pickUp?.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude": dropOff?.latitude.toString(),
      "longitude": dropOff?.longitude.toString(),
    };

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo != null ? userCurrentInfo?.name : "",
      "rider_phone": userCurrentInfo != null ? userCurrentInfo?.phone : "",
      "pickup_address": pickUp?.placeName,
      "dropoff_address": dropOff?.placeName,
      //"ride_type": carRideType,
    };

    rideRequestRef.set(rideInfoMap);
/*
    rideStreamSubscription =rideRequestRef.onValue.listen((event) {
      if(event.snapshot.value == null)
      {
        return;
      }
      if(event.snapshot.value!["status"] != null)
      {
        statusRide = event.snapshot.value["status"].toString();
      }
      if(statusRide == "accepted")
      {
        displayDriverDetailsContainer();
      });*/
  }

  void cancelRideRequest() {
    rideRequestRef.remove();
    setState(() {
      state = "normal";
    });
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250.0;
      //rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });

    saveRideRequest();
  }
  //  void driverDriverDetailContainer(){
  // setState(() {
  // requestRideContainerHeight = 0.0;
  //   rideDetailsContainerHeight = 0.0;
  //  bottomPaddingOfMap = 270.0;
  //  driverDetailsContainerHeight=270.0;
  //  });
  //  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            Exception('Location permissions are permanently denied.'));
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error(Exception('Location permissions are denied.'));
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(
        position, context); //koordinatları adrese çeviriyo
    print("This is your Address:" + address);

    initGeoFireListener();
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Main Screen",
          style: TextStyle(fontFamily: "Brand Bold", fontSize: 24.0),
        ),
      ),

      //Drawer, bir mobil uygulama arayüzünde genellikle sol tarafta açılır bir menüdür.
      // Bu Drawer bileşeni, içinde ListView adı verilen bir başka bileşen içerir.
      // Bu ListView, kullanıcının profil resmi, profil adı ve ziyaret etme seçeneği gibi bazı öğeler içeren bir DrawerHeader bileşeni içerir.
      // Bu öğeler bir sütun içinde yer alır ve profili ziyaret etmek için tıklanabilen bir metin öğesi içerir.
      drawer: Container(
          color: Colors.white,
          width: 255.0,
          child: Drawer(
            child: ListView(
              children: [
                Container(
                  height: 165.0,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        Image.asset(
                          "images/user_icon.png",
                          height: 65.0,
                          width: 65.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Profile Name",
                              style: TextStyle(
                                  fontSize: 16.0, fontFamily: "Brand-Bold"),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            Text(
                              "Visit Profile",
                              style: TextStyle(
                                  fontSize: 10.0, fontFamily: "Brand-Bold"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                DividerWidget(),
                SizedBox(
                  height: 12.0,
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    "History",
                    style: TextStyle(fontSize: 15.0, fontFamily: "Brand-Bold"),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    "Visit Profile",
                    style: TextStyle(fontSize: 15.0, fontFamily: "Brand-Bold"),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text(
                    "About",
                    style: TextStyle(fontSize: 15.0, fontFamily: "Brand-Bold"),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text(
                      "Sign Out",
                      style:
                          TextStyle(fontSize: 15.0, fontFamily: "Brand-Bold"),
                    ),
                  ),
                ),
              ],
            ),
          )),

      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });

              locatePosition(); //map create edildiğinde bu fnksiyon çağırılıcak
              //getLocation();
            },
          ),

          //HamburgerButton for Drawer
          Positioned(
            top: 38.0,
            left: 22.0,
            //GestureDetector, kullanıcının dokunmatik
            // etkileşimlerine yanıt vermek için Flutter'da kullanılan bir bileşendir.
            child: GestureDetector(
              // Bu yöntem, kullanıcının HamburgerButton bileşenine dokunduğunda çağrılır ve
              // Scaffold bileşenindeki Drawer bileşenini açar
              onTap: () {
                //Eğer drawerOpen true ise, scaffoldKey üzerinden çekmecenin açılmasını sağlayabilirsiniz.
                // Aksi takdirde, resetApp fonksiyonunu çağırarak uygulamayı sıfırlayabilirsiniz.

                if (drawerOpen) {
                  scaffoldKey.currentState?.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (drawerOpen) ? Icons.menu : Icons.close,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          //search ui
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              // vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      Text(
                        "Hi there,",
                        style:
                            TextStyle(fontSize: 14.0, fontFamily: "Brand-Bold"),
                      ),
                      Text(
                        "Where to?",
                        style:
                            TextStyle(fontSize: 20.0, fontFamily: "Brand-Bold"),
                      ),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));
                          if (res == "obtainDirection") {
                            displayRideDetailsContainer();
                            availableDrivers =
                                GeoFireAssistant.nearByAvailableDriversList;
                            searchNearestDriver();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  "Search Drop Off",
                                  style: TextStyle(
                                      fontSize: 15.0, fontFamily: "Brand-Bold"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AppData>(context).pickUpLocation !=
                                        null
                                    ? Provider.of<AppData>(context)
                                        .pickUpLocation!
                                        .placeName
                                    : "Add Home",

                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.0,
                                    fontFamily: "Brand-Bold"),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your living home adress",
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 13.0,
                                    fontFamily: "Brand-Bold"),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add Work",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17.0,
                                    fontFamily: "Brand-Bold"),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your office adress",
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 13.0,
                                    fontFamily: "Brand-Bold"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //ride details ui
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              //vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/taxi.png",
                                height: 70.0,
                                width: 80.0,
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Car",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Brand-Bold",
                                    ),
                                  ),
                                  Text(
                                    ((tripDirectiondetails != null)
                                        ? tripDirectiondetails.distanceText
                                        : ''),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey,
                                      fontFamily: "Brand-Bold",
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectiondetails != null)
                                    ? '\$${AssistantMethods.calculateFares(tripDirectiondetails)}'
                                    : ''),
                                style: TextStyle(
                                  fontFamily: "Brand-Bold",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyCheckAlt,
                              size: 18.0,
                              color: Colors.black54,
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Text("Cash"),
                            SizedBox(
                              width: 6.0,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            availableDrivers =
                                GeoFireAssistant.nearByAvailableDriversList;
                            setState(() {
                              state = "requesting";
                            });
                            displayRequestRideContainer();
                            searchNearestDriver();
                          },
                          // color: Theme.of(context).accentColor,
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Request",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  FontAwesomeIcons.taxi,
                                  color: Colors.white,
                                  size: 26.0,
                                ),
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
          ),
          //request or cancel ui
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: requestRideContainerHeight, //containerın boyu
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ColorizeAnimatedTextKit(
                        //animated kitten daha güzelini bul
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          "Requesting a Ride...",
                          "Please wait...",
                          "Finding a Driver...",
                        ],
                        textStyle:
                            TextStyle(fontSize: 35.0, fontFamily: "Horizon"),
                        colors: [
                          Colors.green,
                          Colors.purple,
                          Colors.pink,
                          Colors.blue,
                          Colors.yellow,
                          Colors.red,
                        ],
                        textAlign: TextAlign.center,
                        //alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                      ),
                    ),
                    SizedBox(
                      height: 22.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(width: 2.0, color: Colors.grey),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 26.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Cancel Ride",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    // var pickUpLatLng = LatLng(initialPos!.latitude!, initialPos!.longitude!);
    // var dropOffLatLng = LatLng(finalPos!.latitude!, finalPos!.longitude!);
    //var pickUpLatLng = LatLng(initialPos != null ? initialPos.latitude! : 0.0, initialPos != null ? initialPos.longitude! : 0.0);
    //var dropOffLatLng = LatLng(finalPos != null ? finalPos.latitude! : 0.0, finalPos != null ? finalPos.longitude! : 0.0);
    var pickUpLatLng = LatLng(
      initialPos?.latitude ?? 0.0,
      initialPos?.longitude ?? 0.0,
    );
    var dropOffLatLng = LatLng(
      finalPos?.latitude ?? 0.0,
      finalPos?.longitude ?? 0.0,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    if(details?.distanceText!= "") {
      setState(() {
        tripDirectiondetails = details!;
      });
    }
    Navigator.pop(context);

    // try {
    // var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);
    //  print("This is Encoded Points ::");
    //  print(details?.encodedPoints);
    //  } catch (e) {
    //   print("Errorr: $e");
    // }
    // if (details != null) {
    //  print("This is Encoded Points ::");
    // print(details.encodedPoints);
    // } else {
    //   print("Details is null");
    // }
    print("This is Encoded Points ::");
    print(details?.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details?.encodedPoints ?? "");

    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
//Bu kod parçası, pickUpLatLng ve dropOffLatLng noktaları arasındaki sınırları belirleyerek harita üzerinde bu noktaları görünür hale getirir.

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
          InfoWindow(title: initialPos?.placeName, snippet: "my Location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos?.placeName, snippet: "DropOff Location"),
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
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

  void initGeoFireListener() {
    Geofire.initialize("availableDrivers");

    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 15)
        ?.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(
                    key: '', latitude: 0.0, longitude: 0.0); //??????
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.nearByAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearbyAvailableDriverKeysLoaded == true) {
              updateAvailableDriversOnMap();
            }

            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map['key']);
            // keysRetrieved.remove(map["key"]);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(key: '', latitude: 0.0, longitude: 0.0);
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            // print(map['result'])
            updateAvailableDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });

    Set<Marker> tMarkers = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearByAvailableDriversList) {
      LatLng driverAvailablePosition =
          LatLng(driver.latitude, driver.longitude);
      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverAvailablePosition,
        icon: nearByIcon!,
        rotation: AssistantMethods.createRandomNumber(360),
      );

      tMarkers.add(marker);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }

  void createIconMarker() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios.png")
          .then((value) {
        nearByIcon = value;
      });
    }
  }

  void noDriverFound() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => NoDriverAvailableDialog());
  }

  void searchNearestDriver() {
    if (availableDrivers.isEmpty) {
      cancelRideRequest();
      noDriverFound();
      resetApp();

      return;
    }
    var driver = availableDrivers[0];
    notifyDriver(driver);
    availableDrivers.removeAt(0);
  }

  void notifyDriver(NearbyAvailableDrivers driver) {
    driversRef.child(driver.key).child("newRide").set(rideRequestRef.key);

    driversRef
        .child(driver.key)
        .child("token")
        .once()
        .then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        String token = snapshot.value.toString();
        AssistantMethods.sendNotificationToDriver(
            token, context, rideRequestRef.key!);
      } else {
        return;
      }
      const oneSecondPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        if (state != "requesting") {
          driversRef.child(driver.key).child("newRide").set("cancelled");
          driversRef.child(driver.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 40;
          timer.cancel();
        }

        driverRequestTimeOut = driverRequestTimeOut - 1;

        driversRef.child(driver.key).child("newRide").onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driversRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 40;
            timer.cancel();
          }
        });

        if (driverRequestTimeOut == 0) {
          driversRef.child(driver.key).child("newRide").set("timeout");
          driversRef.child(driver.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 40;
          timer.cancel();

          searchNearestDriver();
        }
      });
    });
  }
}
