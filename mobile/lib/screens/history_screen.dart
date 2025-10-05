import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  static const String routeName = '/history';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<HistoryService>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryService>().history;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detections History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => context.read<HistoryService>().clear(),
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = history[index];
          final dateStr = DateFormat.yMMMd().add_jm().format(item.timestamp);
          return ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(item.numberPlate),
            subtitle: Text('${item.vehicleType} • ${(item.confidence * 100).toStringAsFixed(1)}% • $dateStr'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/result', arguments: item),
          );
        },
      ),
    );
  }
}
