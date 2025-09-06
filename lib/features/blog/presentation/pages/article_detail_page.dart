import 'package:flutter/material.dart';
class ArticleDetailPage extends StatelessWidget {
  final int articleId;
  const ArticleDetailPage({super.key, required this.articleId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: Center(child: Text('Article \$articleId - Coming Soon')),
    );
  }
}
