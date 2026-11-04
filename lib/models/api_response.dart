/// Parsed form of the backend JSON envelope:
/// { success, code, message, data, timestamp, meta?, errors? }
class ApiResponse {
  final bool success;
  final int code;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? meta;
  final dynamic errors;

  ApiResponse({
    required this.success,
    required this.code,
    required this.message,
    this.data,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] == true,
      code: (json['code'] is int) ? json['code'] : int.tryParse('${json['code']}') ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'],
      meta: json['meta'] is Map ? Map<String, dynamic>.from(json['meta']) : null,
      errors: json['errors'],
    );
  }

  List<dynamic> get list => (data is List) ? data as List : <dynamic>[];
  Map<String, dynamic> get map =>
      (data is Map) ? Map<String, dynamic>.from(data as Map) : <String, dynamic>{};
}

/// Thrown for non-success envelopes or transport errors, so the UI can show a message.
class ApiException implements Exception {
  final String message;
  final int code;
  ApiException(this.message, [this.code = 0]);
  @override
  String toString() => message;
}
