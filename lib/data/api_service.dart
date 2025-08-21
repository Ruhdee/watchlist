import 'package:dio/dio.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final String imageBaseUrl = dotenv.env['IMAGE_BASE_URL'] ?? '';

  String getImageUrl(String endpoint, {size = 'w500'}) {
    return '$imageBaseUrl$size$endpoint';
  }

  Future<Map<String, dynamic>> getJson(String endpoint) async {
    final url = '$baseUrl$endpoint';

    try {
      final response = await DioService.dio.get(url);
      final fromNetwork = response.extra['@fromNetwork@'] ?? true;
      print('fetching json');
      print(
        'Json ${fromNetwork ? 'fetched from network' : 'loaded from cache'}',
      );
      return response.data;
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          print('Connection timeout - check your internet');
          break;
        case DioExceptionType.connectionError:
          if (e.message?.contains('Failed host lookup') == true) {
            print('DNS lookup failed - check DNS settings or try VPN');
          } else {
            print('Connection error: ${e.message}');
          }
          break;
        default:
          print('Request failed: ${e.message}');
      }
      throw Exception(
        "Request failed: ${e.response?.statusCode} ${e.response?.statusMessage}",
      );
    }
  }
}

class DioService {
  static final String bearerToken = dotenv.env['TMDB_BEARER'] ?? '';
  static Dio? _dio;

  static Dio get dio {
    _dio ??= Dio(
      BaseOptions(
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-Type": "application/json;charset=utf-8",
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    )..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    return _dio!;
  }
}
