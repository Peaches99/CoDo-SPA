import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'dart:html' as html;
import 'package:hive_flutter/hive_flutter.dart';

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
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String url = 'http://localhost:8080/#/test';
  List _items = [];
  String project = "";
  var box = Hive.openBox('Bitbox');

  Future<String> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      if (result.files.single.bytes != null) {
        var byteString = String.fromCharCodes(result.files.single.bytes!);
        return byteString;
      }
    }
    return "";
  }

  Future<void> load() async {
    var jsonString = await pickFile();

    if (jsonString.isNotEmpty) {
      var json = jsonDecode(jsonString);

      var box = Hive.box('bitbox');
      await box.put('Data', json);
      html.window.location.reload();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => readJson("assets/sample.json"));
  }

  Future<void> readJson(String file) async {
    //final String response = await rootBundle.loadString(file);
    //final data2 = await json.decode(response);

    var box = await Hive.openBox('bitbox');
    final data = box.get('Data');

    setState(() {
      if (data != null) {
        _items = data["Features"];
        project = " - " + data["Project"] + " v" + data["Version"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("BitLog (Dev Build)" + project),
      ),
      body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () async => load(),
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
                                  title: Text(item.name),
                                  subtitle: Text(item.description),
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

  static TextStyle heading() {
    return const TextStyle(fontSize: 30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(featureItem.name)),
        body: Padding(
            padding: const EdgeInsets.all(5),
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
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 10),
                                        child: Text(
                                          scenario.name,
                                          style: heading(),
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Given: " +
                                                      scenario.syntax.given,
                                                  textAlign: TextAlign.left),
                                              Text(
                                                  "When: " +
                                                      scenario.syntax.when,
                                                  textAlign: TextAlign.left),
                                              Text(
                                                  "Then: " +
                                                      scenario.syntax.then,
                                                  textAlign: TextAlign.left)
                                            ]))
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
