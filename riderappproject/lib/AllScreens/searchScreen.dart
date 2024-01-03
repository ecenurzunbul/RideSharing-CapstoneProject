

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_aappp/AllWidgets/Divider.dart';
import 'package:test_aappp/AllWidgets/progressDialog.dart';
import 'package:test_aappp/Assistants/requestAsistant.dart';
import 'package:test_aappp/Models/address.dart';
import 'package:test_aappp/configMaps.dart';

import '../DataHandler/appData.dart';
import '../Models/placePredictions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  //TextEditingController nesnesi, pick-up ve drop-off konumları için metin girişini işlemek için kullanılır.
  TextEditingController pickUpTextEditingController=TextEditingController();
  TextEditingController dropOffTextEditingController=TextEditingController();
  List<PlacePredictions> placePredictionList = [];


  @override
  Widget build(BuildContext context) {
    String placeAdress=Provider.of<AppData>(context).pickUpLocation?.placeName ??"";
    //Provider.of<AppData>(context) yöntemi kullanılarak AppData nesnesine erişilir.
    // Bu nesne, uygulamanın durumunu (state) saklamak için kullanılır.
    pickUpTextEditingController.text=placeAdress;

    //pickUpTextEditingController nesnesinin text özelliği, placeAdress değişkeninin değeriyle ayarlanır.
    // Bu sayede, pick-up konumu için metin giriş kutusunun içeriği, AppData nesnesinden alınan veriyle güncellenir.
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 215.0,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7,0.7),
                ),
              ],
            ),

            child: Padding(
              padding: EdgeInsets.only(left: 25.0, top:25.0, right:25.0, bottom: 20.0),
            child: Column(
              children: [
                SizedBox(height: 5.0,),
                //Stack bileşeni, birden fazla bileşeni üst üste koymak için kullanılır. Bu sayede,
                // içindeki bileşenlerin konumları belirlenebilir.

                // İlk GestureDetector bileşeni, bir geri dönüş simgesi içerir ve kullanıcı bu simgeye
                // dokunduğunda (onTap), mevcut ekranı kapatarak bir önceki ekrana geri döner.

                // İkinci bileşen, Center bileşenidir ve "Set Drop Off" metnini içerir. Bu metin,
                // kullanıcının ekranın ortasında yer alır ve kullanıcının hangi işlemin yapılmakta olduğunu anlamasına yardımcı olur.
                Stack(
                  children: [
                    GestureDetector(
                      onTap:(){
              Navigator.pop(context)   ;
            },
                      //Navigator.pop(context) metodu, mevcut ekranı kapatarak bir önceki ekrana geri dönmeyi sağlar.
                      child: Icon(
                          Icons.arrow_back
                      ),
                    ),
                    Center(
                      child: Text("Set Drop Off", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold"),),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Image.asset("images/pickicon.png", height: 16.0, width: 16.0,),
                    SizedBox(width: 18.0,),
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5.0),

                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: InputDecoration(
                                hintText: "PickUp Location",
                                fillColor: Colors.grey[200],
                                filled:true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(left:11.0,top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                    ),
                  ],
                ),

                SizedBox(height: 10.0),

                Row(
                  children: [
                    Image.asset("images/desticon.png", height: 16.0, width: 16.0,),

                    SizedBox(width: 18.0,),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: TextField(
                            onChanged: (val){
                              findPlace(val);
                            },

                           controller: dropOffTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Where to?",
                              fillColor: Colors.grey[200],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
            ),
          ),
          (placePredictionList.length > 0)
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0.0),
                    itemBuilder: (context, index){
                      return PredictionTile(
                        key: ValueKey(index),
                        placePredictions: placePredictionList[index],);
                    },
                    separatorBuilder: (BuildContext context, int index) => DividerWidget(),
                    itemCount: placePredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
              ],
            ),


    );
  }

  void findPlace(String placeName) async{
    if(placeName.length > 1)
      {
        String autoCompleteUrl="https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:tr";

        var res = await RequestAsistant.getRequest(autoCompleteUrl);

        if(res== "failed"){
          return;
        }
        if(res["status"] == "OK")
        {
          var predictions = res["predictions"];

          var placesList = (predictions as List).map((e) => PlacePredictions.fromJson(e)).toList();
          setState(() {
            placePredictionList = placesList;
          });


        }

      }
  }

}
class PredictionTile extends StatelessWidget
{

  final PlacePredictions placePredictions;
  const PredictionTile({required Key key, required this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    return TextButton(
        //padding: EdgeInsets.all(0.0),
        onPressed: ()
        {
        getPlaceAddressDetails(placePredictions.place_id, context);
        },
      child: Container(
        child: Column(
          children: [
            SizedBox(width: 10.0,),
            Row(
              children: [
                Icon(Icons.add_location),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(placePredictions.main_text, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0),),
                      SizedBox(height: 3.0,),
                      Text(placePredictions.secondary_text,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.0, color: Colors.grey),),

                    ],
                  ),
                )
              ],
            ),
            SizedBox(width: 10.0,),
          ],
        )
      ),
    );
  }
  void getPlaceAddressDetails(String placeId, context) async
  {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Setting drop off, please wait...",)
    );

    String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?&place_id=$placeId&key=$mapKey";
    var res = await RequestAsistant.getRequest(placeDetailsUrl);
    Navigator.pop(context);
    if(res == "failed")
    {
      return;
    }

    if(res["status"] == "OK"){
      Address address = Address(placeFormattedAddress: '', placeName: '', placeId: '', latitude: null, longitude: null);
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen:false ).updateDropOffLocationAddress(address);
      print("This is Drop Off Location::");
      print(address.placeName);

      Navigator.pop(context , "obtainDirection");
    }

  }
}

