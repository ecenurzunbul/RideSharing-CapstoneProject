import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/Models/drivers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:drivers_app/Models/allUsers.dart';
import 'package:geolocator/geolocator.dart';

String mapKey ="AIzaSyD6rDdBGDW8J3930py5Fc1ToJhB4cZPYrI";

User? firebaseUser;

Users? userCurrentInfo;

User? currentfirebaseUser;

late StreamSubscription<Position> homeTabPageStreamSubscription;  //????
late StreamSubscription<Position> rideStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();

late Position currentPosition;

Drivers? driversInformation;