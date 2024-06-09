import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_flutter/models/process_text_image.model.dart';

final ProcessTextImage _processTextImage = ProcessTextImage();

class ProcessIsolate {
  bool isProcessing = false;
  final ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPort;
  Isolate? _isolate;
  String processedImage = '';
  StreamSubscription<dynamic>? isolateSubscription;
  static StreamSubscription<dynamic>? isolateBSubscription;
  static final textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final resultController = StreamController<bool>();

  Stream<bool> resultListener() => resultController.stream;

  Future<void> createIsolate() async {
    RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      debugPrint("Cannot get the RootIsolateToken");
      return;
    }
    _isolate = await Isolate.spawn(
      _imageProcessingIsolate,
      [rootIsolateToken, _receivePort.sendPort],
    );
    isolateSubscription = _receivePort.listen((isDetected) {
      if (isDetected is bool) {
        if (isDetected) {
          resultController.add(isDetected);
          Future.delayed(const Duration(seconds: 1), () {
            closeIsolate();
          });
        } else {
          isProcessing = false;
        }
      } else if (isDetected is SendPort) {
        _sendPort = isDetected;
      }
    });
  }

  void sendImage(InputImage image) {
    if (!isProcessing) {
      isProcessing = true;
      _sendPort?.send(image);
    }
  }

  void closeIsolate() {
    _sendPort = null;
    textRecognizer.close();
    isolateSubscription?.cancel();
    isolateBSubscription?.cancel();
    _receivePort.close();
    _isolate?.kill();
    resultController.close();
    debugPrint("Isolate closed");
  }

  static void _imageProcessingIsolate(
    List<Object> args,
  ) {
    RootIsolateToken rootIsolateToken = args[0] as RootIsolateToken;
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    SendPort sendPort = args[1] as SendPort;
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    isolateBSubscription = receivePort.listen((dynamic message) {
      if (message is InputImage) {
        _processImage(sendPort, message);
      }
    });
  }

  static void _processImage(SendPort sendPort, InputImage message) {
    try {
      debugPrint("Isolate process:   START SCANNING");
      textRecognizer.processImage(message).then((recognizedText) {
        _processTextImage
            .firstDetectingProcess(recognizedText)
            .then((isDetected) {
          sendPort.send(isDetected);
        }).catchError((onError) {
          debugPrint("Isolate process:  has error $onError");
        });
      });
    } catch (error) {
      debugPrint("Isolate process:  has error $error");
    }
  }
}
