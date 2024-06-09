import 'package:flutter/material.dart';
import 'package:mrz_flutter/core/rounting.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MRZ Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: Routes.routes,
      initialRoute: Routes.home,
    );
  }
}

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({
    super.key,
  });

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  String isolateResult = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('MRZ Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: isolateCameraExample,
                color: Colors.green,
                child: const Text(
                  'Isolate camera example',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (isolateResult.isNotEmpty)
                Text("Isolate result $isolateResult"),
            ],
          ),
        ),
      ),
    );
  }

  void isolateCameraExample() {
    Navigator.pushNamed(context, Routes.cameraIsolate).then((value) {
      if (value is String?) {
        setState(() {
          isolateResult = value ?? '';
        });
      }
    });
  }
}
