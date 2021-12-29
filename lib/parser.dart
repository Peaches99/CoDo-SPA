import 'package:flutter/services.dart';
import 'dart:convert';

//currently not used, actual function at main.dart:54
Future<void> readJson() async {
  final String response = await rootBundle.loadString('assets/sample.json');
  final data = await json.decode(response);
  return data["Features"];
}
