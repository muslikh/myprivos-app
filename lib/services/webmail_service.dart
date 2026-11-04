import '../core/api_client.dart';

class WebmailService {
  static Future<List<dynamic>> accounts() async {
    final r = await ApiClient.instance.get('/webmail/accounts');
    return r.list;
  }

  static Future<List<dynamic>> broadcasts() async {
    final r = await ApiClient.instance.get('/webmail/broadcasts');
    return r.list;
  }

  static Future<void> send({
    required String to,
    required String subject,
    required String body,
  }) async {
    await ApiClient.instance.post('/webmail/send', body: {
      'to': to,
      'subject': subject,
      'body': body,
    });
  }
}
