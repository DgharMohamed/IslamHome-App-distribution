import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:islamic_library_flutter/data/models/adhkar_model.dart';

class AzkarService {
  static final AzkarService _instance = AzkarService._internal();
  factory AzkarService() => _instance;
  AzkarService._internal();

  Future<Map<String, List<AdhkarModel>>> getLocalAzkar() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/azkar.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      return data.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((i) => AdhkarModel.fromJson(i)).toList(),
        ),
      );
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, List<AdhkarModel>>> getLocalDuas() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/duas.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      return data.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((i) => AdhkarModel.fromJson(i)).toList(),
        ),
      );
    } catch (e) {
      return {};
    }
  }
}
