import 'package:flutter/material.dart';
import 'package:mrz_flutter/isolate_camera.screen.dart';
import 'package:mrz_flutter/main.dart';

class Routes {
  static const String home = '/home';
  static const String cameraIsolate = '/camera-isolate';
  static final routes = <String, WidgetBuilder>{
    home: (_) => const MyHomeScreen(),
    cameraIsolate: (_) => const IsolateCameraScreen(),
  };
}
