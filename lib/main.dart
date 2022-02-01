import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'dart:html' as html;
import 'package:hive_flutter/hive_flutter.dart';
import 'util/items.dart';
import 'pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(const Bitlog());
}

class Bitlog extends StatelessWidget {
  const Bitlog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: "Bitlog - Devbuild",
        home: TestPage(),
        debugShowCheckedModeBanner: false);
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  Home createState() => Home();
}
