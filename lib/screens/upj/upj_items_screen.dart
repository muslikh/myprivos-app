import 'package:flutter/material.dart';
import '../../services/upj_service.dart';
import '../../widgets/async_views.dart';

class UpjItemsScreen extends StatefulWidget {
  const UpjItemsScreen({super.key});
  @override
  State<UpjItemsScreen> createState() => _UpjItemsScreenState();
}

class _UpjItemsScreenState extends State<UpjItemsScreen> {
  final Map<dynamic, Map<String, dynamic>> _cart = {};

  num get _total {
    num t = 0;
    _cart.forEach((_, v) {
      final price = num.tryParse('${v['item']['price'] ?? v['item']['harga'] ?? 0}') ?? 0;
      t += price * (v['qty'] as int);
    });
    return t;
  }

  int get _count => _cart.values.fold(0, (a, v) => a + (v['qty'] as int));

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
    final items = _cart.entries.map((e) => {'id': e.key, 'qty': e.value['qty']}).toList();
    try {
      final r = await UpjService.checkout(items: items, paidAmount: _total);
      if (!mounted) return;
      final tx = r['transaction_code'] ?? r['kode'] ?? r['id'] ?? '';
      showSnack(context, 'Pesanan berhasil diproses. $tx');
      setState(() => _cart.clear());
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog UPJ')),
      body: AsyncList<Map<String, dynamic>>(
        emptyText: 'Katalog belum tersedia.',
        emptyIcon: Icons.storefront_outlined,
        loader: () async =>
            (await UpjService.items()).map((e) => Map<String, dynamic>.from(e)).toList(),
        itemBuilder: (c, item) {
          final id = item['id'];
          final qty = _cart[id]?['qty'] as int? ?? 0;
          final price = item['price'] ?? item['harga'] ?? 0;
          return Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.inventory_2_outlined, color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['name'] ?? item['nama'] ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('Rp $price', style: TextStyle(color: scheme.primary)),
                      ],
                    ),
                  ),
                  if (qty == 0)
                    FilledButton.tonal(
                      onPressed: () => _add(item),
                      child: const Text('Pesan'),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _remove(id)),
                        Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _add(item)),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$_count item', style: TextStyle(color: scheme.outline, fontSize: 12)),
                    Text('Total Rp $_total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _cart.isEmpty ? null : _checkout,
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
