import 'package:flutter/material.dart';
class AddHealthMetricPage extends StatelessWidget {
  final String metricType;
  const AddHealthMetricPage({super.key, required this.metricType});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add \$metricType')),
      body: const Center(child: Text('Add Health Metric - Coming Soon')),
    );
  }
}
