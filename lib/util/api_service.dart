import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:bitlog/util/constants.dart';

class ApiService {
  String placeholderJson = ("");

  Future<String> get() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 404) {
        print("Error: 404");
      } else if (response.statusCode == 204) {
        print("Error: 204");
      }
    } catch (e) {
      log(e.toString());
      print(e.toString());
    }
    return "";
  }

  // placeholder upload data file picker to simulate the Api receiving a String
  Future<String> fakeGet() async {
    final String response =
        await rootBundle.loadString('../../data/output.json');
    return response;
  }
}
