import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/detection.dart';
import '../providers/detection_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Color _vehicleTypeColor(VehicleType type) {
    switch (type) {
      case VehicleType.lmv:
        return Colors.green;
      case VehicleType.hmv:
        return Colors.orange;
      case VehicleType.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetectionProvider>();
    final DetectionResult? result = provider.lastResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Detection Result')),
      body: result == null
          ? const Center(child: Text('No result available'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      title: Text('Vehicle Type: ${vehicleTypeToString(result.vehicleType)}'),
                      trailing: CircleAvatar(backgroundColor: _vehicleTypeColor(result.vehicleType), radius: 8),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Number Plate'),
                      subtitle: Text(result.plateNumber),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Confidence'),
                      subtitle: Text('${(result.confidence * 100).toStringAsFixed(1)}%'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Location'),
                      subtitle: Text(
                        [
                          if (result.location.address != null) result.location.address,
                          if (result.location.latitude != null && result.location.longitude != null)
                            '(${result.location.latitude}, ${result.location.longitude})',
                        ].whereType<String>().join('\n'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Timestamp'),
                      subtitle: Text(DateFormat.yMd().add_jm().format(result.timestamp)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
