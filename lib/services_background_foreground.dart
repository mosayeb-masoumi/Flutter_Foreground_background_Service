import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration:
          AndroidConfiguration(onStart: onStart, isForegroundMode: true));
}

@pragma('vm:entry-point')  // this line is to get native code from java or swift
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')  // this line is to get native code from java or swift
void onStart(ServiceInstance service) async{

  DartPluginRegistrant.ensureInitialized();
  if(service is AndroidServiceInstance){
    service.on("setAsForeground").listen((event) { // this name "setAsForeground" must be the same in home screen when we call it
      service.setAsForegroundService();
    });

    service.on("setAsBackground").listen((event) { // this name "setAsBackground" must be the same in home screen when we call it
      service.setAsBackgroundService();
    });
  }

  service.on("stopService").listen((event) { // this name "stopService" must be the same in home screen when we call it
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
     if(service is AndroidServiceInstance){
        if(await service.isForegroundService()){
          service.setForegroundNotificationInfo(
              title: "Example title",
              content: "This is description");
        }
     }

     /// perform some operation on background which is not noticeable to the user everytime
     print("background service running");
     service.invoke("update");
  });
}
