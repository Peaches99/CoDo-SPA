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
      await box.put('Data', json);
      html.window.location.reload();
      readJson();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => readJson());
  }

  Future<void> readJson() async {
    var box = await Hive.openBox(boxName);
    final data = await box.get('Data');

    setState(() {
      if (data != null) {
        _items = data["Features"];
        project = data["Project"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Hive.openBox(boxName);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      /*appBar: AppBar(
        centerTitle: true,
        title: Text("BitLog (Dev Build)" + project),
      ),*/
      body: Row(children: [
        Column(
          children: [
            Container(
              width: width * 0.2,
              height: height,
              color: const Color(0xff3338ae),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1,
                              color: Colors.black,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(10))
                          ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(project,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 25, color: Colors.white)),
                            )),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Align(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if(states.contains(MaterialState.pressed)) {
                                    return const Color(0xaa5538ae);
                                  }
                                  return const Color(0xff6638bb);
                                }
                            )),
                              onPressed: () async => load(),
                              child: const Text("Upload JSON")),
                        ),
                      ),
                    ],
                  )
                ]),
              ),
            ),
          ],
        ),
        Column(children: [
          _items.isNotEmpty
              ? Container(
                  width: width * 0.3,
                  height: height,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      border: Border(
                          right:
                              BorderSide(width: 5, color: Color(0xFFe2e2e2)))),
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      FeatureItem item = FeatureItem.fromJson(_items[index]);
                      return GestureDetector(
                          onTap: () {
                            openItem.value = item;
                            debugPrint(openItem.value.toString());
                            //TODO: find workaround cuz this might be bad performance wise?
                            setState(() {});
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
                )
              : Container(
                  width: width * 0.3,
                  height: height,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      border: Border(
                          right:
                              BorderSide(width: 5, color: Color(0xFFe2e2e2)))))
        ]),
        Column(
          children: [
            SizedBox(
              width: width * 0.5,
              height: height,
              child: InspectPage(featureItem: openItem),
            )
          ],
        ),
      ]),
    );
  }
}
