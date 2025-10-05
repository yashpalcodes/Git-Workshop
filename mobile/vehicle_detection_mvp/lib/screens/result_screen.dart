import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/detection_result.dart';

class ResultScreen extends StatelessWidget {
  static const String routeName = '/result';
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DetectionResult result = ModalRoute.of(context)!.settings.arguments as DetectionResult;
    final dateStr = DateFormat.yMMMd().add_jm().format(result.timestamp);

    return Scaffold(
      appBar: AppBar(title: const Text('Detection Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(label: Text(result.vehicleType)),
                    const SizedBox(width: 8),
                    Chip(label: Text('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%')),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Number Plate', style: Theme.of(context).textTheme.titleSmall),
                Text(result.numberPlate, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('Location', style: Theme.of(context).textTheme.titleSmall),
                Text(result.location, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('Detected at $dateStr'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
