// TODO Implement this library.import 'dart:convert';
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
  List _items = []; // feature items of currently open project
  String projectName = ''; // name of currently open project
  List projectKeys = [];

  String boxName = "Bitbox";
  final openItem = ValueNotifier<FeatureItem>(FeatureItem("", "", []));

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

      await box.put(json['Project'], json['Features']);

      loadProject(json['Project']);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => loadProjectKeys());
  }

  Future<void> loadProjectKeys() async {
    var box = await Hive.openBox(boxName);
    projectKeys = box.keys.toList();
  }

  Future<void> loadProject(String key) async {
    var box = await Hive.openBox(boxName);

    setState(() {
      loadProjectKeys();
      _items = box.get(key);
      projectName = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    Hive.openBox(boxName);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(children: [
        Column(
          children: [
            SingleChildScrollView(
              child: Container(
                width: width * 0.2,
                height: height,
                color: Colors.indigo,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ListTile(
                          leading: Text("Current:"),
                          title: Text(projectName)
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            projectKeys.isNotEmpty
                                ? Expanded(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: projectKeys.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                            onTap: () {
                                              debugPrint("Hi!");
                                              loadProject(projectKeys[index]);
                                            },
                                            child: Card(
                                              margin: const EdgeInsets.all(10),
                                              child: ListTile(
                                                  title:
                                                      Text(projectKeys[index])),
                                            ));
                                      }),
                                )
                                : Flexible(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.black,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                              _items.isNotEmpty
                                                  ? projectName
                                                  : "Upload a project to view.",
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.white)),
                                        )),
                                  ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: ElevatedButton(
                                  style: ButtonStyle(backgroundColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors.indigoAccent;
                                    }
                                    return Colors.blueAccent;
                                  })),
                                  onPressed: () async => load(),
                                  child: const Text("Upload JSON")),
                            ),
                          ],
                        )
                      ]),
                ),
              ),
            ),
          ],
        ),
        Column(children: [
          SingleChildScrollView(
            child: Container(
              width: width * 0.3,
              height: height,
              decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  border: Border(
                      right: BorderSide(width: 5, color: Color(0xFFe2e2e2)))),
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  FeatureItem item = FeatureItem.fromJson(_items[index]);
                  return GestureDetector(
                      onTap: () {
                        setState(() {
                          openItem.value = item;
                        });
                        debugPrint(openItem.value.toString());
                      },
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(item.description),
                        ),
                      ));
                },
              ),
            ),
          )
        ]),
        Column(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                width: width * 0.5,
                height: height,
                child: InspectPage(featureItem: openItem),
              ),
            )
          ],
        ),
      ]),
    );
  }
}
