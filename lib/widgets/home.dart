import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../main.dart';
import '../util/items.dart';
import 'inspect.dart';
import '../util/api_service.dart' as apis;

class Home extends State<MainPage> {
  String url = 'http://localhost:8070/';
  List _items = []; // feature items of currently open project
  String projectName = ''; // name of currently open project
  List projectKeys = [];

  String boxName = "Bitbox";
  final openItem = ValueNotifier<FeatureItem>(FeatureItem("", "", []));

  Future<void> load() async {
    await Hive.openBox(boxName);
    String jsonString = await apis.ApiService().fakeGetProjects();

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
    load();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadProjectKeys());
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

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    String? font = Theme.of(context).textTheme.bodyText1?.fontFamily;

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
                color: colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(children: [
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Image.asset("assets/walter_logo.jpg",
                                    fit: BoxFit.fill, width: 300),
                              ),
                            ])),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                    style: ButtonStyle(backgroundColor:
                                        MaterialStateProperty.resolveWith<
                                                Color?>(
                                            (Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return colorScheme.background;
                                      }
                                      return colorScheme.secondary;
                                    })),
                                    onPressed: () async => load(),
                                    child: Text("Refresh",
                                        style: TextStyle(fontFamily: font))),
                              ),
                            ),
                          ],
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
                                                loadProject(projectKeys[index]);
                                              },
                                              child: Card(
                                                margin:
                                                    const EdgeInsets.all(10),
                                                color: (projectKeys[index] ==
                                                        projectName)
                                                    ? colorScheme.tertiary
                                                    : colorScheme.background,
                                                child: ListTile(
                                                    title: Text(
                                                        projectKeys[index],
                                                        style: TextStyle(
                                                            fontFamily: font))),
                                              ));
                                        }),
                                  )
                                : Flexible(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: colorScheme.background,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                              _items.isNotEmpty
                                                  ? projectName
                                                  : "No Projects",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontFamily: font,
                                                  fontSize: 25,
                                                  color:
                                                      colorScheme.onPrimary)),
                                        )),
                                  ),
                          ],
                        ),
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
              decoration: BoxDecoration(
                  color: colorScheme.background,
                  border: Border(
                      right:
                          BorderSide(width: 5, color: colorScheme.background))),
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  FeatureItem item = FeatureItem.fromJson(_items[index]);
                  return GestureDetector(
                      onTap: () {
                        setState(() {
                          openItem.value = item;
                        });
                      },
                      child: Card(
                        color: colorScheme.surface,
                        key: Key(item.name),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: (item.name == openItem.value.name)
                                  ? colorScheme.primary
                                  : colorScheme.background,
                              width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(item.name,
                              style: TextStyle(fontFamily: font)),
                          subtitle: Text(item.description,
                              style: TextStyle(fontFamily: font)),
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
