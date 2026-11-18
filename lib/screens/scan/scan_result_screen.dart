import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/scan_result.dart';
import '../../widgets/common.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/risk_gauge.dart';
import '../../widgets/sub_page.dart';
import '../community/create_report_screen.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key, required this.result});
  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final v = result.verdict;
    final pad = Responsive.hPad(context);
    final gauge = math.min(260.0, Responsive.width(context) * 0.62);

    return SubPage(
      title: 'Scan result',
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, 10, pad, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: RiskGauge(
                score: result.riskScore,
                color: v.color,
                label: v.label,
                size: gauge,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  Tag(result.category, color: v.color),
                  Tag(result.kindLabel),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (result.summary.isNotEmpty)
              AppCard(
                child: Text(
                  result.summary,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            const SectionHeader('Why we think so'),
            AppCard(
              child: Column(
                children: [
                  for (final r in result.reasons)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.circle, size: 8, color: v.color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(r, style: const TextStyle(height: 1.45, fontSize: 14.5)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SectionHeader('What you should do'),
            AppCard(
              light: true,
              child: Column(
                children: [
                  for (final a in result.actions)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, size: 20, color: AppColors.navy),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              a,
                              style: const TextStyle(
                                  height: 1.45, fontSize: 14.5, color: AppColors.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SectionHeader('Checked content'),
            AppCard(
              child: SelectableText(
                result.input,
                maxLines: 6,
                style: const TextStyle(color: AppColors.muted, height: 1.4),
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Report to community',
              icon: Icons.campaign_outlined,
              onPressed: () {
                final what = result.kind == ScanKind.link ? 'link' : 'message';
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateReportScreen(
                      initialCategory: AppConfig.guessCategory(result.category),
                      initialDescription:
                          'I received a suspicious $what flagged as '
                          '${result.category.toLowerCase()}. ',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlineButtonX(
              label: 'Scan another',
              icon: Icons.refresh,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                result.source,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
