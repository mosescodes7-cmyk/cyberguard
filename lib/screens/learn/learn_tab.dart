import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/awareness.dart';
import '../../models/learning_resource.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import 'article_screen.dart';
import 'assistant_screen.dart';
import 'resource_screen.dart';

class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  late final Stream<List<LearningResource>> _resources;
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _resources = context.read<FirestoreService>().resources();
  }

  Widget _grid(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 640 ? 2 : 1;
        final w = (c.maxWidth - (cols - 1) * 14) / cols;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [for (final card in cards) SizedBox(width: w, child: card)],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabScroll(
      children: [
        const MixedTitle('Learn to stay **safe**', size: 30),
        const SizedBox(height: 8),
        const Text(
          'Guides and resources written for everyday life in Mbarara City.',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w300, height: 1.4),
        ),
        const SizedBox(height: 22),
        InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AssistantScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.alpha(Colors.white, 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_outlined, size: 26),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ask the AI agent',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Get quick answers about scams and online safety.',
                          style: TextStyle(height: 1.35, fontSize: 14)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),
        StreamBuilder<List<LearningResource>>(
          stream: _resources,
          builder: (context, snap) {
            final all = snap.data ?? const <LearningResource>[];
            if (all.isEmpty) return const SizedBox.shrink();
            final cats = <String>{'All', ...all.map((r) => r.category)}.toList();
            final selected = cats.contains(_category) ? _category : 'All';
            final items =
                all.where((r) => selected == 'All' || r.category == selected).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('Latest resources'),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final c in cats)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoicePill(
                            label: c,
                            selected: selected == c,
                            onTap: () => setState(() => _category = c),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _grid([
                  for (final r in items)
                    AppCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ResourceScreen(resource: r)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(r.icon, color: AppColors.navy),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 15.5, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${r.typeLabel}  -  ${r.category}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12.5, color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ]),
              ],
            );
          },
        ),
        const SectionHeader('Essential guides'),
        _grid([
          for (final a in awarenessArticles)
            AppCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ArticleScreen(article: a)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(a.icon, color: AppColors.navy),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${a.minutes} min read',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ]),
      ],
    );
  }
}
