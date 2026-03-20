import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pokemap/models/monster_model.dart';
import 'package:pokemap/models/player_ranking_model.dart';

class ApiResult<T> {
  const ApiResult({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final T? data;
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'http://3.0.90.110';
  static const LatLng defaultMapCenter = LatLng(15.243946, 120.562387);

  final http.Client _client;

  static String? resolveImageUrl(String? rawPath) {
    final value = rawPath?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      return value;
    }

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
  }

  Future<List<Monster>> getMonsters() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/get_monsters.php'))
          .timeout(const Duration(seconds: 20));

      final payload = _decodeJsonResponse(response.body);

      if (payload is List) {
        return payload
            .whereType<Map<String, dynamic>>()
            .map(Monster.fromJson)
            .toList();
      }

      if (payload is! Map<String, dynamic>) {
        throw const ApiException('Unexpected monster list response.');
      }

      if (!_responseSucceeded(payload, response.statusCode)) {
        throw ApiException(_extractMessage(payload) ?? 'Failed to load monsters.');
      }

      final dynamic rawList =
          payload['data'] ?? payload['monsters'] ?? payload['results'] ?? [];

      if (rawList is! List) {
        return const <Monster>[];
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(Monster.fromJson)
          .toList();
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException('Unable to load monsters: $error');
    }
  }

  Future<ApiResult<void>> addMonster({
    required String monsterName,
    required String monsterType,
    required double spawnLatitude,
    required double spawnLongitude,
    required double spawnRadiusMeters,
    required String pictureUrl,
  }) async {
    final payload = _monsterWritePayload(
      monsterName: monsterName,
      monsterType: monsterType,
      spawnLatitude: spawnLatitude,
      spawnLongitude: spawnLongitude,
      spawnRadiusMeters: spawnRadiusMeters,
      pictureUrl: pictureUrl,
    );

    final result = await _postWriteJson(
      path: '/add_monster.php',
      payload: payload,
    );

    return ApiResult<void>(
      success: result.success,
      message: result.message,
    );
  }

  Future<ApiResult<void>> updateMonster({
    required int monsterId,
    required String monsterName,
    required String monsterType,
    required double spawnLatitude,
    required double spawnLongitude,
    required double spawnRadiusMeters,
    required String pictureUrl,
  }) async {
    final payload = _monsterWritePayload(
      monsterId: monsterId,
      monsterName: monsterName,
      monsterType: monsterType,
      spawnLatitude: spawnLatitude,
      spawnLongitude: spawnLongitude,
      spawnRadiusMeters: spawnRadiusMeters,
      pictureUrl: pictureUrl,
    );

    final result = await _postWriteJson(
      path: '/update_monster.php',
      payload: payload,
    );

    return ApiResult<void>(
      success: result.success,
      message: result.message,
    );
  }

  Future<ApiResult<void>> deleteMonster(int monsterId) async {
    final result = await _postWriteJson(
      path: '/delete_monster.php',
      payload: <String, String>{
        'monster_id': '$monsterId',
      },
    );

    return ApiResult<void>(
      success: result.success,
      message: result.message,
    );
  }

  Future<ApiResult<String>> uploadMonsterImage(File imageFile) async {
    if (!await imageFile.exists()) {
      return const ApiResult<String>(
        success: false,
        message: 'Selected image file was not found.',
      );
    }

    final fileName = imageFile.uri.pathSegments.isNotEmpty
        ? imageFile.uri.pathSegments.last
        : 'monster_image.jpg';
    final endpoint = Uri.parse('$baseUrl/upload_monster_image.php');
    const fieldNames = <String>[
      'image',
      'monster_image',
      'file',
      'picture',
      'photo',
    ];

    ApiResult<dynamic> lastResult = const ApiResult<dynamic>(
      success: false,
      message: 'Image upload failed.',
    );

    for (final fieldName in fieldNames) {
      final request = http.MultipartRequest('POST', endpoint);
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          imageFile.path,
          filename: fileName,
        ),
      );

