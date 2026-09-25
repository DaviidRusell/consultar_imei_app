import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/imei_response_model.dart';

abstract class ImeiRemoteDataSource {
  Future<ImeiResponseModel> consultarImei(String imei);
}

class ImeiRemoteDataSourceImpl implements ImeiRemoteDataSource {
  final http.Client client;

  ImeiRemoteDataSourceImpl({required this.client});

  @override
  Future<ImeiResponseModel> consultarImei(String imei) async {
    final uri = Uri.parse(ApiConstants.imeiEndpoint(imei));

    late final http.Response response;
    try {
      response = await client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiConstants.timeout);
    } on Exception {
      throw NetworkException();
    }

    switch (response.statusCode) {
      case 200:
        final Map<String, dynamic> body = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return ImeiResponseModel.fromJson(body);
      case 404:
        throw NotFoundException();
      case 422:
        throw InvalidImeiException();
      default:
        throw ServerException();
    }
  }
}
