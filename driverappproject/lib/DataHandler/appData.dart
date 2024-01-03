import 'package:flutter/cupertino.dart';


import '../Models/address.dart';

class AppData extends ChangeNotifier {
 Address? pickUpLocation, dropOffLocation;
   //Address pickUpLocation = Address(placeFormattedAddress: '', placeName: '', placeId: '', latitude: 0.0, longitude: 0.0);
//AppData(this.pickUpLocation);
  //AppData({required this.pickUpLocation});

   void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }
  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

}
