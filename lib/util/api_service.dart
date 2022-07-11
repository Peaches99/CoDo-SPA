import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:bitlog/util/constants.dart';

class ApiService {
  String placeholderJson = ("");

  Future<String> getProjects() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.usersEndpoint);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      log(e.toString());
    }
    return "";
  }

  // placeholder upload data file picker to simulate the Api receiving a String
  Future<String> fakeGetProjects() async {
    final String response =
        await rootBundle.loadString('../../data/output.json');
    return response;
  }
}
