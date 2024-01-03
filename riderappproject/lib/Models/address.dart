class Address
{
  String placeFormattedAddress;
  String placeName;
  String placeId;
  double?  latitude;
  double?  longitude;

  Address({ required this.placeFormattedAddress,  required this.placeName,  required this.placeId, this.latitude,  this.longitude});
}