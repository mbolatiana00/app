import 'package:dio/dio.dart';

Dio createDio() => Dio(
  BaseOptions(
    baseUrl: '',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
);