import 'dart:convert';
import 'package:http/http.dart' as http;

class AnkiWebAuthResult {
  final bool success;
  final String? hostKey;
  final String? error;

  const AnkiWebAuthResult({
    required this.success,
    this.hostKey,
    this.error,
  });

  factory AnkiWebAuthResult.ok(String hostKey) =>
      AnkiWebAuthResult(success: true, hostKey: hostKey);

  factory AnkiWebAuthResult.fail(String error) =>
      AnkiWebAuthResult(success: false, error: error);
}

class AnkiWebAuthService {
  final http.Client _client;
  static const String _syncHost = 'https://sync.ankiweb.net';

  AnkiWebAuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Authenticate with AnkiWeb using username (email) and password.
  /// Returns [AnkiWebAuthResult] containing the session `hostKey`.
  Future<AnkiWebAuthResult> login({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty || password.isEmpty) {
      return AnkiWebAuthResult.fail('Email và mật khẩu không được để trống.');
    }

    try {
      final uri = Uri.parse('$_syncHost/sync/hostKey');
      final request = http.MultipartRequest('POST', uri);
      request.headers['User-Agent'] = 'Anki/2.1.57 (7b1f3c3a)';
      request.fields['c'] = '0';
      request.fields['data'] = jsonEncode({
        'u': cleanUsername,
        'p': password,
      });

      final streamedResponse =
          await _client.send(request).timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = response.body.trim();
        // AnkiWeb returns raw hostKey or JSON containing key
        if (body.isNotEmpty && !body.contains('error')) {
          String key = body;
          if (body.startsWith('{')) {
            try {
              final jsonMap = jsonDecode(body) as Map<String, dynamic>;
              key = (jsonMap['key'] ?? jsonMap['hostKey'] ?? body) as String;
            } catch (_) {}
          }
          return AnkiWebAuthResult.ok(key);
        } else {
          return AnkiWebAuthResult.fail(
            'Phản hồi không hợp lệ từ máy chủ AnkiWeb.',
          );
        }
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        return AnkiWebAuthResult.fail(
          'Email hoặc mật khẩu AnkiWeb không chính xác.',
        );
      } else if (response.statusCode == 429) {
        return AnkiWebAuthResult.fail(
          'Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau ít phút.',
        );
      } else {
        return AnkiWebAuthResult.fail(
          'Lỗi máy chủ AnkiWeb (${response.statusCode}): ${response.reasonPhrase ?? "Unknown"}',
        );
      }
    } on http.ClientException catch (e) {
      return AnkiWebAuthResult.fail(
        'Không thể kết nối máy chủ AnkiWeb. Vui lòng kiểm tra mạng: ${e.message}',
      );
    } catch (e) {
      return AnkiWebAuthResult.fail('Lỗi kết nối AnkiWeb: $e');
    }
  }
}
