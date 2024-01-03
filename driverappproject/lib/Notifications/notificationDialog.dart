//import 'package:drivers_app/AllScreens/newRideScreen.dart';
import 'package:drivers_app/AllScreens/registerationScreen.dart';
import 'package:drivers_app/Assistants/assistantMethods.dart';
import 'package:drivers_app/Models/rideDetails.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../AllScreens/newRideScreen.dart';

class NotificationDialog extends StatelessWidget
{
   final RideDetails rideDetails;

  NotificationDialog({required this.rideDetails});

  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.0),
            Image.asset("images/car_ios.png", width: 150.0,),
            SizedBox(height: 0.0,),
            Text("New Ride Request", style: TextStyle(fontFamily: "Brand Bold", fontSize: 20.0,),),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/pickicon.png", height: 16.0, width: 16.0,),
                      SizedBox(width: 20.0,),
                      Expanded(
                        child: Container(child: Text(rideDetails.pickup_address ?? "" , style: TextStyle(fontSize: 18.0),)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("images/desticon.png", height: 16.0, width: 16.0,),
                      SizedBox(width: 20.0,),
                      Expanded(
                          child: Container(child: Text(rideDetails.dropoff_address ?? "", style: TextStyle(fontSize: 18.0),))
                      ),
                    ],
                  ),
                  SizedBox(height: 0.0),

                ],
              ),
            ),

            SizedBox(height: 15.0),
            Divider(height: 2.0, thickness: 4.0,),
            SizedBox(height: 0.0),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(8.0),
                      ),
                    ),
                    onPressed: () {
                      // İptal işlemi burada gerçekleştirilir
                      // Örneğin, assetsAudioPlayer.stop() gibi bir işlem yapılabilir
                      assetsAudioPlayer.stop();
                      Navigator.pop(context); // Sayfadan çıkış yapılır
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),

                  SizedBox(width: 25.0),

                  ElevatedButton(
                    onPressed: () {
                    checkAvailabilityOfRide(context);
                      assetsAudioPlayer.stop();
                      // İşlemler burada gerçekleştirilir
                      // Örneğin, assetsAudioPlayer.stop() gibi bir işlem yapılabilir
                     // checkAvailabilityOfRide(context);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.green),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: Text(
                      "Accept".toUpperCase(),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),

                ],
              ),
            ),

            SizedBox(height: 10.0),
          ],
        ),
      ),
    );


  }

   void checkAvailabilityOfRide(context)
   {
   //  newRequestsRef.child(rideRequestId).once().then((DataSnapshot dataSnapShot)
    // {DatabaseReference reference = FirebaseDatabase.instance.reference().child("Ride Requests").child(rideRequestId);

    // DatabaseReference reference =FirebaseDatabase.instance.reference().child("drivers").child(currentfirebaseUser!.uid).child("newRide");
     //String sanitizedUserId = currentfirebaseUser!.uid.replaceAll('.', '');
     //DatabaseReference reference = FirebaseDatabase.instance.reference().child("drivers").child(sanitizedUserId).child("newRide");
     rideRequestRef.once().then((DatabaseEvent event) {
       DataSnapshot snapshot = event.snapshot;

      // rideRequestRef.once().then((DataSnapshot dataSnapShot){
         Navigator.pop(context);
         String theRideId = "";
         if(snapshot.value != null)
         {
           theRideId = snapshot.value.toString();
         }
         else
         {
           displayToastMessage("Ride not exists.", context);
         }
print("////////////////////////************");
print(theRideId);
         print(rideDetails.ride_request_id);
         if(theRideId == rideDetails.ride_request_id)
         {
           rideRequestRef.set("accepted");
           AssistantMethods.disableHomeTabLiveLocationUpdates();
           Navigator.push(context, MaterialPageRoute(builder: (context)=> NewRideScreen(rideDetails: rideDetails)));
         //  AssistantMethods.disableHomeTabLiveLocationUpdates();
         //  Navigator.push(context, MaterialPageRoute(builder: (context)=> NewRideScreen(rideDetails: rideDetails)));
         }
         else if(theRideId == "cancelled")
         {
           displayToastMessage("Ride has been Cancelled.", context);
         }
         else if(theRideId == "timeout")
         {
           displayToastMessage("Ride has time out.", context);
         }
         else
         {
           displayToastMessage("Ride not exists.", context);
         }
       });
     }


}