      lastResult = await _sendMultipart(request);
      if (lastResult.success) {
        final path = _extractUploadPath(lastResult.data);
        if (path == null || path.trim().isEmpty) {
          return const ApiResult<String>(
            success: false,
            message: 'Upload succeeded but no image URL was returned.',
          );
        }
        return ApiResult<String>(
          success: true,
          message: lastResult.message,
          data: resolveImageUrl(path) ?? path,
        );
      }
    }

    return ApiResult<String>(
      success: false,
      message: lastResult.message,
    );
  }

  Future<List<PlayerRanking>> getPlayerRankings() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/get_player_rankings.php'))
          .timeout(const Duration(seconds: 20));

      final payload = _decodeJsonResponse(response.body);

      if (payload is! Map<String, dynamic>) {
        return const <PlayerRanking>[];
      }

      if (!_responseSucceeded(payload, response.statusCode)) {
        return const <PlayerRanking>[];
      }

      final dynamic rawList =
          payload['data'] ?? payload['rankings'] ?? payload['results'] ?? [];

      if (rawList is! List) {
        return const <PlayerRanking>[];
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .toList()
          .asMap()
          .entries
          .map((entry) => PlayerRanking.fromJson(entry.value, entry.key))
          .toList();
    } catch (_) {
      return const <PlayerRanking>[];
    }
  }

  Map<String, String> _monsterWritePayload({
    int? monsterId,
    required String monsterName,
    required String monsterType,
    required double spawnLatitude,
    required double spawnLongitude,
    required double spawnRadiusMeters,
    required String pictureUrl,
  }) {
    return <String, String>{
      if (monsterId != null) 'monster_id': '$monsterId',
      'monster_name': monsterName.trim(),
      'monster_type': monsterType.trim(),
      'spawn_latitude': spawnLatitude.toStringAsFixed(6),
      'spawn_longitude': spawnLongitude.toStringAsFixed(6),
      'spawn_radius_meters': spawnRadiusMeters.toStringAsFixed(2),
      'picture_url': pictureUrl.trim(),
    };
  }

  Future<ApiResult<dynamic>> _postWriteJson({
    required String path,
    required Map<String, String> payload,
  }) async {
    try {
      _logWriteRequest(path, payload);
      final response = await _client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: const <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));
      _logWriteResponse(path, response.statusCode, response.body);
      return _buildApiResult(response.statusCode, response.body);
    } catch (error) {
      _logWriteError(path, error);
      return ApiResult<dynamic>(
        success: false,
        message: 'Network error: $error',
      );
    }
  }

  Future<ApiResult<dynamic>> _sendMultipart(http.MultipartRequest request) async {
    try {
      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);
      return _buildApiResult(response.statusCode, response.body);
    } catch (error) {
      return ApiResult<dynamic>(
        success: false,
        message: 'Network error: $error',
      );
    }
  }

  ApiResult<dynamic> _buildApiResult(int statusCode, String body) {
    if (body.trim().isEmpty) {
      return const ApiResult<dynamic>(
        success: false,
        message: 'The server returned an empty response.',
      );
    }

    dynamic decoded;
    try {
      decoded = _decodeJsonResponse(body);
    } catch (error) {
      return ApiResult<dynamic>(
        success: false,
        message: error.toString(),
      );
    }

    if (decoded is Map<String, dynamic>) {
      final success = _responseSucceeded(decoded, statusCode);
      return ApiResult<dynamic>(
        success: success,
        message: _extractMessage(decoded) ??
            (success ? 'Request completed successfully.' : 'Request failed.'),
        data: decoded['data'] ?? decoded,
      );
    }

    if (decoded is List) {
      final success = statusCode >= 200 && statusCode < 300;
      return ApiResult<dynamic>(
        success: success,
        message: success ? 'Request completed successfully.' : 'Request failed.',
        data: decoded,
      );
    }

    return ApiResult<dynamic>(
      success: false,
      message: 'Invalid server response: ${decoded.runtimeType}.',
    );
  }

  dynamic _decodeJsonResponse(String body) {
    return jsonDecode(body);
  }

  bool _responseSucceeded(Map<String, dynamic> payload, int statusCode) {
    final dynamic successValue = payload['success'];
    if (successValue is bool) {
      return successValue;
    }
    if (successValue is num) {
      return successValue != 0;
    }
    if (successValue is String) {
      final text = successValue.toLowerCase().trim();
      return text == 'true' || text == '1' || text == 'success';
    }

    return statusCode >= 200 && statusCode < 300;
  }

  String? _extractMessage(Map<String, dynamic> payload) {
    const keys = <String>[
      'message',
      'error',
      'status',
      'detail',
      'description',
    ];

    for (final key in keys) {
      final value = payload[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  String? _extractUploadPath(dynamic data) {
    if (data == null) {
      return null;
    }
    if (data is String) {
      return data.trim().isEmpty ? null : data;
    }
    if (data is Map<String, dynamic>) {
      const keys = <String>[
        'image_url',
        'imageUrl',
        'picture_url',
        'pictureUrl',
        'url',
        'path',
        'file_path',
        'filePath',
        'location',
      ];

      for (final key in keys) {
        final value = data[key];
        if (value == null) {
          continue;
        }
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
  }

  void _logWriteRequest(String path, Map<String, String> payload) {
    debugPrint('[ApiService] POST $path body: ${jsonEncode(payload)}');
  }

  void _logWriteResponse(String path, int statusCode, String body) {
    debugPrint('[ApiService] POST $path status: $statusCode');
    debugPrint('[ApiService] POST $path response: $body');
  }

  void _logWriteError(String path, Object error) {
    debugPrint('[ApiService] POST $path error: $error');
  }
}
