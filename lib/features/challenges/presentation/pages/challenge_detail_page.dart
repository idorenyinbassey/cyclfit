import 'package:flutter/material.dart';
class ChallengeDetailPage extends StatelessWidget {
  final int challengeId;
  const ChallengeDetailPage({super.key, required this.challengeId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge')),
      body: Center(child: Text('Challenge \$challengeId - Coming Soon')),
    );
  }
}
