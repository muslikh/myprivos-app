import 'package:flutter/material.dart';

/// Converts any exception into a friendly, non-technical message.
/// Never exposes raw backend/SQL errors to the user.
String friendlyError(Object _) => 'Belum dapat memuat data saat ini.';

/// Reusable list loader with modern loading / empty / friendly-error states.
class AsyncList<T> extends StatefulWidget {
  final Future<List<T>> Function() loader;
  final Widget Function(BuildContext, T) itemBuilder;
  final String emptyText;
  final IconData emptyIcon;

  const AsyncList({
    super.key,
    required this.loader,
    required this.itemBuilder,
    this.emptyText = 'Belum ada data.',
    this.emptyIcon = Icons.inbox_outlined,
  });

  @override
  State<AsyncList<T>> createState() => _AsyncListState<T>();
}

class _AsyncListState<T> extends State<AsyncList<T>> {
  late Future<List<T>> _future;

  @override
  void initState() {
    super.initState();
    _future = _safeLoad();
  }

  Future<List<T>> _safeLoad() async {
    try {
      return await widget.loader();
    } catch (_) {
      // Swallow errors -> treated as empty (friendly state), never raw error.
      return <T>[];
    }
  }

  Future<void> _refresh() async {
    setState(() => _future = _safeLoad());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _LoadingList();
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                EmptyState(text: widget.emptyText, icon: widget.emptyIcon, onRetry: _refresh),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (c, i) => widget.itemBuilder(c, items[i]),
          ),
        );
      },
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (c, i) => Card(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: base),
          title: Container(height: 12, margin: const EdgeInsets.only(right: 80), decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8, right: 40),
            child: Container(height: 10, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String text;
  final IconData icon;
  final Future<void> Function()? onRetry;
  const EmptyState({super.key, required this.text, this.icon = Icons.inbox_outlined, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: scheme.primaryContainer.withOpacity(0.4), shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center, style: TextStyle(color: scheme.outline, fontSize: 14)),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, size: 18), label: const Text('Muat ulang')),
            ],
          ],
        ),
      ),
    );
  }
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    behavior: SnackBarBehavior.floating,
    backgroundColor: error ? Colors.red.shade700 : null,
  ));
}
