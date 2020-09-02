import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as HTTP;

class APIService {
  final String url;

  APIService({@required this.url});

  Future fetchData() async {
    HTTP.Response response = await HTTP.get(url);

    if (response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
      debugPrint(response.statusCode.toString());
    }
  }
}
