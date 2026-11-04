import '../core/api_client.dart';

class UpjService {
  static Future<List<dynamic>> items({String? type, dynamic categoryId}) async {
    final r = await ApiClient.instance
        .get('/upj/items', query: {'type': type, 'category_id': categoryId});
    return r.list;
  }

  static Future<Map<String, dynamic>> checkout({
    required List<Map<String, dynamic>> items,
    required num paidAmount,
    String? buyerName,
  }) async {
    final r = await ApiClient.instance.post('/upj/checkout', body: {
      'items': items,
      'paid_amount': paidAmount,
      'buyer_name': buyerName,
    });
    return r.map;
  }

  static Future<Map<String, dynamic>> checkTicket(String ticketNumber) async {
    final r = await ApiClient.instance.get('/upj/ticket/$ticketNumber');
    return r.map;
  }

  static Future<void> submitPklJournal({
    required dynamic placementId,
    required String date,
    required String activities,
    String? photoUrl,
  }) async {
    await ApiClient.instance.post('/upj/pkl/jurnal', body: {
      'pkl_placement_id': placementId,
      'date': date,
      'activities': activities,
      'photo_url': photoUrl,
    });
  }

  static Future<Map<String, dynamic>> borrow({
    required String itemCode,
    required String borrowerName,
  }) async {
    final r = await ApiClient.instance.post('/upj/sarpras/pinjam', body: {
      'item_code': itemCode,
      'borrower_name': borrowerName,
    });
    return r.map;
  }
}
