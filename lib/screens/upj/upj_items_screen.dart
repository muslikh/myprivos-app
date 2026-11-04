import 'package:flutter/material.dart';
import '../../services/upj_service.dart';
import '../../widgets/async_views.dart';

class UpjItemsScreen extends StatefulWidget {
  const UpjItemsScreen({super.key});
  @override
  State<UpjItemsScreen> createState() => _UpjItemsScreenState();
}

class _UpjItemsScreenState extends State<UpjItemsScreen> {
  // itemId -> {item, qty}
  final Map<dynamic, Map<String, dynamic>> _cart = {};

  num get _total {
    num t = 0;
    _cart.forEach((_, v) {
      final price = num.tryParse('${v['item']['price'] ?? v['item']['harga'] ?? 0}') ?? 0;
      t += price * (v['qty'] as int);
    });
    return t;
  }

  void _add(Map<String, dynamic> item) {
    final id = item['id'];
    setState(() {
      if (_cart.containsKey(id)) {
        _cart[id]!['qty'] = (_cart[id]!['qty'] as int) + 1;
      } else {
        _cart[id] = {'item': item, 'qty': 1};
      }
    });
  }

  void _remove(dynamic id) {
    setState(() {
      if (!_cart.containsKey(id)) return;
      final q = _cart[id]!['qty'] as int;
      if (q <= 1) {
        _cart.remove(id);
      } else {
        _cart[id]!['qty'] = q - 1;
      }
    });
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;
    final items = _cart.entries
        .map((e) => {'id': e.key, 'qty': e.value['qty']})
        .toList();
    try {
      final r = await UpjService.checkout(items: items, paidAmount: _total);
      if (!mounted) return;
      final tx = r['transaction_code'] ?? r['kode'] ?? r['id'] ?? '';
      showSnack(context, 'Transaksi berhasil. $tx');
      setState(() => _cart.clear());
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog UPJ')),
      body: AsyncList<Map<String, dynamic>>(
        loader: () async =>
            (await UpjService.items()).map((e) => Map<String, dynamic>.from(e)).toList(),
        emptyText: 'Katalog kosong.',
        itemBuilder: (c, item) {
          final id = item['id'];
          final qty = _cart[id]?['qty'] as int? ?? 0;
          final price = item['price'] ?? item['harga'] ?? 0;
          return Card(
            child: ListTile(
              title: Text('${item['name'] ?? item['nama'] ?? '-'}'),
              subtitle: Text('Rp $price  •  ${item['type'] ?? ''}'),
              trailing: qty == 0
                  ? IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => _add(item),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _remove(id)),
                        Text('$qty'),
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _add(item)),
                      ],
                    ),
            ),
          );
        },
      ),
      bottomNavigationBar: _cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${_cart.length} item • Total Rp $_total',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    FilledButton.icon(
                      onPressed: _checkout,
                      icon: const Icon(Icons.point_of_sale),
                      label: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
