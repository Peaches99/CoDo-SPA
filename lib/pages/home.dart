import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'dart:html' as html;
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';
import '../util/items.dart';
import 'inspect.dart';

class Home extends State<MainPage> {
  String url = 'http://localhost:8080/#/test';
  List _items = [];
  String project = "";
  String boxName = "Bitbox";

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

  // Load the uploaded json file into the box
  Future<void> load() async {
    var jsonString = await pickFile();

    if (jsonString.isNotEmpty) {
      var json = jsonDecode(jsonString);

      var box = Hive.box(boxName);
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
    var box = await Hive.openBox(boxName);
    final data = await box.get('Data');

    setState(() {
      if (data != null) {
        _items = data["Features"];
        project = " - " + data["Project"] + " v" + data["Version"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Hive.openBox(boxName);

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
