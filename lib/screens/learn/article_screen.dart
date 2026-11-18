import 'package:flutter/material.dart';

import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/awareness.dart';
import '../../widgets/common.dart';
import '../../widgets/sub_page.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});
  final AwarenessArticle article;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    return SubPage(
      title: 'Guide',
      maxWidth: 680,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, 10, pad, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(article.icon, color: AppColors.navy, size: 30),
            ),
            const SizedBox(height: 18),
            Text(article.title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2)),
            const SizedBox(height: 8),
            Text('${article.tagline}  -  ${article.minutes} min read',
                style: const TextStyle(color: AppColors.muted, height: 1.4)),
            const SizedBox(height: 22),
            Text(article.intro,
                style: const TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.w300)),
            const SectionHeader('Key points'),
            AppCard(
              child: Column(
                children: [
                  for (final p in article.points)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(Icons.circle, size: 8, color: AppColors.accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(p, style: const TextStyle(height: 1.5, fontSize: 15))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SectionHeader('Do'),
            _ChecklistCard(items: article.dos, good: true),
            const SectionHeader('Do not'),
            _ChecklistCard(items: article.donts, good: false),
          ],
        ),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.items, required this.good});
  final List<String> items;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final color = good ? AppColors.safe : AppColors.danger;
    return AppCard(
      light: true,
      child: Column(
        children: [
          for (final t in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(good ? Icons.check_circle : Icons.cancel, color: color, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(t,
                        style: const TextStyle(
                            height: 1.5, fontSize: 15, color: AppColors.ink)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
