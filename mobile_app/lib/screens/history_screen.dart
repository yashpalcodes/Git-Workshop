import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/detection.dart';
import '../providers/detection_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetectionProvider>();
    final List<DetectionResult> items = provider.history;

    return Scaffold(
      appBar: AppBar(title: const Text('Detection History')),
      body: RefreshIndicator(
        onRefresh: () => provider.loadHistory(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, index) {
            final item = items[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: item.vehicleType == VehicleType.lmv ? Colors.green : (item.vehicleType == VehicleType.hmv ? Colors.orange : Colors.grey),
                child: Text(vehicleTypeToString(item.vehicleType)[0]),
              ),
              title: Text(item.plateNumber),
              subtitle: Text(DateFormat.yMd().add_jm().format(item.timestamp)),
              trailing: Text('${(item.confidence * 100).toStringAsFixed(0)}%'),
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: items.length,
        ),
      ),
    );
  }
}
