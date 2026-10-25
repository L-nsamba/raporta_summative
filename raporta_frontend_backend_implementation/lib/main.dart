import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:raporta_frontend_backend_implementation/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raporta',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<MyHomePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}