import 'package:bitlog/util/global_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'widgets/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(const Bitlog());
}

class Bitlog extends StatelessWidget {
  const Bitlog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Bitlog",
        theme: GlobalTheme.bitlogTheme(),
        home: const MainPage(),
        debugShowCheckedModeBanner: false);
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Home createState() => Home();
}
