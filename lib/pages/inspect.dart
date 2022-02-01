import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'dart:html' as html;
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';
import '../util/items.dart';

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
