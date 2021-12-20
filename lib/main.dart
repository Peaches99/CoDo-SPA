import 'package:flutter/material.dart';

void main() => runApp(const Bitlog());

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Welcome to Flutter',
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Your Jordans are fake'),
//         ),
//       ),
//     );
//   }
// }

class Bitlog extends StatelessWidget {
  const Bitlog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blue,
            toolbarHeight: 20,
            title: const Text(
              'Bitlog - Devbuild',
              style: TextStyle(fontSize: 15),
            ),
          ),
          body: Row(
            children: const [
              Drawer(
                backgroundColor: Colors.lightBlue,
                child: FlutterLogo(),
              )
            ],
          )),
    );
  }
}
