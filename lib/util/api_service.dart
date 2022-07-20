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
        log("Error: 404");
      } else if (response.statusCode == 204) {
        log("Error: 204");
      }
    } catch (e) {
      log(e.toString());
    }
    return "";
  }
}
