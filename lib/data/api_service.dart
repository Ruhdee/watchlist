import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
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
      final response = await JsonCacheService.dio.get(url);
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

  Future<Image> getImageWithDioCache(
    String posterPath, {
    String size = 'w500',
  }) async {
    final url = '$imageBaseUrl$size$posterPath';

    try {
      final response = await ImageCacheService.dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final fromNetwork = response.extra['@fromNetwork@'] ?? true;
      print('fetching image');
      print(
        'Image ${fromNetwork ? 'fetched from network' : 'loaded from cache'}',
      );
      final bytes = Uint8List.fromList(response.data!);
      return Image.memory(bytes, fit: BoxFit.contain);
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }
}

class JsonCacheService {
  static final String bearerToken = dotenv.env['TMDB_BEARER'] ?? '';
  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.refreshForceCache,
        maxStale: const Duration(hours: 1),
        priority: CachePriority.high,
        cipher: null,
      );

      _dio =
          Dio(
              BaseOptions(
                headers: {
                  "Authorization": "Bearer $bearerToken",
                  "Content-Type": "application/json;charset=utf-8",
                },
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            )
            ..interceptors.add(DioCacheInterceptor(options: cacheOptions))
            ..interceptors.add(
              LogInterceptor(responseBody: true, requestBody: true),
            );
    }
    return _dio!;
  }
}

class ImageCacheService {
  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      final cacheOptions = CacheOptions(
        store: MemCacheStore(), // File-based for persistence
        policy: CachePolicy.request,
        maxStale: const Duration(days: 7), // Long cache duration
        priority: CachePriority.normal, // Lower priority than JSON
      );

      _dio = Dio()
        ..interceptors.add(DioCacheInterceptor(options: cacheOptions));
    }
    return _dio!;
  }
}
