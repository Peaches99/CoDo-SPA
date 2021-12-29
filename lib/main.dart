import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

void main() => runApp(const Bitlog());

class Bitlog extends StatelessWidget {
  const Bitlog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: "Bitlog - Devbuild", home: TestPage()
        /*Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            backgroundColor: Colors.blue,
            toolbarHeight: 30,
            title: const Text(
              'Bitlog - Devbuild',
              style: TextStyle(fontSize: 20),
            ),
          ),
          body: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              Drawer(
                child: FlutterLogo(),
              )
            ],
          )),*/
        );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String url = 'http://localhost:8080/#/test';
  List _items = [];

  Future<String> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      if (result.files.single.bytes != null) {
        var file = String.fromCharCodes(result.files.single.bytes!);
        return file;
      }
    }
    return "";
  }

  Future sendJson(String str) async {
    var response = await http.post(Uri.parse(url),
        body: json.encode(str),
        headers: {
          "content-type": "application/json",
          "accept": "application/json"
        }).then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching JSON " + statusCode.toString());
      }
      return json.decode(response.body);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => readJson("assets/sample.json"));
  }

  Future<void> readJson(String file) async {
    final String response = await rootBundle.loadString(file);
    final data = await json.decode(response);
    setState(() {
      _items = data["Features"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("BitLog - Dev Build"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () async => sendJson(await pickFile()),
                  child: const Text("Upload JSON")),
              _items.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          FeatureItem item =
                              FeatureItem.fromJson(_items[index]);
                          return GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          InspectPage(featureItem: item))),
                              child: Card(
                                margin: const EdgeInsets.all(10),
                                child: ListTile(
                                  leading: Text(item.name),
                                  title: Text(item.description),
                                  subtitle: Text(item
                                      .scenarios[item.scenarios.length - 1]
                                      .name),
                                ),
                              ));
                        },
                      ),
                    )
                  : Container()
            ],
          )),
    );
  }
}

class InspectPage extends StatelessWidget {
  const InspectPage({Key? key, required this.featureItem}) : super(key: key);

  final FeatureItem featureItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(featureItem.name)),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text(featureItem.description),
              featureItem.scenarios.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                          itemCount: featureItem.scenarios.length,
                          itemBuilder: (context, index) {
                            ScenarioItem scenario =
                                featureItem.scenarios[index];
                            return Card(
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(title: Text(scenario.name)),
                                    Text("Given: " + scenario.syntax.given,
                                        textAlign: TextAlign.left),
                                    Text("When: " + scenario.syntax.when,
                                        textAlign: TextAlign.left),
                                    Text("Then: " + scenario.syntax.then,
                                        textAlign: TextAlign.left)
                                  ],
                                ));
                          }),
                    )
                  : Container()
            ])));
  }
}

class FeatureItem {
  final String name;
  final String description;
  final List<ScenarioItem> scenarios;

  FeatureItem(this.name, this.description, this.scenarios);

  factory FeatureItem.fromJson(Map json) {
    List<ScenarioItem> scens = [];
    json["Scenarios"].forEach((scen) {
      scens.add(ScenarioItem.fromJson(scen));
    });
    return FeatureItem(json['FeatureName'], json['Description'], scens);
  }
}

class ScenarioItem {
  final String name;
  final SyntaxItem syntax;

  const ScenarioItem(this.name, this.syntax);

  factory ScenarioItem.fromJson(Map json) {
    return ScenarioItem(json["Scenario"], SyntaxItem.fromJson(json["Syntax"]));
  }
}

class SyntaxItem {
  final String given;
  final String when;
  final String then;

  const SyntaxItem(this.given, this.when, this.then);

  factory SyntaxItem.fromJson(Map json) {
    return SyntaxItem(json["Given"], json["When"], json["Then"]);
  }
}
